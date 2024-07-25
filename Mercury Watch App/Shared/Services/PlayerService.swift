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
    
    static let updateInterval: Double = 0.10
    
    @Published var elapsedTime: TimeInterval = .zero
    
    private var audioPlayer: AVAudioPlayer?
    private var audioFilePath: URL
    private var audioFilePathData: Data?
    var elapsedTimeTimer: Timer?
    
    init(audioFilePath: URL, delegate: AVAudioPlayerDelegate) throws {
        
        self.audioFilePath = audioFilePath
        self.audioFilePathData = try? Data(contentsOf: audioFilePath)
        super.init()
        
        let audioSession = AVAudioSession.sharedInstance()
        try audioSession.setCategory(.playback, mode: .default)
        try audioSession.setActive(true)
        
        guard let data = audioFilePathData else {
            print("[CLIENT] [\(type(of: self))] [\(#function)] nil data")
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
    
    func getWaveform() -> [Float] {
        
        guard let data = audioFilePathData else {
            print("[CLIENT] [\(type(of: self))] [\(#function)] nil data")
            return []
        }
        
        return [UInt8](data).map({ Float($0) })
    }
    
    func startPlayingAudio() {
        print("[CLIENT] [\(type(of: self))] [\(#function)] Start playing")
        audioPlayer?.play()
        startTimer()
    }
    
    func pausePlayingAudio() {
        print("[CLIENT] [\(type(of: self))] [\(#function)] Stop playing")
        audioPlayer?.pause()
    }
    
    func stopPlayingAudio() {
        print("[CLIENT] [\(type(of: self))] [\(#function)] Stop playing")
        audioPlayer?.stop()
    }
}
