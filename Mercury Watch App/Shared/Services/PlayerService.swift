//
//  PlayingViewModel.swift
//  Mercury Watch App
//
//  Created by Marco Tammaro on 27/06/24.
//

import Foundation
import SwiftUI
import AVFoundation

class PlayerService: NSObject, ObservableObject {
    
    static let updateInterval: Double = 0.20
    
    @Published var elapsedTime: TimeInterval = .zero
    
    private var audioPlayer: AVAudioPlayer?
    private var audioFilePath: URL
    private var audioFilePathData: Data?
    private let logger = LoggerService(PlayerService.self)
    var elapsedTimeTimer: Timer?
    
    init(audioFilePath: URL, delegate: AVAudioPlayerDelegate) throws {
        
        self.audioFilePath = audioFilePath
        self.audioFilePathData = try? Data(contentsOf: audioFilePath)
        super.init()
        
        let audioSession = AVAudioSession.sharedInstance()
        try audioSession.setCategory(.playback, mode: .default)
        try audioSession.setActive(true)
        
        guard let data = audioFilePathData else {
            logger.log("nil data", level: .error)
            return
        }
        
        audioPlayer = try AVAudioPlayer(data: data)
        audioPlayer?.delegate = delegate
        audioPlayer?.isMeteringEnabled = true
        audioPlayer?.volume = 1.0
        audioPlayer?.prepareToPlay()
        
        elapsedTimeTimer = Timer.scheduledTimer(
            withTimeInterval: PlayerService.updateInterval,
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
    }
    
    func startTimer() {
        guard let timer = self.elapsedTimeTimer else { return }
        let queue = DispatchQueue.global(qos: .userInteractive)
        
        queue.async {
            RunLoop.current.add(timer, forMode: .default)
            RunLoop.current.run()
        }
    }
    
    func updateElapsedTime() {
        if audioPlayer?.isPlaying ?? false {
            self.elapsedTime += PlayerService.updateInterval
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
