//
//  MessageViewModel.swift
//  Mercury Watch App
//
//  Created by Alessandro Alberti on 17/05/24.
//

import SwiftUI
import TDLibKit
import AVFAudio

class MessageViewModel: TDLibViewModel {
    
    var chat: Chat
    
    @Published var message: Message
    @Published var user: User?
    @Published var state: MessageSendingState? = nil
    
    init(message: Message, chat: Chat) {
        self.message = message
        self.chat = chat
        self.state = message.sendingState != nil ? .sending : nil
        super.init()
        
        initUser()
    }
    
    override func updateHandler(update: Update) {
        super.updateHandler(update: update)
        switch update {
        case .updateMessageContent(let update):
            self.updateMessageContent(messageId: update.messageId)
        case .updateMessageSendSucceeded(let update):
            self.updateMessageSendStatus(oldId: update.oldMessageId, message: update.message, status: .success)
        case .updateMessageSendFailed(let update):
            self.updateMessageSendStatus(oldId: update.oldMessageId, message: update.message, status: .failure)
        default:
            break
        }
    }
    
    private func updateMessageContent(messageId: Int64) {
        guard messageId == self.message.id else { return }
        
        Task {
            guard let newMessage = try? await TDLibManager.shared.client?.getMessage(chatId: self.chat.id, messageId: messageId)
            else { return }
            
            await MainActor.run {
                withAnimation {
                    self.message = newMessage
                }
            }
            
        }
    }
    
    private enum MessageSendStatus { case success, failure }
    private func updateMessageSendStatus(oldId: Int64, message: Message, status: MessageSendStatus) {
        guard oldId == self.message.id else { return }
        DispatchQueue.main.async {
            withAnimation {
                self.message = message
                
                switch status {
                case .success:
                    self.state = .delivered
                case .failure:
                    self.state = .failed
                }
            }
        }
    }
    
    var textAlignment: HorizontalAlignment {
        message.isOutgoing ? .trailing : .leading
    }
    
    var showSender: Bool {
        if message.isOutgoing {
            return false
        }
        
        switch chat.type {
        case .chatTypePrivate(_):
            return false
        default:
            return true
        }
    }
    
    var senderID: Int64 {
        switch message.senderId {
        case .messageSenderUser(let messageSenderUser):
            messageSenderUser.userId
        case .messageSenderChat(let messageSenderChat):
           messageSenderChat.chatId
        }
    }
    
    var time: String {
        Date(fromUnixTimestamp: message.date).formatted(.dateTime.hour().minute())
    }
    
    var userFullName: String {
        guard let user else { return "placeholder" }
        return user.fullName
    }
    
    var userNameRedaction: RedactionReasons {
        userFullName == "placeholder" ? .placeholder : []
    }
    
    var titleColor: Color {
        return Color(fromUserId: senderID)
    }
    
    var bubbleColor: Color {
        message.isOutgoing ? .blue.opacity(0.7) : .white.opacity(0.2)
    }
    
    var reactions: [Reaction] {
        guard let reactions = message.interactionInfo?.reactions?.reactions else { return [] }
        return reactions.map { reaction in
            var emoji = "?"
            if case .reactionTypeEmoji(let type) = reaction.type {
                emoji = type.emoji
            }
            return Reaction(
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
    
    private func initUser() {
        Task { [weak self] in
            guard let self else { return }
            let user = try? await TDLibManager.shared.client?.getUser(userId: self.senderID)
            DispatchQueue.main.async {
                withAnimation {
                    self.user = user
                }
            }
        }
    }
    
}

enum MessageSendingState {
    case sending, delivered, seen, failed
}
