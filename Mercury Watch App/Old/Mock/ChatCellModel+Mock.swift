//
//  ChatCellModel+Mock.swift
//  Mercury Watch App
//
//  Created by Alessandro Alberti on 31/05/24.
//

import TDLibKit
import SwiftUI

extension ChatCellModel {

    static func preview(
        title: String = "Craig Federighi",
        sender: String? = nil,
        message: AttributedString = "Message",
        unreadCount: Int = 0,
        showUnreadMention: Bool = false,
        showUnreadReaction: Bool = false,
        isOnline: Bool = false,
        color: Color = .blue,
        imageName: String? = nil
    ) -> ChatCellModel {
        
        var chatModel = ChatCellModel.from(.preview(
            title: title,
            lastMessage: .preview(),
            type: sender == nil ? .privatePreview() : .groupPreview(),
            unreadCount: unreadCount
        ))
        
        chatModel.unreadCount = unreadCount
        chatModel.showUnreadMention = showUnreadMention
        chatModel.showUnreadReaction = showUnreadReaction
        if showUnreadMention || showUnreadReaction {
            chatModel.unreadCount = 1
        }
        
        chatModel.message = message
        if let sender {
            var senderString = AttributedString(sender + ": ")
            senderString.foregroundColor = .white
            chatModel.message = senderString + message
        }
        
        chatModel.time = "10:09"
        chatModel.avatar.isOnline = isOnline
        chatModel.avatar.color = color
        
        if let imageName {
            chatModel.avatar.tdImage = TDImageMock(imageName)
        }
        return chatModel
    }
}
