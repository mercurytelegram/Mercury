//
//  RecordingViewModel.swift
//  Mercury Watch App
//
//  Created by Marco Tammaro on 21/06/24.
//

import Foundation
import SwiftUI
import AVFoundation

class RecordingViewModel: NSObject, ObservableObject {
    
    /*
     
     State Diagram:
                                   ┌───────────────┬──────────────────┬──────────────────┬──> sending ──> Final State
                                   │               │                  │                  │
     Initial State ──> recStarted ─┴─> recStopped ─┴─┬─> playStarted ─┴─> playStopped ───┤
                                                     │                                   │
                                                     └───────────────────────────────────┘
     
     Notice: From each state it is possible to reach the cancel
             state that consist in the sheet dismissal
     
    */
    enum RecordingState {
        case recStarted, recStopped, playStarted, playStopped, sending
    }
    
    static let zeroValue: Float = 0.01
    static let maxValue: Float = 1
    static let chunks: Int = 41
    static let updateInterval: Double = 0.10
    
    @Published var state: RecordingState = .recStarted
    @Published var waveformData: [Float] = Array(repeating: zeroValue, count: chunks)
    @Published var elapsedTime: TimeInterval = .zero
    
    private var audioRecorder: AVAudioRecorder?
    private var audioPlayer: AVAudioPlayer?
    private var recFilePath: URL
    private var waveformTimer: Timer?
    
    override init() {
        
        // Recording file path
        let recName = "\(UUID().uuidString).m4a"
        let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        recFilePath = (urls[0] as URL).appendingPathComponent(recName)
        super.init()
       
        // Starting audio session
        let audioSession = AVAudioSession.sharedInstance()
        
        do {
            try audioSession.setCategory(.playAndRecord, mode: .default)
            try audioSession.setActive(true)
        } catch {
            print("[CLIENT] [\(type(of: self))] [\(#function)] error: \(error)")
        }
        
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
    
    func initAudioRecorder() {
        do {
            
            let recSettings = [
                AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
                AVSampleRateKey: 48000,
                AVEncoderBitRateKey: 256000,
                AVNumberOfChannelsKey: 1,
                AVEncoderAudioQualityKey: .max
            ]
            
            audioRecorder = try AVAudioRecorder(url: recFilePath, settings: recSettings)
            audioRecorder?.isMeteringEnabled = true
            audioRecorder?.prepareToRecord()
            audioRecorder?.record()
            
        } catch {
            print("[CLIENT] [\(type(of: self))] [\(#function)] recorder error: \(error)")
            return
        }
    }
    
    func initAudioPlayer() {
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: recFilePath)
            audioPlayer?.delegate = self
            audioPlayer?.isMeteringEnabled = true
            audioPlayer?.volume = 1.0
            audioPlayer?.prepareToPlay()
        } catch {
            print("[CLIENT] [\(type(of: self))] [\(#function)] player error: \(error)")
            return
        }
    }
    
    deinit {
        waveformTimer?.invalidate()
        
        audioRecorder?.stop()
        audioRecorder?.deleteRecording()
        audioPlayer?.stop()
        
        audioRecorder = nil
        audioPlayer = nil
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
        
        if state == .recStarted {
            audioRecorder?.updateMeters()
            
            guard let decibel = audioRecorder?.averagePower(forChannel: 0) // Gives -160...0 values
            else { return }
            
            let normdB = normalizedB(value: decibel)
            
            print(decibel, normdB)
            DispatchQueue.main.async {
                withAnimation {
                    self.waveformData.append(normdB)
                    self.waveformData.remove(at: 0)
                    self.elapsedTime += RecordingViewModel.updateInterval
                }
            }
        }
        
        else if state == .playStarted {
            audioPlayer?.updateMeters()
            
            guard let decibel = audioPlayer?.averagePower(forChannel: 0) // Gives -160...0 values
            else { return }
            
            let normdB = normalizedB(value: decibel)
            let center = Int(RecordingViewModel.chunks/2)
            let sigma = Double(center) / 2.0
            let maxGaussian = gaussiana(x: center, mu: center, sigma: sigma)
            
            DispatchQueue.main.async {
                withAnimation {
                    for i in 0..<self.waveformData.count {
                        let gaussianValue = gaussiana(x: i, mu: center, sigma: sigma)
                        self.waveformData[i] = normdB * Float((gaussianValue / maxGaussian))
                    }
                }
            }
        }
    }
    
    func didPressMainAction() {
        switch state {
        case .recStarted:
            stopRecordingAudio()
        case .recStopped, .playStopped:
            startPlayingAudio()
        case .playStarted:
            stopPlayingAudio()
        default:
            return
        }
    }
    
    func didPressSendButton() {
        
        if state == .recStarted {
            stopRecordingAudio()
        }
        
        state = .sending
    }
    
    func startRecordingAudio() {
        print("[CLIENT] [\(type(of: self))] [\(#function)] Start recording")
        state = .recStarted
        initAudioRecorder()
    }
    
    private func stopRecordingAudio() {
        print("[CLIENT] [\(type(of: self))] [\(#function)] Stop recording")
        state = .recStopped
        audioRecorder?.stop()
        initAudioPlayer()
    }
    
    private func startPlayingAudio() {
        print("[CLIENT] [\(type(of: self))] [\(#function)] Start playing")
        state = .playStarted
        clearWaveform()
        audioPlayer?.play()
    }
    
    private func stopPlayingAudio() {
        print("[CLIENT] [\(type(of: self))] [\(#function)] Stop playing")
        state = .playStopped
        audioPlayer?.stop()
        clearWaveform()
    }
    
    private func clearWaveform() {
        waveformData = Array(repeating: RecordingViewModel.zeroValue, count: RecordingViewModel.chunks)
    }
}

extension RecordingViewModel: AVAudioPlayerDelegate {
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        if flag { stopPlayingAudio() }
    }
}
