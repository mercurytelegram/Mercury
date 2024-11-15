//
//  TDImageMock.swift
//  Mercury
//
//  Created by Marco Tammaro on 15/11/24.
//

import SwiftUI
import TDLibKit

struct TDImageMock: TDImage {
    var minithumbnail: Minithumbnail?
    var lowRes: File?
    var highRes: File?
    
    init(_ imageName: String) {
        minithumbnail = .preview(imageName)
    }
}

extension Minithumbnail {
    static func preview(_ imageName: String) -> Minithumbnail {
        if let image = UIImage(named: imageName), let data = image.jpegData(compressionQuality: 1.0) {
            return Minithumbnail(data: data, height: 0, width: 0)
        }
        return Minithumbnail(data: Data(), height: 0, width: 0)
    }
}
