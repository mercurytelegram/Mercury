//
//  User+Mock.swift
//  Mercury Watch App
//
//  Created by Alessandro Alberti on 09/07/24.
//

import TDLibKit


extension User {
    static func preview(firstName: String = "John", lastName: String = "Appleseed", usernames: [String] = ["AppleSeed"]) -> User {
        User(accentColorId: 0, addedToAttachmentMenu: false, backgroundCustomEmojiId: 0, emojiStatus: nil, firstName: firstName, hasActiveStories: false, hasUnreadActiveStories: false, haveAccess: false, id: 0, isCloseFriend: false, isContact: false, isFake: false, isMutualContact: false, isPremium: false, isScam: false, isSupport: false, isVerified: false, languageCode: "", lastName: lastName, phoneNumber: "391234567890", profileAccentColorId: 0, profileBackgroundCustomEmojiId: 0, profilePhoto: nil, restrictionReason: "", restrictsNewChats: false, status: .userStatusEmpty, type: .userTypeRegular, usernames: .init(activeUsernames: usernames, disabledUsernames: [], editableUsername: ""))
    }
}
