//
//  PlayingViewModel.swift
//  Mercury Watch App
//
//  Created by Marco Tammaro on 27/06/24.
//

import Foundation
import SwiftUI
import AVFoundation
import SwiftOGG

class PlayerService_Old: NSObject, ObservableObject {
    
    static let updateInterval: Double = 0.20
    
    @Published var elapsedTime: TimeInterval = .zero
    
    private var audioPlayer: AVAudioPlayer?
    private let logger = LoggerService(PlayerService_Old.self)
    var elapsedTimeTimer: Timer?
    var filePath: URL
    
    init(audioFilePath: URL, delegate: AVAudioPlayerDelegate) throws {
        
        self.filePath = audioFilePath
        
        // if audio file format is oga or ogg, convert to m4a
        if audioFilePath.pathExtension == "oga" || audioFilePath.pathExtension == "ogg" {
            let dest: URL = audioFilePath.deletingPathExtension().appendingPathExtension("m4a")
            
            // Check if file has been already converted
            if !FileManager.default.fileExists(atPath: dest.absoluteString) {
                try OGGConverter.convertOpusOGGToM4aFile(src: audioFilePath, dest: dest)
            }
            
            self.filePath = dest
        }
        
        super.init()
        
        logger.log(self.filePath.absoluteString, level: .debug)
        
        let audioSession = AVAudioSession.sharedInstance()
        try audioSession.setCategory(.playback, mode: .default)
        try audioSession.setActive(true)
        
        audioPlayer = try AVAudioPlayer(contentsOf: self.filePath)
        audioPlayer?.delegate = delegate
        audioPlayer?.isMeteringEnabled = true
        audioPlayer?.volume = 1.0
        audioPlayer?.prepareToPlay()
        
        elapsedTimeTimer = Timer.scheduledTimer(
            withTimeInterval: PlayerService_Old.updateInterval,
            repeats: true,
            block: { [weak self] _ in
                self?.updateElapsedTime()
            }
        )
    }
    
    deinit {
        elapsedTimeTimer?.invalidate()
        audioPlayer?.stop()
        audioPlayer = nil
        removeM4aAudio()
    }
    
    private func removeM4aAudio() {
        do {
            try FileManager.default.removeItem(at: self.filePath)
        } catch {
            logger.log(error, level: .error)
        }
    }
    
    private func startTimer() {
        guard let timer = self.elapsedTimeTimer else { return }
        let queue = DispatchQueue.global(qos: .userInteractive)
        
        queue.async {
            RunLoop.current.add(timer, forMode: .default)
            RunLoop.current.run()
        }
    }
    
    func updateElapsedTime() {
        if audioPlayer?.isPlaying ?? false {
            self.elapsedTime += PlayerService_Old.updateInterval
        }
    }
    
    func startPlayingAudio() {
        logger.log("Start playing")
        audioPlayer?.play()
        startTimer()
    }
    
    func pausePlayingAudio() {
        logger.log("Pause playing")
        audioPlayer?.pause()
    }
    
    func stopPlayingAudio() {
        logger.log("Stop playing")
        audioPlayer?.stop()
    }
}
