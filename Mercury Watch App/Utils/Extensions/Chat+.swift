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
        case .chatTypeBasicGroup, .chatTypeSupergroup:
            return true
        default:
            return false
        }
    }
    
    var isChannel: Bool {
        if case .chatTypeSupergroup(let data) = self.type {
            return data.isChannel
        }
        return false
    }
    
    var isSecretChat: Bool {
        if case .chatTypeSecret = self.type { return true }
        return false
    }
    
    var isPrivate: Bool {
        if case .chatTypePrivate = self.type { return true }
        return false
    }
    
    var privateUserId: Int64? {
        switch self.type {
        case .chatTypePrivate(let data): return data.userId
        case .chatTypeSecret(let data):  return data.userId
        default: return nil
        }
    }
    
    var isArchived: Bool {
        return self.chatLists.contains(.chatListArchive)
    }
    
    func toAvatarModel(isFullScreen: Bool = false) -> AvatarModel {
        let avatarImage = photo?.getAsyncModel(highRes: isFullScreen)
        let letters = "\(self.title.prefix(1))"
        return AvatarModel(avatarImage: avatarImage, letters: letters, isFullScreen: isFullScreen)
    }
}
