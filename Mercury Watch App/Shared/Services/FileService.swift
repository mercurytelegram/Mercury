//
//  PhotoManager.swift
//  Mercury Watch App
//
//  Created by Alessandro Alberti on 14/05/24.
//

import SwiftUI
import TDLibKit


class FileService {
    
    static func getImage(for photo: File) async -> Image? {
        let logger = LoggerService(FileService.self)
        var imagePath = photo.local.path
        
        if imagePath == "" {
            do {
                let photoID = photo.id
                guard let file = try await TDLibManager.shared.client?.downloadFile(
                    fileId: photoID,
                    limit: 0,
                    offset: 0,
                    priority: 4,
                    synchronous: true
                ) else {
                    logger.log("Unable to retrive file")
                    return nil
                }
                
                imagePath = file.local.path
                
            } catch {
                logger.log(error, level: .error)
            }
        }
        
        if let uiImage = UIImage(contentsOfFile: imagePath){
            return Image(uiImage: uiImage)
        }
        
        logger.log("Unable to convert file to image")
        return nil
    }
}
