//
//  RecordingViewModel.swift
//  Mercury Watch App
//
//  Created by Marco Tammaro on 21/06/24.
//

import Foundation
import SwiftUI
import AVFoundation

class RecordingViewModel: ObservableObject {
    
    static let zeroValue: Float = 0.25
    static let maxValue: Float = 10
    static let chunks: Int = 20
    static let updateInterval: Double = 0.10
    private let recSettings = [
        AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
        AVSampleRateKey: 48000,
        AVEncoderBitRateKey: 256000,
        AVNumberOfChannelsKey: 2,
        AVEncoderAudioQualityKey: .max
    ]
    
    @Published var isRecording: Bool = false
    @Published var elapsedTime: Double = 0
    @Published var waveformData: [Float] = Array(repeating: zeroValue, count: chunks)
    
    private var recFilePath: URL
    private var audioRecorder: AVAudioRecorder?
    private var startTimestamp: Foundation.Date?
    private var endTimestamp: Foundation.Date?
    private var waveformUpdateTimer: Timer?
    
    init() {
        
        // Recording file path init
        let recordingName = "\(UUID().uuidString).m4a"
        let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        recFilePath = (urls[0] as URL).appendingPathComponent(recordingName)
        
        // Starting audio session
        let audioSession = AVAudioSession.sharedInstance()
        
        do {
            try audioSession.setCategory(.record, mode: .default)
            try audioSession.setActive(true)
        } catch {
            print("[CLIENT] [\(type(of: self))] [\(#function)] error: \(error)")
        }
        
        // Waveform update timer
        let queue = DispatchQueue.global(qos: .userInteractive)
        waveformUpdateTimer = Timer.scheduledTimer(
            withTimeInterval: RecordingViewModel.updateInterval,
            repeats: true,
            block: updateWaveform
        )
        
        queue.async {
            RunLoop.current.add(self.waveformUpdateTimer!, forMode: .default)
            RunLoop.current.run()
        }
        
    }
    
    func updateWaveform(_ timer: Timer) {
        
        guard let audioRecorder, isRecording else { return }
        
        func normalizedB(value: Float) -> Float {
//            let input = Float(-160)...Float(0)
            let input = Float(-80)...Float(0)
            let output = RecordingViewModel.zeroValue...RecordingViewModel.maxValue
            
            let x = (output.upperBound - output.lowerBound) * (value - input.lowerBound)
            let y = (input.upperBound - input.lowerBound)
            return x / y + output.lowerBound
        }
        
        audioRecorder.updateMeters()
        let decibel = audioRecorder.averagePower(forChannel: 0)
        let normdB = normalizedB(value: decibel)
        
        DispatchQueue.main.async {
            withAnimation {
                self.waveformData.append(normdB)
                self.waveformData.remove(at: 0)
                self.elapsedTime += RecordingViewModel.updateInterval
            }
        }
    }
    
    func startRecordingAudio() {
    
        print("[CLIENT] [\(type(of: self))] [\(#function)] Start recording")
        
        audioRecorder = try? AVAudioRecorder(url: recFilePath, settings: recSettings)
        audioRecorder?.isMeteringEnabled = true
        audioRecorder?.prepareToRecord()
        
        startTimestamp = .now
        audioRecorder?.record()
        isRecording = true
        
    }
    
    func stopRecordingAudio() {
        
        print("[CLIENT] [\(type(of: self))] [\(#function)] Stop recording")
        
        isRecording = false
        audioRecorder?.stop()
        endTimestamp = .now
        audioRecorder = nil
        
    }
    
}

