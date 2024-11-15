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
            let isVideo = message.isVideo
            stringMessage = isVideo ? "📹" : "📞" + " Call"
        case .messageSticker(let sticker):
            let emoji = sticker.sticker.emoji
            stringMessage = emoji.isEmpty ? "Sticker" : emoji
        case .messagePinMessage(_):
            stringMessage = "📌 Pinned a message"
        default:
            stringMessage = "\(self)"
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
    
    func copyWith(
        authorSignature: String? = nil,
        autoDeleteIn: Double? = nil,
        canBeDeletedForAllUsers: Bool? = nil,
        canBeDeletedOnlyForSelf: Bool? = nil,
        canBeEdited: Bool? = nil,
        canBeForwarded: Bool? = nil,
        canBeRepliedInAnotherChat: Bool? = nil,
        canBeSaved: Bool? = nil,
        canGetAddedReactions: Bool? = nil,
        canGetMediaTimestampLinks: Bool? = nil,
        canGetMessageThread: Bool? = nil,
        canGetReadDate: Bool? = nil,
        canGetStatistics: Bool? = nil,
        canGetViewers: Bool? = nil,
        canReportReactions: Bool? = nil,
        chatId: Int64? = nil,
        containsUnreadMention: Bool? = nil,
        content: MessageContent? = nil,
        date: Int? = nil,
        editDate: Int? = nil,
        forwardInfo: MessageForwardInfo? = nil,
        hasTimestampedMedia: Bool? = nil,
        id: Int64? = nil,
        importInfo: MessageImportInfo? = nil,
        interactionInfo: MessageInteractionInfo? = nil,
        isChannelPost: Bool? = nil,
        isFromOffline: Bool? = nil,
        isOutgoing: Bool? = nil,
        isPinned: Bool? = nil,
        isTopicMessage: Bool? = nil,
        mediaAlbumId: TdInt64? = nil,
        messageThreadId: Int64? = nil,
        replyMarkup: ReplyMarkup? = nil,
        replyTo: MessageReplyTo? = nil,
        restrictionReason: String? = nil,
        savedMessagesTopicId: Int64? = nil,
        schedulingState: MessageSchedulingState? = nil,
        selfDestructIn: Double? = nil,
        selfDestructType: MessageSelfDestructType? = nil,
        senderBoostCount: Int? = nil,
        senderBusinessBotUserId: Int64? = nil,
        senderId: MessageSender? = nil,
        sendingState: TDLibKit.MessageSendingState? = nil,
        unreadReactions: [UnreadReaction]? = nil,
        viaBotUserId: Int64? = nil
    ) -> Message {
        return Message(
            authorSignature: authorSignature ?? self.authorSignature,
            autoDeleteIn: autoDeleteIn ?? self.autoDeleteIn,
            canBeDeletedForAllUsers: canBeDeletedForAllUsers ?? self.canBeDeletedForAllUsers,
            canBeDeletedOnlyForSelf: canBeDeletedOnlyForSelf ?? self.canBeDeletedOnlyForSelf,
            canBeEdited: canBeEdited ?? self.canBeEdited,
            canBeForwarded: canBeForwarded ?? self.canBeForwarded,
            canBeRepliedInAnotherChat: canBeRepliedInAnotherChat ?? self.canBeRepliedInAnotherChat,
            canBeSaved: canBeSaved ?? self.canBeSaved,
            canGetAddedReactions: canGetAddedReactions ?? self.canGetAddedReactions,
            canGetMediaTimestampLinks: canGetMediaTimestampLinks ?? self.canGetMediaTimestampLinks,
            canGetMessageThread: canGetMessageThread ?? self.canGetMessageThread,
            canGetReadDate: canGetReadDate ?? self.canGetReadDate,
            canGetStatistics: canGetStatistics ?? self.canGetStatistics,
            canGetViewers: canGetViewers ?? self.canGetViewers,
            canReportReactions: canReportReactions ?? self.canReportReactions,
            chatId: chatId ?? self.chatId,
            containsUnreadMention: containsUnreadMention ?? self.containsUnreadMention,
            content: content ?? self.content,
            date: date ?? self.date,
            editDate: editDate ?? self.editDate,
            forwardInfo: forwardInfo ?? self.forwardInfo,
            hasTimestampedMedia: hasTimestampedMedia ?? self.hasTimestampedMedia,
            id: id ?? self.id,
            importInfo: importInfo ?? self.importInfo,
            interactionInfo: interactionInfo ?? self.interactionInfo,
            isChannelPost: isChannelPost ?? self.isChannelPost,
            isFromOffline: isFromOffline ?? self.isFromOffline,
            isOutgoing: isOutgoing ?? self.isOutgoing,
            isPinned: isPinned ?? self.isPinned,
            isTopicMessage: isTopicMessage ?? self.isTopicMessage,
            mediaAlbumId: mediaAlbumId ?? self.mediaAlbumId,
            messageThreadId: messageThreadId ?? self.messageThreadId,
            replyMarkup: replyMarkup ?? self.replyMarkup,
            replyTo: replyTo ?? self.replyTo,
            restrictionReason: restrictionReason ?? self.restrictionReason,
            savedMessagesTopicId: savedMessagesTopicId ?? self.savedMessagesTopicId,
            schedulingState: schedulingState ?? self.schedulingState,
            selfDestructIn: selfDestructIn ?? self.selfDestructIn,
            selfDestructType: selfDestructType ?? self.selfDestructType,
            senderBoostCount: senderBoostCount ?? self.senderBoostCount,
            senderBusinessBotUserId: senderBusinessBotUserId ?? self.senderBusinessBotUserId,
            senderId: senderId ?? self.senderId,
            sendingState: sendingState ?? self.sendingState,
            unreadReactions: unreadReactions ?? self.unreadReactions,
            viaBotUserId: viaBotUserId ?? self.viaBotUserId
        )
    }
    
    
}

