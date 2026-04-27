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
            showStoryPoster: Bool? = nil,
            soundId: TdInt64? = nil,
            storySoundId: TdInt64? = nil,
            useDefaultDisableMentionNotifications: Bool? = nil,
            useDefaultDisablePinnedMessageNotifications: Bool? = nil,
            useDefaultMuteFor: Bool? = nil,
            useDefaultMuteStories: Bool? = nil,
            useDefaultShowPreview: Bool? = nil,
            useDefaultShowStoryPoster: Bool? = nil,
            useDefaultSound: Bool? = nil,
            useDefaultStorySound: Bool? = nil
        ) -> ChatNotificationSettings {
            let newDisableMention = disableMentionNotifications ?? self.disableMentionNotifications
            let newDisablePinned = disablePinnedMessageNotifications ?? self.disablePinnedMessageNotifications
            let newMuteFor = muteFor ?? self.muteFor
            let newMuteStories = muteStories ?? self.muteStories
            let newShowPreview = showPreview ?? self.showPreview
            let newShowStoryPoster = showStoryPoster ?? self.showStoryPoster
            let newSoundId = soundId ?? self.soundId
            let newStorySoundId = storySoundId ?? self.storySoundId
            let newUseDefaultDisableMention = useDefaultDisableMentionNotifications ?? self.useDefaultDisableMentionNotifications
            let newUseDefaultDisablePinned = useDefaultDisablePinnedMessageNotifications ?? self.useDefaultDisablePinnedMessageNotifications
            let newUseDefaultMuteFor = useDefaultMuteFor ?? self.useDefaultMuteFor
            let newUseDefaultMuteStories = useDefaultMuteStories ?? self.useDefaultMuteStories
            let newUseDefaultShowPreview = useDefaultShowPreview ?? self.useDefaultShowPreview
            let newUseDefaultShowStoryPoster = useDefaultShowStoryPoster ?? self.useDefaultShowStoryPoster
            let newUseDefaultSound = useDefaultSound ?? self.useDefaultSound
            let newUseDefaultStorySound = useDefaultStorySound ?? self.useDefaultStorySound

            return ChatNotificationSettings(
                disableMentionNotifications: newDisableMention,
                disablePinnedMessageNotifications: newDisablePinned,
                muteFor: newMuteFor,
                muteStories: newMuteStories,
                showPreview: newShowPreview,
                showStoryPoster: newShowStoryPoster,
                soundId: newSoundId,
                storySoundId: newStorySoundId,
                useDefaultDisableMentionNotifications: newUseDefaultDisableMention,
                useDefaultDisablePinnedMessageNotifications: newUseDefaultDisablePinned,
                useDefaultMuteFor: newUseDefaultMuteFor,
                useDefaultMuteStories: newUseDefaultMuteStories,
                useDefaultShowPreview: newUseDefaultShowPreview,
                useDefaultShowStoryPoster: newUseDefaultShowStoryPoster,
                useDefaultSound: newUseDefaultSound,
                useDefaultStorySound: newUseDefaultStorySound
            )
        }
    }
