//
//  MockChatViewModel.swift
//  Mercury Watch App
//
//  Created by Alessandro Alberti on 31/05/24.
//

import TDLibKit
import SwiftUI

class MockChatDetailViewModel: ChatDetailViewModel_Old {
    
    init(messages: [Message] = [], chat: ChatCellModel_Old = .from(.preview())) {
        super.init(chat: chat, sendService: MockSendMessageService(chat: chat.td))
        isLoadingInitialMessages = false
        
        switch chat.td.title {
        case "Alessandro":
            self.messages = [
                .preview(
                    content: .text("Ready?"),
                    isOutgoing: true
                ),
                .preview(
                    content: .text("How's the view from space? 🚀✨")
                )
            ]
        case "Marco":
            self.messages = [
                .preview(
                    content: .text("Where're you??"),
                    isOutgoing: true
                ),
                .preview(
                    content: .text("I'm on the roof! ☀️")
                )
            ]
        case "Mission Control":
            self.messages = [
                .preview(
                    content: .text("SwiftUI or UIKit?")
                ),
                .preview(
                    content: .text("SwiftUI!! 🤩"),
                    isOutgoing: true
                ),
                .preview(
                    content: .text("We have a problem!")
                )
            ]
        default:
            break
        }
        
    }
    
    func messageViewModel(for message: Message) -> MessageViewModel {
        MessageViewModelMock(message: message, name: "Name", titleColor: .blue, showSender: true)
    }
    
    override func requestInitialMessage() {}
    override func requestMoreMessages(limit: Int = 30) async {}
    
    override var canSendVoiceNotes: Bool { true }
    override var canSendText: Bool { true }
    override var canSendStickers: Bool { true }
}
