//
//  User+Mock.swift
//  Mercury Watch App
//
//  Created by Alessandro Alberti on 09/07/24.
//

import TDLibKit
import UIKit


extension User {
    static func preview(firstName: String = "John", lastName: String = "Appleseed", usernames: [String] = ["AppleSeed"], profilePhoto: String = "alessandro") -> User {
        User(accentColorId: 0, addedToAttachmentMenu: false, backgroundCustomEmojiId: 0, emojiStatus: nil, firstName: firstName, hasActiveStories: false, hasUnreadActiveStories: false, haveAccess: false, id: 0, isCloseFriend: false, isContact: false, isFake: false, isMutualContact: false, isPremium: false, isScam: false, isSupport: false, isVerified: false, languageCode: "", lastName: lastName, phoneNumber: "391234567890", profileAccentColorId: 0, profileBackgroundCustomEmojiId: 0, profilePhoto: .preview(profilePhoto), restrictionReason: "", restrictsNewChats: false, status: .userStatusEmpty, type: .userTypeRegular, usernames: .init(activeUsernames: usernames, disabledUsernames: [], editableUsername: ""))
    }
}

extension ProfilePhoto {
    static func preview(_ imageName: String) -> ProfilePhoto {
        .init(big: .empty, hasAnimation: false, id: 0, isPersonal: true, minithumbnail: .preview(imageName), small: .empty)
    }
}

