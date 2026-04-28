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
            let text = message.text.attributedString
            return text.isBlank ? "📊 Poll" : text
        case .messagePhoto(_):
            stringMessage = "📷 Photo"
        case .messageLocation(_):
            stringMessage = "📍 Location"
        case .messageVenue(let message):
            stringMessage = "📍 \(message.venue.title)"
        case .messagePoll(let message):
            return message.previewText
        case .messagePollOptionAdded(let message):
            return "📊 Added option: " + message.text.attributedString
        case .messagePollOptionDeleted(let message):
            return "📊 Removed option: " + message.text.attributedString
        case .messageDocument(let doc):
            stringMessage = "📎 \(doc.document.fileName)"
        case .messagePaidMedia(let message):
            let caption = message.caption.text
            stringMessage = "⭐️ \(caption.isEmpty ? "Paid media" : caption)"
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
        case .messageDice(let message):
            stringMessage = "\(message.emoji) \(message.value)"
        case .messageGame(_):
            stringMessage = "🎮 Game"
        case .messageStakeDice(let message):
            stringMessage = "🎲 \(message.value)"
        case .messageStory(_):
            stringMessage = "Story"
        case .messageChecklist(_):
            stringMessage = "Checklist"
        case .messageInvoice(_):
            stringMessage = "Invoice"
        case .messageVoiceNote(_):
            stringMessage = "🎤 Voice message"
        case .messageCall(let message):
            stringMessage = message.isVideo ? "📹 Video call" : "📞 Call"
        case .messageGroupCall(_):
            stringMessage = "Group call"
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
        case .messageChatDeletePhoto:
            stringMessage = "Deleted group photo"
        case .messageChatOwnerLeft(_):
            stringMessage = "Left ownership of the chat"
        case .messageChatOwnerChanged(_):
            stringMessage = "Changed chat owner"
        case .messageChatHasProtectedContentToggled(let message):
            stringMessage = message.newHasProtectedContent ? "Enabled protected content" : "Disabled protected content"
        case .messageChatHasProtectedContentDisableRequested(let message):
            stringMessage = message.isExpired ? "Protected content request expired" : "Requested to disable protected content"
        case .messageChatJoinByRequest:
            stringMessage = "👥 joined by request"
        case .messageForumTopicCreated(let msg):
            stringMessage = "Created topic \"\(msg.name)\""
        case .messageForumTopicEdited(let message):
            stringMessage = message.name.isEmpty ? "Edited topic" : "Renamed topic to \"\(message.name)\""
        case .messageForumTopicIsClosedToggled(let message):
            stringMessage = message.isClosed ? "Closed topic" : "Reopened topic"
        case .messageForumTopicIsHiddenToggled(let message):
            stringMessage = message.isHidden ? "Hid General topic" : "Unhid General topic"
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
        case .messagePremiumGiftCode(_):
            stringMessage = "🎁 Premium gift code"
        case .messageGiveawayCreated(_):
            stringMessage = "🎁 Giveaway created"
        case .messageGiveaway(_):
            stringMessage = "🎁 Giveaway"
        case .messageGiveawayCompleted(_):
            stringMessage = "🎁 Giveaway completed"
        case .messageGiveawayWinners(_):
            stringMessage = "🎁 Giveaway winners"
        case .messageGiftedStars(_):
            stringMessage = "⭐️ Gifted Telegram Stars"
        case .messageGiftedTon(_):
            stringMessage = "💎 Gifted TON"
        case .messageGiveawayPrizeStars(_):
            stringMessage = "⭐️ Giveaway prize Stars"
        case .messageGift(_):
            stringMessage = "🎁 Gift"
        case .messageUpgradedGift(_):
            stringMessage = "🎁 Upgraded gift"
        case .messageRefundedUpgradedGift(_):
            stringMessage = "🎁 Refunded upgraded gift"
        case .messageUpgradedGiftPurchaseOffer(_):
            stringMessage = "🎁 Gift purchase offer"
        case .messageUpgradedGiftPurchaseOfferRejected(_):
            stringMessage = "🎁 Gift purchase offer rejected"
        case .messagePaidMessagesRefunded(_):
            stringMessage = "Paid messages refunded"
        case .messagePaidMessagePriceChanged(_):
            stringMessage = "Paid message price changed"
        case .messageDirectMessagePriceChanged(_):
            stringMessage = "Direct message price changed"
        case .messageChecklistTasksDone(_):
            stringMessage = "Checklist tasks completed"
        case .messageChecklistTasksAdded(_):
            stringMessage = "Checklist tasks added"
        case .messageSuggestedPostApprovalFailed(_):
            stringMessage = "Suggested post approval failed"
        case .messageSuggestedPostApproved(_):
            stringMessage = "Suggested post approved"
        case .messageSuggestedPostDeclined(_):
            stringMessage = "Suggested post declined"
        case .messageSuggestedPostPaid(_):
            stringMessage = "Suggested post paid"
        case .messageSuggestedPostRefunded(_):
            stringMessage = "Suggested post refunded"
        case .messageChatSetMessageAutoDeleteTime(_):
            stringMessage = "⏱ Auto-delete timer changed"
        case .messageContactRegistered:
            stringMessage = "👤 Joined Telegram"
        case .messageScreenshotTaken:
            stringMessage = "📸 Screenshot taken"
        case .messageChatBoost(_):
            stringMessage = "🚀 Boosted the channel"
        case .messageChatSetBackground(_):
            stringMessage = "Changed chat background"
        case .messageChatSetTheme(let message):
            stringMessage = message.theme == nil ? "Reset chat theme" : "Changed chat theme"
        case .messageSuggestProfilePhoto(_):
            stringMessage = "Suggested profile photo"
        case .messageSuggestBirthdate(_):
            stringMessage = "Suggested birthdate"
        case .messageCustomServiceAction(let message):
            stringMessage = message.text
        case .messageGameScore(let message):
            stringMessage = "Scored \(message.score) in a game"
        case .messageManagedBotCreated(_):
            stringMessage = "Managed bot created"
        case .messagePaymentSuccessful(_):
            stringMessage = "Payment completed"
        case .messagePaymentSuccessfulBot(_):
            stringMessage = "Payment received"
        case .messagePaymentRefunded(_):
            stringMessage = "Payment refunded"
        case .messageUsersShared(_):
            stringMessage = "Users shared"
        case .messageChatShared(_):
            stringMessage = "Chat shared"
        case .messageBotWriteAccessAllowed(_):
            stringMessage = "Bot write access allowed"
        case .messageWebAppDataSent(_):
            stringMessage = "Web app data sent"
        case .messageWebAppDataReceived(_):
            stringMessage = "Web app data received"
        case .messagePassportDataSent(_):
            stringMessage = "Telegram Passport data sent"
        case .messagePassportDataReceived(_):
            stringMessage = "Telegram Passport data received"
        case .messageProximityAlertTriggered(_):
            stringMessage = "Proximity alert triggered"
        case .messageExpiredPhoto:
            stringMessage = "Expired photo"
        case .messageExpiredVideo:
            stringMessage = "Expired video"
        case .messageExpiredVideoNote:
            stringMessage = "Expired video message"
        case .messageExpiredVoiceNote:
            stringMessage = "Expired voice message"
        case .messageUnsupported:
            stringMessage = "Unsupported message"
        default:
            stringMessage = "Unsupported message"
        }
        
        return AttributedString(stringMessage)
    }
}

private extension AttributedString {
    var isBlank: Bool {
        String(characters).trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
}

extension MessagePoll {
    var previewText: AttributedString {
        let question = poll.question.attributedString
        if !question.characters.isEmpty {
            return "📊 " + question
        }

        let description = description.attributedString
        if !description.characters.isEmpty {
            return "📊 " + description
        }

        return "📊 Poll"
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
