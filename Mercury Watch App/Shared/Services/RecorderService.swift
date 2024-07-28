//
//  RecordingViewModel.swift
//  Mercury Watch App
//
//  Created by Marco Tammaro on 27/06/24.
//

import Foundation
import SwiftUI
import AVFoundation

class RecorderService: NSObject, ObservableObject {
    
    static let updateInterval: Double = 0.10
    
    @Published var waveformSample: Float = 0
    @Published var elapsedTime: TimeInterval = .zero
    
    private var audioRecorder: AVAudioRecorder?
    private var recFilePath: URL
    private let logger = LoggerService(RecorderService.self)
    var waveformTimer: Timer?
    
    init(recFilePath: URL) {
        
        // Recording file path
        self.recFilePath = recFilePath
        super.init()
        
        waveformTimer = Timer.scheduledTimer(
            withTimeInterval: RecorderService.updateInterval,
            repeats: true,
            block: { [weak self] _ in
                self?.updateWaveform()
            }
        )
        
    }
    
    deinit {
        waveformTimer?.invalidate()
        audioRecorder?.stop()
        audioRecorder = nil
    }
    
    func initAudioRecorder() {
        do {
            
            let audioSession = AVAudioSession.sharedInstance()
            try audioSession.setCategory(.playAndRecord, mode: .default)
            try audioSession.setActive(true)
            
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
            
        } catch {
            logger.log(error, level: .error)
            return
        }
    }
    
    func startDataTimer() {
        guard let timer = self.waveformTimer else { return }
        let queue = DispatchQueue.global(qos: .userInteractive)
        
        queue.async {
            RunLoop.current.add(timer, forMode: .default)
            RunLoop.current.run()
        }
    }
    
    func updateWaveform() {
        
        if audioRecorder?.isRecording ?? false {
            audioRecorder?.updateMeters()
            
            // Gives -160...0 values
            guard let decibel = audioRecorder?.averagePower(forChannel: 0)
            else { return }
            
            let normalizedSample = Waveform.normalize(decibel, from: (-100, 0))
            
            self.waveformSample = normalizedSample
            self.elapsedTime += RecorderService.updateInterval
        }
        
    }
    
    func startRecordingAudio() {
        logger.log("Start recording")
        audioRecorder?.record()
        startDataTimer()
    }
    
    func stopRecordingAudio() {
        logger.log("Stop recording")
        audioRecorder?.stop()
    }
    
    func clearWaveform() {
        waveformSample = 0
    }
}
