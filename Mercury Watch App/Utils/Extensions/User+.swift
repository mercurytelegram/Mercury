//
//  User+.swift
//  Mercury Watch App
//
//  Created by Alessandro Alberti on 15/07/24.
//

import Foundation
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
            tdImage: self.profilePhoto,
            letters: "\(firstLetter)\(secondLetter)"
        )
    }
}
