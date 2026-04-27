//
//  Message+.swift
//  Mercury Watch App
//
//  Created by Marco Tammaro on 09/05/24.
//

import TDLibKit
import Foundation

extension MessageContent {
    /// A textual desctiption of the message content
    var description: AttributedString {
        var stringMessage = ""
        
        switch self {
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
            stringMessage = message.isVideo ? "📹 Video call" : "📞 Call"
        case .messageSticker(let sticker):
            let emoji = sticker.sticker.emoji
            stringMessage = emoji.isEmpty ? "Sticker" : emoji
        case .messagePinMessage(_):
            stringMessage = "📌 Pinned a message"
        case .messageAudio(let message):
            let title = message.audio.title
            stringMessage = "🎵 \(title.isEmpty ? "Audio" : title)"
        case .messageChatAddMembers(_):
            stringMessage = "👥 joined the group"
        case .messageChatJoinByLink:
            stringMessage = "👥 joined by invite link"
        case .messageChatDeleteMember(_):
            stringMessage = "👤 left the group"
        case .messageForumTopicCreated(let msg):
            stringMessage = "Created topic \"\(msg.name)\""
        case .messageForumTopicEdited(_):
            stringMessage = "Edited topic"
        case .messageForumTopicIsClosedToggled(_):
            stringMessage = "Toggled topic closed state"
        case .messageForumTopicIsHiddenToggled(_):
            stringMessage = "Toggled topic visibility"
        case .messageChatUpgradeFrom(_):
            stringMessage = "Upgraded to supergroup"
        case .messageChatUpgradeTo(_):
            stringMessage = "Upgraded to supergroup"
        case .messageSupergroupChatCreate(_):
            stringMessage = "Created supergroup"
        case .messageBasicGroupChatCreate(_):
            stringMessage = "Created group"
        case .messageVideoChatScheduled(_):
            stringMessage = "📅 Scheduled a video chat"
        case .messageVideoChatStarted(_):
            stringMessage = "📹 Video chat started"
        case .messageVideoChatEnded(_):
            stringMessage = "📹 Video chat ended"
        case .messageInviteVideoChatParticipants(_):
            stringMessage = "📹 Invited to video chat"
        case .messageGiftedPremium(_):
            stringMessage = "🎁 Gifted Telegram Premium"
        case .messageChatSetMessageAutoDeleteTime(_):
            stringMessage = "⏱ Auto-delete timer changed"
        case .messageContactRegistered:
            stringMessage = "👤 Joined Telegram"
        case .messageScreenshotTaken:
            stringMessage = "📸 Screenshot taken"
        case .messageChatBoost(_):
            stringMessage = "🚀 Boosted the channel"
        case .messageUnsupported:
            stringMessage = "Unsupported message"
        default:
            stringMessage = "Unsupported message"
        }
        
        return AttributedString(stringMessage)
    }
}

extension Message {
    var description: AttributedString {
        self.content.description
    }
    
    var senderID: Int64 {
        switch senderId {
        case .messageSenderUser(let messageSenderUser):
            messageSenderUser.userId
        case .messageSenderChat(let messageSenderChat):
           messageSenderChat.chatId
        }
    }
    
    var errorSending: Bool {
        
        switch self.sendingState {
        case .messageSendingStateFailed(_):
            return true
        default:
            return false
        }
        
    }
    
    func setVoiceNoteListened() -> Message {
        
        var newVoiceNote: MessageVoiceNote
        if case .messageVoiceNote(let voiceNote) = content {
            newVoiceNote = MessageVoiceNote(caption: voiceNote.caption, isListened: true, voiceNote: voiceNote.voiceNote)
        } else {
            return self
        }
        let newContent = MessageContent.messageVoiceNote(newVoiceNote)
        return self.copyWith(content: newContent)
    }
    
    func copyWith(content: MessageContent) -> Message {
        return Message(
            authorSignature: self.authorSignature,
            autoDeleteIn: self.autoDeleteIn,
            canBeSaved: self.canBeSaved,
            chatId: self.chatId,
            containsUnreadMention: self.containsUnreadMention,
            content: content,
            date: self.date,
            editDate: self.editDate,
            effectId: self.effectId,
            factCheck: self.factCheck,
            forwardInfo: self.forwardInfo,
            hasTimestampedMedia: self.hasTimestampedMedia,
            id: self.id,
            importInfo: self.importInfo,
            interactionInfo: self.interactionInfo,
            isChannelPost: self.isChannelPost,
            isFromOffline: self.isFromOffline,
            isOutgoing: self.isOutgoing,
            isPaidStarSuggestedPost: self.isPaidStarSuggestedPost,
            isPaidTonSuggestedPost: self.isPaidTonSuggestedPost,
            isPinned: self.isPinned,
            mediaAlbumId: self.mediaAlbumId,
            paidMessageStarCount: self.paidMessageStarCount,
            replyMarkup: self.replyMarkup,
            replyTo: self.replyTo,
            restrictionInfo: self.restrictionInfo,
            schedulingState: self.schedulingState,
            selfDestructIn: self.selfDestructIn,
            selfDestructType: self.selfDestructType,
            senderBoostCount: self.senderBoostCount,
            senderBusinessBotUserId: self.senderBusinessBotUserId,
            senderId: self.senderId,
            senderTag: self.senderTag,
            sendingState: self.sendingState,
            suggestedPostInfo: self.suggestedPostInfo,
            summaryLanguageCode: self.summaryLanguageCode,
            topicId: self.topicId,
            unreadReactions: self.unreadReactions,
            viaBotUserId: self.viaBotUserId
        )
    }
}
