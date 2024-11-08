//
//  ChatDetailViewModel+Messages.swift
//  Mercury Watch App
//
//  Created by Marco Tammaro on 08/11/24.
//

import SwiftUI
import TDLibKit

extension ChatDetailViewModel {
    
    func requestMessages(fromId: Int64? = nil, firstBatch: Bool = false, limit: Int = 30) async -> [MessageModel] {
        
        if isLoadingInitialMessages && firstBatch { return [] }
        await MainActor.run {
            isLoadingInitialMessages = firstBatch
        }
        
        if isLoadingMoreMessages && !firstBatch { return [] }
        await MainActor.run {
            isLoadingMoreMessages = !firstBatch
        }
        
        self.logger.log("Loading \(limit) \(firstBatch ? "initial" : "more") messages")
        
        do {
            
            let result = try await TDLibManager.shared.client?.getChatHistory(
                chatId: self.chatId,
                fromMessageId: fromId,
                limit: limit,
                offset: 0,
                onlyLocal: false
            )
            
            let data: [Message] = result?.messages ?? []
            
            var newMessages: [MessageModel] = []
            for msg in data {
                newMessages.append(await self.messageModelFrom(msg))
            }
           
            await MainActor.run {
                isLoadingInitialMessages = false
                isLoadingMoreMessages = false
            }
            
            if newMessages.count == 1 && firstBatch {
                newMessages += await self.requestMessages(fromId: newMessages.first?.id)
            }
            
            return newMessages
            
        } catch {
            self.logger.log(error, level: .error)
            return []
        }
        
    }
    
    func messageModelFrom(_ message: Message) async -> MessageModel {
        
        let time = Date(fromUnixTimestamp: message.date).formatted(.dateTime.hour().minute())
        let senderColor = Color(fromUserId: message.senderID)
        let senderName = await self.senderNameFrom(message.senderId)
        let reactionsData = message.interactionInfo?.reactions?.reactions ?? []
        let reactions = reactionsModelFrom(reactionsData)
        let reply = await replyModelFrom(message.replyTo, isOutgoing: message.isOutgoing)
        let stateStyle = await stateStyleFrom(message)
        
        return MessageModel(
            id: message.id,
            sender: senderName,
            senderColor: senderColor,
            time: time,
            isOutgoing: message.isOutgoing,
            reactions: reactions,
            reply: reply,
            stateStyle: stateStyle,
            content: .text(message.description)
        )
    }
    
    @MainActor
    func insertMessage(at: InsertAt, message: MessageModel) {
        
        guard message.stateStyle != .failed
        else { return }
        
        // if message has been already shown, update it by removing the old one
        self.messages.removeAll(where: { $0.id == message.id })
        
        withAnimation {
            switch at {
            case .first:
                self.messages.insert(message, at: 0)
            case .last:
                self.messages.append(message)
            case .index(let value):
                self.messages.insert(message, at: value)
            }
        }
    }
    
    func senderNameFrom(_ sender: MessageSender) async -> String {
        switch sender {
        case .messageSenderUser(let user):
            return (try? await TDLibManager.shared.client?.getUser(userId: user.userId))?.fullName ?? ""
        case .messageSenderChat(let chat):
            return (try? await TDLibManager.shared.client?.getChat(chatId: chat.chatId))?.title ?? ""
        }
    }
    
    func stateStyleFrom(_ message: Message) async -> MessageModel.StateStyle? {
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
                title: await self.senderNameFrom(replyMsg.senderId),
                text: replyMsg.description
            )
            
        }
        
        return nil
    }
   
}
