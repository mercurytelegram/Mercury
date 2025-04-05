//
//  ChatDetailViewModel+Messages.swift
//  Mercury Watch App
//
//  Created by Marco Tammaro on 08/11/24.
//

import SwiftUI
import TDLibKit

extension ChatDetailViewModel {
    
    enum RequestMessageDirection {
        case forward, backward, all
    }
    
    func requestMessages(
        fromId: Int64? = nil,
        direction: RequestMessageDirection,
        quantity: Int = 4
    ) async -> [MessageModel] {
        
        var offset: Int {
            switch direction {
            case .forward:
                -quantity
            case .backward:
                0
            case .all:
                -Int(quantity/2)
            }
        }
        
        self.logger.log("Loading \(quantity) \(direction) messages")
        
        do {
            
            let result = try await TDLibManager.shared.client?.getChatHistory(
                chatId: self.chatId,
                fromMessageId: fromId,
                limit: quantity,
                offset: offset,
                onlyLocal: false
            )
            
            let data: [Message] = result?.messages ?? []
            
            var newMessages: [MessageModel] = []
            for msg in data {
                newMessages.append(await self.messageModelFrom(msg))
            }
            
            // Add date pill between messages
            // TODO: move this logics into message cell
//            for (index, msg) in newMessages.enumerated() {
//                
//                guard index + 1 < newMessages.count else { continue }
//                
//                // check if the next message is from a different day
//                let nextDate = newMessages[index + 1].date
//                let currentDate = msg.date
//                if !Calendar.current.isDate(nextDate, inSameDayAs: currentDate) {
//                    newMessages.insert(
//                        await self.dateSeparatorFor(currentDate),
//                        at: index + 1
//                    )
//                }
//            }
            
            return newMessages
            
        } catch {
            self.logger.log(error, level: .error)
            return []
        }
        
    }
    
    func fetchBackwardMessages(_ message: MessageModel) async -> [MessageModel] {
        return (await self.requestMessages(fromId: message.id, direction: .backward)).reversed()
    }
    
    func fetchForwardMessage(_ message: MessageModel) async -> [MessageModel] {
        return (await self.requestMessages(fromId: message.id, direction: .forward)).reversed()
    }
    
    func onMessagesAppear(_ messages: Set<MessageModel>) {
        for msg in messages { self.onMessageAppear(msg) }
    }
    
    func messageModelFrom(_ message: Message) async -> MessageModel {
        
        let date = Date(fromUnixTimestamp: message.date)
        let senderColor = Color(fromUserId: message.senderID)
        let sender = await self.senderNameFrom(message)
        let reactionsData = message.interactionInfo?.reactions?.reactions ?? []
        let reactions = reactionsModelFrom(reactionsData)
        let reply = await replyModelFrom(message.replyTo, isOutgoing: message.isOutgoing)
        let stateStyle = await stateStyleFrom(message)
        let content = await messageContentFrom(message)
        
        return MessageModel(
            id: message.id,
            sender: sender.name,
            senderColor: senderColor,
            isSenderHidden: sender.isHidden,
            date: date,
            isOutgoing: message.isOutgoing,
            reactions: reactions,
            reply: reply,
            stateStyle: stateStyle,
            content: content
        )
    }
    
    func dateSeparatorFor(_ currentDate: Foundation.Date) async -> MessageModel {
        let content = MessageModel.MessageContent.pill(
            title: nil,
            description: currentDate.dayDescription
        )
        
        return MessageModel(
            id: Int64(currentDate.timeIntervalSince1970),
            date: currentDate,
            content: content
        )
    }
    
    @MainActor
    func insertMessage(at: InsertAt, message: MessageModel) {
        
        guard message.stateStyle != .failed
        else { return }
        
        // if message has been already shown, update it by removing the old one
        self.messages.removeAll(where: { $0.id == message.id })
        
        switch at {
        case .first:
            self.messages.insert(message, at: 0)
        case .last:
            self.messages.append(message)
        case .index(let value):
            self.messages.insert(message, at: value)
        }
    }
    
    func senderNameFrom(_ message: Message) async -> (name: String, isHidden: Bool) {
        let name: String
        var isHidden: Bool = false
        
        if message.isOutgoing {
            isHidden = true
        }
        
        let chat = try? await TDLibManager.shared.client?.getChat(chatId: message.chatId)
        if !(chat?.isGroup ?? true) {
            isHidden = true
        }
        
        switch message.senderId {
        case .messageSenderUser(let user):
            name = (try? await TDLibManager.shared.client?.getUser(userId: user.userId))?.fullName ?? ""
        case .messageSenderChat(let chat):
            name = (try? await TDLibManager.shared.client?.getChat(chatId: chat.chatId))?.title ?? ""
        }
        
        if name.isEmpty {
            isHidden = true
        }
        
        return (name, isHidden)
    }
    
    func stateStyleFrom(_ message: Message) async -> MessageModel.StateStyle? {

        if !message.isOutgoing { return nil }
        
        let chat = try? await TDLibManager.shared.client?.getChat(chatId: message.chatId)
        
        var state: MessageModel.StateStyle? = nil
        let lastReadMessageId = chat?.lastReadOutboxMessageId
        if message.sendingState != nil {
            state = .sending
        } else if let lastReadMessageId, message.id <= lastReadMessageId {
            state = .seen
        } else if message.isOutgoing {
            state = .delivered
        }
        
        return state
    }
    
    func reactionsModelFrom(_ reactions:  [MessageReaction]) -> [ReactionModel] {
        return reactions.map { reaction in
            var emoji = "?"
            if case .reactionTypeEmoji(let type) = reaction.type {
                emoji = type.emoji
            }
            return ReactionModel(
                emoji: emoji,
                count: reaction.totalCount,
                isSelected: reaction.isChosen,
                recentUsers: reaction.recentSenderIds.map { sender in
                    if case .messageSenderUser(let user) = sender {
                        return user.userId
                    }
                    return 0
                }
            )
        }
    }
    
    func replyModelFrom(_ reply: MessageReplyTo?, isOutgoing: Bool) async -> ReplyModel? {
        if case .messageReplyToMessage(let replyId) = reply,
           let replyMsg = try? await TDLibManager.shared.client?.getMessage(
            chatId: replyId.chatId,
            messageId: replyId.messageId
        ) {
            
            return ReplyModel(
                color: isOutgoing ? .white : Color(fromUserId: replyMsg.senderID),
                title: await self.senderNameFrom(replyMsg).name,
                text: replyMsg.description
            )
            
        }
        
        return nil
    }
    
    func setMessageAsOpened(_ messageId: Int64) {
        Task.detached(priority: .background) {
            do {
                try await TDLibManager.shared.client?.openMessageContent(
                    chatId: self.chatId,
                    messageId: messageId
                )
            } catch {
                self.logger.log(error, level: .error)
            }
        }
    }

   
}
