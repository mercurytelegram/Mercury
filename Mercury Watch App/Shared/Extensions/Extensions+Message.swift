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
        case .messageVenue(let message):
            stringMessage = "📍 \(message.venue.title)"
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
            stringMessage = "📷 Changed group photo"
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
    
    func setinteractionInfo(_ info: MessageInteractionInfo?) -> Message {
        Message(
            authorSignature: self.authorSignature,
            autoDeleteIn: self.autoDeleteIn,
            canBeDeletedForAllUsers: self.canBeDeletedForAllUsers,
            canBeDeletedOnlyForSelf: self.canBeDeletedOnlyForSelf,
            canBeEdited: self.canBeEdited,
            canBeForwarded: self.canBeForwarded,
            canBeRepliedInAnotherChat: self.canBeRepliedInAnotherChat,
            canBeSaved: self.canBeSaved,
            canGetAddedReactions: self.canGetAddedReactions,
            canGetMediaTimestampLinks: self.canGetMediaTimestampLinks,
            canGetMessageThread: self.canGetMessageThread,
            canGetReadDate: self.canGetReadDate,
            canGetStatistics: self.canGetStatistics,
            canGetViewers: self.canGetViewers,
            canReportReactions: self.canReportReactions,
            chatId: self.chatId,
            containsUnreadMention: self.containsUnreadMention,
            content: self.content,
            date: self.date,
            editDate: self.editDate,
            forwardInfo: self.forwardInfo,
            hasTimestampedMedia: self.hasTimestampedMedia,
            id: self.id,
            importInfo: self.importInfo,
            interactionInfo: info,
            isChannelPost: self.isChannelPost,
            isFromOffline: self.isFromOffline,
            isOutgoing: self.isOutgoing,
            isPinned: self.isPinned,
            isTopicMessage: self.isTopicMessage,
            mediaAlbumId: self.mediaAlbumId,
            messageThreadId: self.messageThreadId,
            replyMarkup: self.replyMarkup,
            replyTo: self.replyTo,
            restrictionReason: self.restrictionReason,
            savedMessagesTopicId: self.savedMessagesTopicId,
            schedulingState: self.schedulingState,
            selfDestructIn: self.selfDestructIn,
            selfDestructType: self.selfDestructType,
            senderBoostCount: self.senderBoostCount,
            senderBusinessBotUserId: self.senderBusinessBotUserId,
            senderId: self.senderId,
            sendingState: self.sendingState,
            unreadReactions: self.unreadReactions,
            viaBotUserId: self.viaBotUserId
        )
    }
    
    
}

