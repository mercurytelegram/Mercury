//
//  AvatarModel.swift
//  Mercury Watch App
//
//  Created by Alessandro Alberti on 14/05/24.
//

import SwiftUI
import TDLibKit

struct AvatarModel {
    var tdPhoto: TDImage?
    var letters: String = ""
    var color: Color = .blue
    var isOnline: Bool = false
}


extension ChatPhotoInfo: TDImage {}
extension ProfilePhoto: TDImage {}

protocol TDImage {
    var minithumbnail: Minithumbnail? { get }
    var small: File { get }
}
