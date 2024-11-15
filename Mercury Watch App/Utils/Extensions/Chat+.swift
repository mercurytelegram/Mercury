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
        var thumbnail: UIImage? = nil
        if let data = self.photo?.minithumbnail?.data {
            thumbnail = UIImage(data: data)
        }
        
        let photo = AsyncImageModel(
            thumbnail: thumbnail,
            getImage: {
                guard let photo = self.photo?.lowRes
                else { return nil }
                return await FileService.getImage(for: photo)
            }
        )
        
        let letters: String = "\(self.title.prefix(1))"
        
        return AvatarModel(avatarImage: photo, letters: letters)
    }
    
}
