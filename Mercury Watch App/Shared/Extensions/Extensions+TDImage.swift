//
//  Extensions+TDImage.swift
//  Mercury Watch App
//
//  Created by Alessandro Alberti on 16/07/24.
//

import TDLibKit

protocol TDImage {
    var minithumbnail: Minithumbnail? { get }
    var lowRes: File? { get }
    var highRes: File? { get }
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


