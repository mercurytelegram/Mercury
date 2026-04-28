//
//  PhotoManager.swift
//  Mercury Watch App
//
//  Created by Alessandro Alberti on 14/05/24.
//

import SwiftUI
import TDLibKit
import Gzip
import AVFoundation


class FileService {
    
    static let logger = LoggerService(FileService.self)
    
    static func getImage(for photo: File) async -> UIImage? {
        
        guard let imagePath = await FileService.getPath(for: photo, priority: 32) else {
            logger.log("imagePath is nil")
            return nil
        }
        
        guard let uiImage = UIImage(contentsOfFile: imagePath) else {
            logger.log("Unable to convert file to image")
            return nil
        }
        
        return uiImage
    }
    
    static func getFilePath(for file: File) async -> URL? {
        
        // Priority 16 for files (videos, voice notes) to avoid blocking UI/thumbnails
        guard let path = await FileService.getPath(for: file, priority: 16) else {
            logger.log("path is nil")
            return nil
        }
        
        return URL(fileURLWithPath: path)
    }

    static func getStreamingFilePath(
        for file: File,
        priority: Int = 32,
        minimumPrefixSize: Int64 = 512 * 1024,
        timeout: TimeInterval = 30
    ) async -> URL? {
        let startedFile: File

        if let url = await streamingURLIfReady(for: file, minimumPrefixSize: minimumPrefixSize) {
            return url
        }

        do {
            startedFile = try await TDLibManager.shared.client?.downloadFile(
                fileId: file.id,
                limit: 0,
                offset: 0,
                priority: priority,
                synchronous: false
            ) ?? file
        } catch {
            logger.log(error, level: .error)
            startedFile = file
        }

        if let url = await streamingURLIfReady(for: startedFile, minimumPrefixSize: minimumPrefixSize) {
            return url
        }

        let deadline = Date().addingTimeInterval(timeout)

        while Date() < deadline {
            do {
                try await Task.sleep(nanoseconds: 150_000_000)

                guard let currentFile = try await TDLibManager.shared.client?.getFile(fileId: file.id) else {
                    continue
                }

                if let url = await streamingURLIfReady(for: currentFile, minimumPrefixSize: minimumPrefixSize) {
                    return url
                }
            } catch is CancellationError {
                return nil
            } catch {
                logger.log(error, level: .error)
            }
        }

        logger.log("Timed out waiting for streaming file prefix", level: .error)
        return nil
    }

    private static func streamingURLIfReady(for file: File, minimumPrefixSize: Int64) async -> URL? {
        guard !file.local.path.isEmpty else { return nil }

        let fileSize = file.size > 0 ? file.size : file.expectedSize
        let requiredPrefixSize = fileSize > 0 ? min(minimumPrefixSize, fileSize) : minimumPrefixSize

        if file.local.isDownloadingCompleted {
            return URL(fileURLWithPath: file.local.path)
        }

        guard file.local.downloadedPrefixSize >= requiredPrefixSize else {
            return nil
        }

        let url = URL(fileURLWithPath: file.local.path)
        return await isPlayableMovie(at: url) ? url : nil
    }

    private static func isPlayableMovie(at url: URL) async -> Bool {
        await withCheckedContinuation { continuation in
            let asset = AVURLAsset(url: url)
            let keys = ["playable", "tracks"]

            asset.loadValuesAsynchronously(forKeys: keys) {
                var error: NSError?
                let playableStatus = asset.statusOfValue(forKey: "playable", error: &error)
                let tracksStatus = asset.statusOfValue(forKey: "tracks", error: &error)

                continuation.resume(
                    returning: playableStatus == .loaded && tracksStatus == .loaded && asset.isPlayable && !asset.tracks.isEmpty
                )
            }
        }
    }
    
    static func getPath(for file: File, priority: Int = 16) async -> String? {
        
        var filePath = file.local.path
        
        if filePath.isEmpty {
            do {
                let fileID = file.id
                guard let file = try await TDLibManager.shared.client?.downloadFile(
                    fileId: fileID,
                    limit: 0,
                    offset: 0,
                    priority: priority,
                    synchronous: true
                ) else {
                    logger.log("Unable to retrive file", level: .error)
                    return nil
                }
                
                filePath = file.local.path
                
            } catch {
                logger.log(error, level: .error)
            }
        }
        
        return filePath
    }
    
    static func getLottieJson(for tgsPath: URL) -> Data? {
        let zipPath = tgsPath.deletingPathExtension().appendingPathExtension("zip")
        
        do {
            // Change file extension
            if !FileManager.default.fileExists(atPath: zipPath.path) {
                try FileManager.default.copyItem(at: tgsPath, to: zipPath)
            }
            let sourceData = try Data(contentsOf: zipPath)
            let lottieJSONData = try sourceData.gunzipped()
            return lottieJSONData
        } catch {
            return nil
        }
    }
}
