//
//  MockChatViewModel.swift
//  Mercury Watch App
//
//  Created by Alessandro Alberti on 31/05/24.
//

import TDLibKit
import SwiftUI

class MockChatDetailViewModel: ChatDetailViewModel {
    
    init(messages: [Message] = [], chat: ChatCellModel = .from(.preview())) {
        super.init(chat: chat, sendService: MockSendMessageService(chat: chat.td))
        isLoadingInitialMessages = false
        
        switch chat.td.title {
        case "iOS Devs":
            self.messages = [
                .preview(
                    content: .text("SwiftUI or UIKit?")
                ),
                .preview(
                    content: .text("SwiftUI!! 🤩"),
                    isOutgoing: true
                ),
                .preview(
                    content: .text("Who's excited for WWDC? 😁")
                )
            ]
        case "Craig":
            self.messages = [
                .preview(
                    content: .text("Ready?"),
                    isOutgoing: true
                ),
                .preview(
                    content: .text("Let's rock! 🎸")
                )
            ]
        case "Lisa":
            self.messages = [
                .preview(
                    content: .text("Where're you??"),
                    isOutgoing: true
                ),
                .preview(
                    content: .text("I'm on the roof! ☀️")
                )
            ]
        default:
            break
        }
        
    }
    
    override func requestInitialMessage() {}
    override func requestMoreMessages(limit: Int = 30) async {}
    
    override func getMessageVM(for message: Message) -> MessageViewModel {
        var sender = ""
        var color: Color = .blue
        
        switch message.content {
        case .messageText(let messageText):
            switch messageText.text.attributedString {
            case "Who's excited for WWDC? 😁":
                sender = "Alessandro"
                color = .tdOrange
            case "SwiftUI or UIKit?":
                sender = "Marco"
                color = .tdTeal
            default:
                break
            }
        default:
            break
        }
        
        return MessageViewModelMock(message: message, name: sender, titleColor: color, showSender: sender != "")
    }
}
