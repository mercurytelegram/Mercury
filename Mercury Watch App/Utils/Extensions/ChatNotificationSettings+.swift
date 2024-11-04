//
//  ChatNotificationSettings+.swift
//  Mercury Watch App
//
//  Created by Marco Tammaro on 04/11/24.
//

import TDLibKit

extension ChatNotificationSettings {
    public func copyWith(
            disableMentionNotifications: Bool? = nil,
            disablePinnedMessageNotifications: Bool? = nil,
            muteFor: Int? = nil,
            muteStories: Bool? = nil,
            showPreview: Bool? = nil,
            showStorySender: Bool? = nil,
            soundId: TdInt64? = nil,
            storySoundId: TdInt64? = nil,
            useDefaultDisableMentionNotifications: Bool? = nil,
            useDefaultDisablePinnedMessageNotifications: Bool? = nil,
            useDefaultMuteFor: Bool? = nil,
            useDefaultMuteStories: Bool? = nil,
            useDefaultShowPreview: Bool? = nil,
            useDefaultShowStorySender: Bool? = nil,
            useDefaultSound: Bool? = nil,
            useDefaultStorySound: Bool? = nil
        ) -> ChatNotificationSettings {
            return ChatNotificationSettings(
                disableMentionNotifications: disableMentionNotifications ?? self.disableMentionNotifications,
                disablePinnedMessageNotifications: disablePinnedMessageNotifications ?? self.disablePinnedMessageNotifications,
                muteFor: muteFor ?? self.muteFor,
                muteStories: muteStories ?? self.muteStories,
                showPreview: showPreview ?? self.showPreview,
                showStorySender: showStorySender ?? self.showStorySender,
                soundId: soundId ?? self.soundId,
                storySoundId: storySoundId ?? self.storySoundId,
                useDefaultDisableMentionNotifications: useDefaultDisableMentionNotifications ?? self.useDefaultDisableMentionNotifications,
                useDefaultDisablePinnedMessageNotifications: useDefaultDisablePinnedMessageNotifications ?? self.useDefaultDisablePinnedMessageNotifications,
                useDefaultMuteFor: useDefaultMuteFor ?? self.useDefaultMuteFor,
                useDefaultMuteStories: useDefaultMuteStories ?? self.useDefaultMuteStories,
                useDefaultShowPreview: useDefaultShowPreview ?? self.useDefaultShowPreview,
                useDefaultShowStorySender: useDefaultShowStorySender ?? self.useDefaultShowStorySender,
                useDefaultSound: useDefaultSound ?? self.useDefaultSound,
                useDefaultStorySound: useDefaultStorySound ?? self.useDefaultStorySound
            )
        }
}
