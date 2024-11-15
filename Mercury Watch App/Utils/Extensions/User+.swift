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
    
    private func getAvatar() -> AsyncImageModel {
        var thumbnail: UIImage? = nil
        if let data = self.profilePhoto?.minithumbnail?.data {
            thumbnail = UIImage(data: data)
        }
        return AsyncImageModel(
            thumbnail: thumbnail,
            getImage: {
                guard let photo = self.profilePhoto?.lowRes
                else { return nil }
                return await FileService.getImage(for: photo)
            }
        )
    }
}
