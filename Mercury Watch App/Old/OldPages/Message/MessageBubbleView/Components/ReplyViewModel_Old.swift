//
//  ReplyViewModel.swift
//  Mercury Watch App
//
//  Created by Alessandro Alberti on 07/09/24.
//

import SwiftUI
import TDLibKit

class ReplyViewModel_Old: ObservableObject {
    @Published var color: Color = .blue
    @Published var title: String = "Title"
    @Published var text: AttributedString = "Message"
    @Published var isLoading: Bool = true
    var message: Message
    
    init(message: Message) {
        self.message = message
        
        Task {
            await getReplyMessage()
        }
    }
    
    func getReplyMessage() async {
        
        guard case let .messageReplyToMessage(replyId) = message.replyTo,
              let replyMsg = try? await TDLibManager.shared.client?.getMessage(
                chatId: replyId.chatId,
                messageId: replyId.messageId),
              case let .messageSenderUser(sender) = replyMsg.senderId,
              let user = try? await TDLibManager.shared.client?.getUser(userId: sender.userId)
        else { return }
        
        await MainActor.run {
            withAnimation {
                self.title = user.fullName
                self.text = replyMsg.description
                self.color = message.isOutgoing ?
                    .white : Color(fromUserId: sender.userId)
                self.isLoading = false
            }
        }
    }
}
