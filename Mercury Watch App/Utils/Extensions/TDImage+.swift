//
//  TDImage+.swift
//  Mercury Watch App
//
//  Created by Alessandro Alberti on 16/07/24.
//

import TDLibKit
import UIKit

protocol TDImage {
    var minithumbnail: Minithumbnail? { get }
    var lowRes: File? { get }
    var highRes: File? { get }
}

extension TDImage {
    func getAsyncModel() -> AsyncImageModel {
        var thumbnail: UIImage? = nil
        if let data = self.minithumbnail?.data {
            thumbnail = UIImage(data: data)
        }
        
        return AsyncImageModel(
            thumbnail: thumbnail,
            getImage: {
                guard let photo = self.lowRes
                else { return nil }
                return await FileService.getImage(for: photo)
            }
        )
    }
}

extension ChatPhotoInfo: TDImage {
    var lowRes: File? {
        return small
    }
    var highRes: File? {
        return big
    }
}
extension ProfilePhoto: TDImage {
    var lowRes: File? {
        return small
    }
    var highRes: File? {
        return big
    }
}

extension Photo: TDImage {
    var lowRes: File? {
        return sizes.first?.photo
    }
    
    var highRes: File? {
        return sizes.last?.photo
    }
}

extension Video: TDImage {
    var lowRes: File? {
        return thumbnail?.file
    }
    
    var highRes: File? {
        return nil
    }
}

extension ChatPhoto: TDImage {
    var lowRes: File? {
        self.sizes.isEmpty ? nil :  self.sizes[0].photo
    }
    
    var highRes: File? {
        return nil
    }
}


