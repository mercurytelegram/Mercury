//
//  MessageVoiceNote.swift
//  Mercury Watch App
//
//  Created by Marco Tammaro on 09/07/24.
//

import SwiftUI
import TDLibKit
import DSWaveformImageViews
import DSWaveformImage

struct VoiceNoteView: View {
    
    let model: VoiceNoteModel
    let isOutgoing: Bool
    let onPress: () -> Void
    
    private let waveformConfig: Waveform.Configuration
    private let replyForegroundColor: Color
    private let replyBackgroundColor: Color
    
    init(model: VoiceNoteModel, isOutgoing: Bool, onPress: @escaping () -> Void) {
        self.model = model
        self.isOutgoing = isOutgoing
        self.onPress = onPress
        
        self.replyForegroundColor = isOutgoing ? .white : .blue
        self.replyBackgroundColor = isOutgoing ? .blue : .white
        
        self.waveformConfig = .init(
            style: .striped(
                .init(color: UIColor(replyForegroundColor))
            ),
            verticalScalingFactor: 0.4
        )
    }
    
    private var actionIcon: String {
        model.isPlaying ? "pause.fill" : "play.fill"
    }
    
    private var elapsedTime: String {
        let time = model.seconds
        let seconds = Int(time % 60)
        let minutes = Int(time / 60)
        return String(format:"%02d:%02d", minutes, seconds)
    }
    
    var body: some View {
        
        HStack(alignment: .top, spacing: 5) {
            
            Button(
                action: onPress,
                label: {
                    
                    ZStack {
                        ProgressView()
                            .tint(replyBackgroundColor)
                            .opacity(model.isLoading ? 1 : 0)
                        Image(systemName: actionIcon)
                            .foregroundStyle(replyBackgroundColor)
                            .opacity(model.isLoading ? 0 : 1)
                    }
                    .font(.system(size: 24))
                    .padding(12)
                    .background(replyForegroundColor)
                    .clipShape(Circle())
                    
                }
            )
            .frame(width: 42, height: 42)
            .buttonStyle(.plain)
            
            VStack(alignment: .leading) {
                
                if let url = model.audioUrl {
                    waveform(url)
                    .frame(height: 42, alignment: .leading)
                
                    HStack {
                        Text(elapsedTime)
                            .font(.system(size: 15))
                            .bold()
                        
                        if !model.isListened {
                            Circle()
                                .frame(
                                    width: 6,
                                    height: 6
                                )
                        }
                        
                    }
                    .foregroundStyle(replyForegroundColor)
                    
                } else {
                    waveformPlaceholder()
                        .frame(height: 42, alignment: .leading)
                }
            }
        }
    }
    
    @ViewBuilder
    func waveform(_ url: URL) -> some View {
        WaveformView(
            audioURL: url,
            configuration: waveformConfig
        )
    }
    
    @ViewBuilder
    func waveformPlaceholder() -> some View {
        
        let sampleCount = 320
        
        // Adjust speed for faster or slower oscillation
        let oscillationSpeed = 1.0
        
        // Width of the "0" region to improve visibility
        let zeroWidth = 15
        
        TimelineView(.periodic(from: .now, by: 1/10)) { time in
           
            // Calculate the oscillating position based on time
            let timeInterval = time.date.timeIntervalSinceReferenceDate
            let sinValue = sin(timeInterval * oscillationSpeed)
            let position = Int((sinValue + 1) / 2 * Double(sampleCount - 1))

            // Generate the samples array with a "0" region that moves back and forth
            let samples: [Float] = (0..<sampleCount).map {
                ($0 >= position && $0 < position + zeroWidth) ? 0.2 : 1
            }

            WaveformLiveCanvas(
                samples: samples,
                configuration: waveformConfig
            )
        }
    }
}

struct VoiceNoteModel {
    var audioUrl: URL?
    var isPlaying: Bool = false
    var isLoading: Bool
    var isListened: Bool = false
    var seconds: Int = 0
}

#Preview("Loading") {
    VoiceNoteView(
        model: .init(
            isLoading: true
        ),
        isOutgoing: true
    ) {
        print("Play/Pause")
    }
}

#Preview("Ready") {
    VoiceNoteView(
        model: .init(
            audioUrl: Bundle.main.url(forResource: "audio_sample", withExtension: "m4a"),
            isLoading: false,
            isListened: false,
            seconds: 10
        ),
        isOutgoing: false
    ) {
        print("Play/Pause")
    }
}

#Preview("Listening") {
    VoiceNoteView(
        model: .init(
            audioUrl: Bundle.main.url(forResource: "audio_sample", withExtension: "m4a"),
            isPlaying: true,
            isLoading: false,
            isListened: true,
            seconds: 140
        ),
        isOutgoing: false
    ) {
        print("Play/Pause")
    }
}
