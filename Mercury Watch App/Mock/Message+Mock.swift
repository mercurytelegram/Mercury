//
//  MessageMock.swift
//  Mercury Watch App
//
//  Created by Alessandro Alberti on 24/05/24.
//

import SwiftUI
import TDLibKit

extension Message {
    static func preview(content: MessageContent = .text("Hello"), reaction: MessageInteractionInfo? = .preview(), isOutgoing: Bool = false) -> Message {
        Message(authorSignature: "", autoDeleteIn: 0, canBeDeletedForAllUsers: true, canBeDeletedOnlyForSelf: true, canBeEdited: true, canBeForwarded: true, canBeRepliedInAnotherChat: true, canBeSaved: true, canGetAddedReactions: true, canGetMediaTimestampLinks: true, canGetMessageThread: true, canGetReadDate: true, canGetStatistics: true, canGetViewers: true, canReportReactions: true, chatId: 0, containsUnreadMention: true, content: content, date: 1724291340, editDate: 0, forwardInfo: nil, hasTimestampedMedia: false, id: Int64.random(in: 0...100), importInfo: nil, interactionInfo: reaction, isChannelPost: false, isFromOffline: false, isOutgoing: isOutgoing, isPinned: false, isTopicMessage: false, mediaAlbumId: 0, messageThreadId: 0, replyMarkup: nil, replyTo: nil, restrictionReason: "", savedMessagesTopicId: 0, schedulingState: nil, selfDestructIn: 0, selfDestructType: nil, senderBoostCount: 0, senderBusinessBotUserId: 0, senderId: .user(), sendingState: nil, unreadReactions: [], viaBotUserId: 0)
    }
}

extension MessageContent {
    static func text(_ text: String) -> MessageContent {
        MessageContent.messageText(MessageText(linkPreviewOptions: nil, text: FormattedText(entities: [], text: text), webPage: nil))
    }
    
    static func location(_ latitude: Double = 37.33187132756376, _ longitude: Double = -122.02965972794414) -> MessageContent {
        MessageContent.messageLocation(MessageLocation(expiresIn: 0, heading: 0, livePeriod: 0, location: Location(horizontalAccuracy: 0, latitude: latitude, longitude: longitude), proximityAlertRadius: 0))
    }
}

extension MessageSender {
    static func user(id: Int64 = 0) -> MessageSender {
        MessageSender.messageSenderUser(MessageSenderUser(userId: id))
    }
}

extension MessageInteractionInfo {
    static func preview(emoji: String = "🔥", count: Int = 1) -> MessageInteractionInfo {
        MessageInteractionInfo(forwardCount: 0, reactions: MessageReactions(areTags: false, reactions: [MessageReaction(isChosen: false, recentSenderIds: [], totalCount: count, type: ReactionType.reactionTypeEmoji(ReactionTypeEmoji(emoji: emoji)), usedSenderId: nil)]), replyInfo: nil, viewCount: count)
    }
}
