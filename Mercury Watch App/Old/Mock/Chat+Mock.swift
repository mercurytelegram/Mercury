//
//  ChatMock.swift
//  Mercury Watch App
//
//  Created by Alessandro Alberti on 24/05/24.
//

import SwiftUI
import TDLibKit

extension Chat {
    static func preview(title: String = "Preview", lastMessage: Message = .preview(), type: ChatType = .privatePreview(), unreadCount: Int = 0) -> Chat {
        Chat(accentColorId: 0, actionBar: nil, availableReactions: .chatAvailableReactionsAll(.init(maxReactionCount: 0)), background: nil, backgroundCustomEmojiId: 0, blockList: nil, businessBotManageBar: nil, canBeDeletedForAllUsers: false, canBeDeletedOnlyForSelf: false, canBeReported: false, chatLists: [], clientData: "", defaultDisableNotification: false, draftMessage: nil, emojiStatus: nil, hasProtectedContent: false, hasScheduledMessages: false, id: Int64.random(in: 0...100), isMarkedAsUnread: false, isTranslatable: false, lastMessage: lastMessage, lastReadInboxMessageId: 0, lastReadOutboxMessageId: 0, messageAutoDeleteTime: 0, messageSenderId: nil, notificationSettings: .preview(), pendingJoinRequests: nil, permissions: .preview(), photo: nil, positions: [], profileAccentColorId: 0, profileBackgroundCustomEmojiId: 0, replyMarkupMessageId: 0, themeName: "", title: title, type: .chatTypePrivate(ChatTypePrivate(userId: 0)), unreadCount: unreadCount, unreadMentionCount: 0, unreadReactionCount: 0, videoChat: .preview(), viewAsTopics: false)
    }
}

extension VideoChat {
    static func preview() -> VideoChat {
        VideoChat(defaultParticipantId: nil, groupCallId: 0, hasParticipants: false)
    }
}

extension ChatPermissions {
    static func preview() -> ChatPermissions {
        ChatPermissions(canAddWebPagePreviews: false, canChangeInfo: false, canCreateTopics: false, canInviteUsers: false, canPinMessages: false, canSendAudios: false, canSendBasicMessages: false, canSendDocuments: false, canSendOtherMessages: false, canSendPhotos: false, canSendPolls: false, canSendVideoNotes: false, canSendVideos: false, canSendVoiceNotes: false)
    }
}

extension ChatNotificationSettings {
    static func preview() -> ChatNotificationSettings {
        ChatNotificationSettings(disableMentionNotifications: false, disablePinnedMessageNotifications: false, muteFor: 0, muteStories: false, showPreview: false, showStorySender: false, soundId: 0, storySoundId: 0, useDefaultDisableMentionNotifications: false, useDefaultDisablePinnedMessageNotifications: false, useDefaultMuteFor: false, useDefaultMuteStories: false, useDefaultShowPreview: false, useDefaultShowStorySender: false, useDefaultSound: false, useDefaultStorySound: false)
    }
}

extension ChatType {
    static func privatePreview() -> ChatType {
        .chatTypePrivate(ChatTypePrivate(userId: 0))
    }
    
    static func groupPreview() -> ChatType {
        .chatTypeBasicGroup(ChatTypeBasicGroup(basicGroupId: 0))
    }
}
