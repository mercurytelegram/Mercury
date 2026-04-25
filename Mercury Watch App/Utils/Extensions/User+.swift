//
//  User+.swift
//  Mercury Watch App
//
//  Created by Alessandro Alberti on 15/07/24.
//

import SwiftUI
import TDLibKit

extension User {
    var fullName: String {
        return firstName + " " + lastName
    }
    var mainUserName: String? {
        guard let name = usernames?.activeUsernames.first else { return nil }
        return  "@" + name
    }
    
    func toAvatarModel(isFullScreen: Bool = false) -> AvatarModel {
        let firstLetter = self.firstName.prefix(1)
        let secondLetter = self.lastName.prefix(1)
        
        return AvatarModel(
            avatarImage: getAvatar(highRes: isFullScreen),
            letters: "\(firstLetter)\(secondLetter)",
            isFullScreen: isFullScreen
            
        )
    }
    
    private func getThumbnail() -> UIImage? {
        guard let data = self.profilePhoto?.minithumbnail?.data
        else { return nil }
        return UIImage(data: data)
    }
    
    private func getAvatar(highRes: Bool = false) -> AsyncImageModel {
        let thumbnail = getThumbnail() ?? UIImage()
        return AsyncImageModel(
            thumbnail: thumbnail,
            getImage: {
                guard let photo = highRes ? self.profilePhoto?.big : self.profilePhoto?.lowRes
                else { return nil }
                return await FileService.getImage(for: photo)
            }
        )
    }
    
    func toUserModel() -> UserModel {
        return UserModel(
            thumbnail: getThumbnail() ?? UIImage(),
            avatar: toAvatarModel(),
            fullName: fullName,
            mainUserName: mainUserName ?? "",
            phoneNumber: phoneNumber
        )
    }
    
    var statusDescription: String {
        switch self.status {
        case .userStatusEmpty:
            return "None"
        case .userStatusOnline(_):
            return "online"
        case .userStatusOffline(_):
            return "offline"
        case .userStatusRecently(_):
            return "last seen recently"
        case .userStatusLastWeek(_):
            return "last seen last week"
        case .userStatusLastMonth(_):
            return "last seen last month"
        }
    }
}

extension UserStatus {
    
}
