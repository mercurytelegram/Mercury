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
    
    @Published var elapsedTime: TimeInterval = .zero
    
    private var audioPlayer: AVAudioPlayer?
    private var audioFilePath: URL
    private var audioFilePathData: Data? { try? Data(contentsOf: audioFilePath) }
    
    init(audioFilePath: URL, delegate: AVAudioPlayerDelegate) throws {
        
        self.audioFilePath = audioFilePath
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
        
    }
    
    deinit {
        dispose()
    }
    
    func dispose() {
        audioPlayer?.stop()
        audioPlayer = nil
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
