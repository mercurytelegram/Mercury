//
//  Chat+.swift
//  Mercury Watch App
//
//  Created by Marco Tammaro on 29/05/24.
//

import SwiftUI
import TDLibKit

extension Chat {
    
    var isGroup: Bool {
        switch self.type {
        case .chatTypeBasicGroup(_), .chatTypeSupergroup(_):
            return true
        
        default:
            return false
        }
    }
    
    var isArchived: Bool {
        return self.chatLists.contains(.chatListArchive)
    }
    
    func toAvatarModel() -> AvatarModel {
        let avatarImage = photo?.getAsyncModel()
        let letters = "\(self.title.prefix(1))"
        
        return AvatarModel(avatarImage: avatarImage, letters: letters)
    }
    
}
