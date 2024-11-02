//
//  PreviewTDImage.swift
//  Mercury Watch App
//
//  Created by Alessandro Alberti on 21/08/24.
//

import TDLibKit
import UIKit

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
