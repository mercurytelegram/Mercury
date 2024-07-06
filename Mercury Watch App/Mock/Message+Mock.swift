//
//  MessageMock.swift
//  Mercury Watch App
//
//  Created by Alessandro Alberti on 24/05/24.
//

import SwiftUI
import TDLibKit

extension Message {
    static func preview(content: MessageContent = .text("Hello"), reaction: MessageInteractionInfo = .preview(), isOutgoing: Bool = false) -> Message {
        Message(authorSignature: "", autoDeleteIn: 0, canBeDeletedForAllUsers: true, canBeDeletedOnlyForSelf: true, canBeEdited: true, canBeForwarded: true, canBeRepliedInAnotherChat: true, canBeSaved: true, canGetAddedReactions: true, canGetMediaTimestampLinks: true, canGetMessageThread: true, canGetReadDate: true, canGetStatistics: true, canGetViewers: true, canReportReactions: true, chatId: 0, containsUnreadMention: true, content: content, date: 0, editDate: 0, effectId: 0, factCheck: nil, forwardInfo: nil, hasTimestampedMedia: false, id: Int64.random(in: 0...100), importInfo: nil, interactionInfo: reaction, isChannelPost: false, isFromOffline: false, isOutgoing: isOutgoing, isPinned: false, isTopicMessage: false, mediaAlbumId: 0, messageThreadId: 0, replyMarkup: nil, replyTo: nil, restrictionReason: "", savedMessagesTopicId: 0, schedulingState: nil, selfDestructIn: 0, selfDestructType: nil, senderBoostCount: 0, senderBusinessBotUserId: 0, senderId: .user(), sendingState: nil, unreadReactions: [], viaBotUserId: 0)
    }
}

extension MessageContent {
    static func text(_ text: String) -> MessageContent {
        MessageContent.messageText(MessageText(linkPreviewOptions: nil, text: FormattedText(entities: [], text: text), webPage: nil))
    }
}

extension MessageSender {
    static func user(id: Int64 = 0) -> MessageSender {
        MessageSender.messageSenderUser(MessageSenderUser(userId: id))
    }
}

extension MessageInteractionInfo {
    static func preview() -> MessageInteractionInfo {
        MessageInteractionInfo(forwardCount: 0, reactions: MessageReactions(areTags: false, reactions: [MessageReaction(isChosen: false, recentSenderIds: [], totalCount: 1, type: ReactionType.reactionTypeEmoji(ReactionTypeEmoji(emoji: "🔥")), usedSenderId: nil)]), replyInfo: nil, viewCount: 1)
    }
}
