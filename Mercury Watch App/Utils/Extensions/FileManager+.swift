//
//  FileManager+.swift
//  Mercury
//
//  Created by Marco Tammaro on 25/10/24.
//

import Foundation

extension FileManager {
    
    var tmpFolder: URL {
        
        let tmpDir = FileManager.default.temporaryDirectory
        
        if !FileManager.default.fileExists(atPath: tmpDir.path) {
            do {
                try FileManager.default.createDirectory(
                    atPath: tmpDir.path,
                    withIntermediateDirectories: true,
                    attributes: nil
                )
            } catch {
                print(error.localizedDescription)
            }
        }
        
        return tmpDir
        
    }
    
}
