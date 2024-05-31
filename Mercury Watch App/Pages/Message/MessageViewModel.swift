//
//  MessageViewModel.swift
//  Mercury Watch App
//
//  Created by Alessandro Alberti on 17/05/24.
//

import SwiftUI
import TDLibKit


class MessageViewModel: ObservableObject {
    var message: Message
    var chat: Chat
    @Published var user: User?
    
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
    
    var showBubble: Bool {
        switch message.content {
        case .messagePhoto(_) :
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
    
    var date: String {
        Date(fromUnixTimestamp: message.date).stringDescription
    }
    
    var userFullName: String {
        guard let user else { return "placeholder" }
        var string = user.firstName
        if user.lastName != "" {
            string += " " + user.lastName
        }
        
        return string
    }
    
    var userNameRedaction: RedactionReasons {
        userFullName == "placeholder" ? .placeholder : []
    }
    
    var titleColor: Color {
        return Color(fromUserId: senderID)
    }
    
    init(message: Message, chat: Chat) {
        self.message = message
        self.chat = chat
        
        Task {
            let user = try? await TDLibManager.shared.client?.getUser(userId: senderID)
            DispatchQueue.main.async {
                withAnimation {
                    self.user = user
                }
            }
        }
    }
    
}
