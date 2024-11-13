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

@Observable
class PlayerService: NSObject {
    
    static let updateInterval: Double = 0.20
    
    var audioDuration: TimeInterval
    var elapsedTime: TimeInterval = .zero
    var isPlaying: Bool = false
    var isLoading: Bool
    
    private var audioPlayer: AVAudioPlayer?
    private let logger = LoggerService(PlayerService.self)
    var elapsedTimeTimer: Timer?
    var filePath: URL
    
    init(audioFilePath: URL, delegate: AVAudioPlayerDelegate? = nil) throws {
        
        self.isLoading = true
        self.filePath = audioFilePath
        self.audioDuration = 0
        super.init()
        
        // if audio file format is oga or ogg, convert to m4a
        if audioFilePath.pathExtension == "oga" || audioFilePath.pathExtension == "ogg" {
            let dest: URL = audioFilePath.deletingPathExtension().appendingPathExtension("m4a")
            
            // Check if file has been already converted
            if !FileManager.default.fileExists(atPath: dest.absoluteString) {
                try OGGConverter.convertOpusOGGToM4aFile(src: audioFilePath, dest: dest)
            }
            
            self.filePath = dest
        }
        
        logger.log(self.filePath.absoluteString, level: .debug)
        
        let audioSession = AVAudioSession.sharedInstance()
        try audioSession.setCategory(.playback, mode: .default)
        try audioSession.setActive(true)
        
        audioPlayer = try AVAudioPlayer(contentsOf: self.filePath)
        audioPlayer?.isMeteringEnabled = true
        audioPlayer?.volume = 1.0
        audioPlayer?.prepareToPlay()
        audioPlayer?.delegate = delegate ?? self
        
        audioDuration = audioPlayer?.duration ?? 0
        elapsedTimeTimer = Timer.scheduledTimer(
            withTimeInterval: PlayerService.updateInterval,
            repeats: true,
            block: { [weak self] _ in
                self?.updateElapsedTime()
            }
        )
        
        self.isLoading = false
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
        if isPlaying {
            withAnimation {
                self.elapsedTime += PlayerService.updateInterval
            }
        }
    }
    
    func startPlayingAudio() {
        isPlaying = true
        logger.log("Start playing")
        audioPlayer?.play()
        startTimer()
    }
    
    func pausePlayingAudio() {
        isPlaying = false
        logger.log("Pause playing")
        audioPlayer?.pause()
    }
    
    func stopPlayingAudio() {
        isPlaying = false
        elapsedTime = .zero
        logger.log("Stop playing")
        audioPlayer?.stop()
    }
}

extension PlayerService: AVAudioPlayerDelegate {
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        if flag { self.stopPlayingAudio() }
    }
}

class PlayerServiceMock: PlayerService {
    init() {
        let sampleFile = Bundle.main.url(forResource: "audio_sample", withExtension: "m4a")!
        try! super.init(audioFilePath: sampleFile)
    }
}
