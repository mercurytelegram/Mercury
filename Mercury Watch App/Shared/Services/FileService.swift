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
        
        guard let imagePath = await FileService.getFile(for: photo) else {
            print("[CLIENT] [\(type(of: self))] \(#function) imagePath is nil")
            return nil
        }
        
        guard let uiImage = UIImage(contentsOfFile: imagePath.absoluteString) else {
            print("[CLIENT] [\(type(of: self))] \(#function) uiImage is nil")
            return nil
        }
        
        return Image(uiImage: uiImage)
    }
    
    static func getFile(for file: File) async -> URL? {
        var filePath = file.local.path
        
        if filePath.isEmpty {
            do {
                let fileID = file.id
                guard let file = try await TDLibManager.shared.client?.downloadFile(
                    fileId: fileID,
                    limit: 0,
                    offset: 0,
                    priority: 4,
                    synchronous: true
                ) else { return nil }
                
                filePath = file.local.path
                
            } catch {
                print("[CLIENT] [\(type(of: self))] error in \(#function): \(error)")
            }
        }
        
        return URL(string: filePath)
    }
}
