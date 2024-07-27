//
//  Extensions+Message.swift
//  Mercury Watch App
//
//  Created by Marco Tammaro on 09/05/24.
//

import TDLibKit
import Foundation

extension Message {
    /// A textual desctiption of the message content
    var description: AttributedString {
        var stringMessage = ""
        
        switch self.content {
        case .messageText(let message):
            return message.text.attributedString
        case .messagePhoto(_):
            stringMessage = "📷 Photo"
        case .messageLocation(_):
            stringMessage = "📍 Location"
        case .messagePoll(let message):
            return "📊 " + message.poll.question.attributedString
        case .messageDocument(let doc):
            stringMessage = "📎 \(doc.document.fileName)"
        case .messageVideo(let message):
            let caption = message.caption.text
            stringMessage = "📹 \(caption.isEmpty ? "Video" : caption)"
        case .messageVideoNote(_):
            stringMessage = "📺 Video message"
        case .messageAnimation(let message):
            let caption = message.caption.text
            stringMessage = "📹 \(caption.isEmpty ? "GIF" : caption)"
        case .messageContact(let message):
            stringMessage = "👤 \(message.contact.firstName) \(message.contact.lastName)"
        case .messageChatChangePhoto(_):
            stringMessage = "📷 Photo changed"
        case .messageChatChangeTitle(let change):
            stringMessage = change.title
        case .messageAnimatedEmoji(let data):
            stringMessage = data.emoji
        case .messageVoiceNote(_):
            stringMessage = "🎤 Voice message"
        case .messageCall(let message):
            let isVideo = message.isVideo
            stringMessage = isVideo ? "📹" : "📞" + " Call"
        case .messageSticker(let sticker):
            stringMessage = sticker.sticker.emoji
        case .messagePinMessage(_):
            stringMessage = "📌 Pinned a message"
        default:
            stringMessage = "\(self.content)"
        }
        
        return AttributedString(stringMessage)
    }
    
    var errorSending: Bool {
        
        switch self.sendingState {
        case .messageSendingStateFailed(_):
            return true
        default:
            return false
        }
        
    }
    
}
