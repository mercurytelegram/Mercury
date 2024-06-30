//
//  PlayingViewModel.swift
//  Mercury Watch App
//
//  Created by Marco Tammaro on 27/06/24.
//

import Foundation
import SwiftUI
import AVFoundation

class PlayingViewModel: NSObject, ObservableObject {
   
    enum PlayingState {
        case playStarted, playPaused, playStopped
    }
    
    static let zeroValue: Float = 0.01
    static let maxValue: Float = 1
    static let chunks: Int = 41
    static let updateInterval: Double = 0.10
    
    @Published var waveformData: [Float] = Array(repeating: zeroValue, count: chunks)
    @Published var elapsedTime: TimeInterval = .zero
    
    private var audioPlayer: AVAudioPlayer?
    private var audioFilePath: URL
    var waveformTimer: Timer?
    
    init(audioFilePath: URL) {
        
        // Recording file path
        self.audioFilePath = audioFilePath
        super.init()
        
        // Waveform update timer
        let queue = DispatchQueue.global(qos: .userInteractive)
        
        waveformTimer = Timer.scheduledTimer(
            withTimeInterval: RecordingViewModel.updateInterval,
            repeats: true,
            block: updateWaveform
        )
        
        queue.async {
            RunLoop.current.add(self.waveformTimer!, forMode: .default)
            RunLoop.current.run()
        }
        
    }
    
    deinit {
        dispose()
    }
    
    func dispose() {
        waveformTimer?.invalidate()
        audioPlayer?.stop()
        audioPlayer = nil
    }
    
    func initAudioPlayer() {
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: audioFilePath)
            audioPlayer?.delegate = self
            audioPlayer?.isMeteringEnabled = true
            audioPlayer?.volume = 1.0
            audioPlayer?.prepareToPlay()
        } catch {
            print("[CLIENT] [\(type(of: self))] [\(#function)] player error: \(error)")
            return
        }
    }
    
    func updateWaveform(_ timer: Timer) {
        
        func normalizedB(value: Float) -> Float {
            let input = Float(-60)...Float(0)
            if value < input.lowerBound { return RecordingViewModel.zeroValue }
            let output = RecordingViewModel.zeroValue...RecordingViewModel.maxValue
            let x = (output.upperBound - output.lowerBound) * (value - input.lowerBound)
            let y = (input.upperBound - input.lowerBound)
            return x / y + output.lowerBound
        }
        
        func gaussiana(x: Int, mu: Int, sigma: Double) -> Double {
            return (1.0 / (sigma * sqrt(2.0 * Double.pi))) * exp(-pow(Double(x) - Double(mu), 2) / (2.0 * pow(sigma, 2)))
        }
        
        if audioPlayer?.isPlaying ?? false {
            audioPlayer?.updateMeters()
            
            guard let decibel = audioPlayer?.averagePower(forChannel: 0) // Gives -160...0 values
            else { return }
            
            let normdB = normalizedB(value: decibel)
            let center = Int(RecordingViewModel.chunks/2)
            let sigma = Double(center) / 2.0
            let maxGaussian = gaussiana(x: center, mu: center, sigma: sigma)
            
            for i in 0..<self.waveformData.count {
                let gaussianValue = gaussiana(x: i, mu: center, sigma: sigma)
                self.waveformData[i] = normdB * Float((gaussianValue / maxGaussian))
            }
        }
    }
    
    private func readBuffer(_ audioUrl: URL, completion: @escaping (_ wave:UnsafeBufferPointer<Float>?)->Void)  {
        DispatchQueue.global(qos: .utility).async {
            guard let file = try? AVAudioFile(forReading: audioUrl) else {
                completion(nil)
                return
            }
            let audioFormat = file.processingFormat
            let audioFrameCount = UInt32(file.length)
            guard let buffer = AVAudioPCMBuffer(pcmFormat: audioFormat, frameCapacity: audioFrameCount)
            else { return completion(UnsafeBufferPointer<Float>(_empty: ())) }
            do {
                try file.read(into: buffer)
            } catch {
                print(error)
            }
            
            let floatArray = UnsafeBufferPointer(start: buffer.floatChannelData![0], count: Int(buffer.frameLength))
            
            DispatchQueue.main.sync {
                completion(floatArray)
            }
        }
    }
    
    func startPlayingAudio() {
        print("[CLIENT] [\(type(of: self))] [\(#function)] Start playing")
        clearWaveform()
        audioPlayer?.play()
    }
    
    func pausePlayingAudio() {
        print("[CLIENT] [\(type(of: self))] [\(#function)] Stop playing")
        audioPlayer?.pause()
    }
    
    func stopPlayingAudio() {
        print("[CLIENT] [\(type(of: self))] [\(#function)] Stop playing")
        audioPlayer?.stop()
        clearWaveform()
    }
    
    private func clearWaveform() {
        waveformData = Array(repeating: PlayingViewModel.zeroValue, count: PlayingViewModel.chunks)
    }
}

extension PlayingViewModel: AVAudioPlayerDelegate {
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        if flag { stopPlayingAudio() }
    }
}
