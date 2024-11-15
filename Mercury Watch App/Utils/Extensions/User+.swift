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
    
    func toAvatarModel() -> AvatarModel {
        let firstLetter = self.firstName.prefix(1)
        let secondLetter = self.lastName.prefix(1)
        
        return AvatarModel(
            avatarImage: getAvatar(),
            letters: "\(firstLetter)\(secondLetter)"
        )
    }
    
    private func getThumbnail() -> UIImage? {
        guard let data = self.profilePhoto?.minithumbnail?.data
        else { return nil }
        return UIImage(data: data)
    }
    
    private func getAvatar() -> AsyncImageModel {
        let thumbnail = getThumbnail() ?? UIImage()
        return AsyncImageModel(
            thumbnail: thumbnail,
            getImage: {
                guard let photo = self.profilePhoto?.lowRes
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
}
