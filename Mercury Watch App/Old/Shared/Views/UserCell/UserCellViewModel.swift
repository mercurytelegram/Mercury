//
//  UserCellViewModel.swift
//  Mercury Watch App
//
//  Created by Alessandro Alberti on 10/25/24.
//

import TDLibKit
import SwiftUI

class UserCellViewModel {
    var user: User?
    
    init(user: User? = nil) {
        self.user = user
    }
    
    var fullName: String {
        let firstName = user?.firstName ?? "PlaceHolder"
        let lastName = user?.lastName ?? "PlaceHolder"
        
        return firstName + " " + lastName
    }
    
    var nameLetters: String {
        let firstLetter = user?.firstName.prefix(1) ?? "P"
        let secondLetter = user?.lastName.prefix(1) ?? "P"
        
        return "\(firstLetter)\(secondLetter)"
    }
    
    var redaction: RedactionReasons {
        user == nil ? .placeholder : []
    }
    
    var avatarModel: AvatarModel_Old {
        return AvatarModel_Old(tdImage: user?.profilePhoto, letters: nameLetters)
    }
}
