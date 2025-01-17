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
    
    private let waveformConfig: Waveform.Configuration
    private let replyForegroundColor: Color
    private let replyBackgroundColor: Color
    private var player: PlayerService?
    
    init(model: VoiceNoteModel, isOutgoing: Bool) {
        self.model = model
        self.isOutgoing = isOutgoing
        
        self.replyForegroundColor = isOutgoing ? .white : .blue
        self.replyBackgroundColor = isOutgoing ? .blue : .white
        
        self.waveformConfig = .init(
            style: .striped(
                .init(color: UIColor(replyForegroundColor))
            ),
            verticalScalingFactor: 0.4
        )
    }
    
    var body: some View {
        AsyncView(getData: model.getPlayer) {
            loader()
        } buildContent: { player in
            content(player)
        }
    }
    
    @ViewBuilder
    func content(_ player: PlayerService) -> some View {
        
        var actionIcon: String {
            player.isPlaying ? "pause.fill" : "play.fill"
        }
        
        var elapsedTime: String {
            let time = player.isPlaying ? player.elapsedTime : player.audioDuration
            let seconds = Int(time.truncatingRemainder(dividingBy: 60))
            let minutes = Int(time / 60)
            return String(format:"%02d:%02d", minutes, seconds)
        }
        
        HStack(alignment: .top, spacing: 5) {
            
            Button {
                model.onPress?()
                if player.isPlaying {
                    player.pausePlayingAudio()
                } else {
                    player.startPlayingAudio()
                }
            } label: {
                Image(systemName: actionIcon)
                    .foregroundStyle(replyBackgroundColor)
                    .font(.system(size: 24))
                    .padding(12)
                    .background(replyForegroundColor)
                    .clipShape(Circle())
            }
            .frame(width: 42, height: 42)
            .buttonStyle(.plain)
            
            VStack(alignment: .leading) {
                
                waveform(player)
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
                
            }
        }
    }
    
    @ViewBuilder
    func loader() -> some View {
        
        HStack(alignment: .top, spacing: 5) {
            
            ProgressView()
                .tint(replyBackgroundColor)
                .font(.system(size: 24))
                .padding(12)
                .background(replyForegroundColor)
                .clipShape(Circle())
                .frame(width: 42, height: 42)
                .buttonStyle(.plain)
            
            VStack(alignment: .leading) {
                waveformPlaceholder()
                    .frame(height: 42, alignment: .leading)
                
                Text("00:00")
                    .font(.system(size: 15))
                    .bold()
                    .foregroundStyle(replyForegroundColor)
            }
        }
    }
    
    @ViewBuilder
    func waveform(_ player: PlayerService) -> some View {
        
        GeometryReader { proxy in
            
            let elapsed = player.elapsedTime == 0 ? player.audioDuration : player.elapsedTime
            let duration = player.audioDuration
            let width = proxy.size.width * (elapsed / duration)
            
            ZStack(alignment: .leading) {
                Rectangle()
                    .fill(replyForegroundColor.opacity(0.3))
                
                Rectangle()
                    .fill(replyForegroundColor)
                    .frame(width: width)
            }
            .mask {
                WaveformView(
                    audioURL: player.filePath,
                    configuration: waveformConfig
                )
            }
        }
    }
    
    @ViewBuilder
    func waveformPlaceholder() -> some View {
        
        let sampleCount = 320
        
        // Adjust speed for faster or slower oscillation
        let oscillationSpeed = 1.0
        
        // Width of the waveform "peak" region
        let peakWidth = sampleCount / 4
        
        TimelineView(.periodic(from: .now, by: 1/10)) { time in
            
            // Calculate the oscillating position based on time
            let timeInterval = time.date.timeIntervalSinceReferenceDate
            let sinValue = sin(timeInterval * oscillationSpeed)
            let position = Int((sinValue + 1) / 2 * Double(sampleCount - 1))
            
            // Generate the samples array with a smooth gradient moving back and forth
            let samples: [Float] = (0..<sampleCount).map { i in
                // Calculate the distance from the peak position
                let distance = abs(i - position)
                
                // Scale intensity based on distance, peaking at 1 in the center
                if distance < peakWidth {
                    let normalizedDistance = Float(distance) / Float(peakWidth)
                    // quadratic falloff for smooth gradient
                    return 0.2 + pow(normalizedDistance, 2)
                } else {
                    return 1
                }
            }
            
            WaveformLiveCanvas(
                samples: samples,
                configuration: waveformConfig
            )
        }
    }
}

struct VoiceNoteModel {
    var isListened: Bool = false
    var getPlayer: () async throws -> PlayerService?
    var onPress: (() -> Void)?
}

#Preview("Listened") {
    VoiceNoteView(
        model: .init(
            isListened: true,
            getPlayer: { PlayerServiceMock() }
        ),
        isOutgoing: true
    )
}

#Preview("Not Listened") {
    VoiceNoteView(
        model: .init(
            isListened: false,
            getPlayer: { PlayerServiceMock() }
        ),
        isOutgoing: false
    )
}

#Preview("Loading") {
    VoiceNoteView(
        model: .init(
            isListened: false,
            getPlayer: {
                try? await Task.sleep(for: .seconds(1_000_000))
                return PlayerServiceMock()
            }
        ),
        isOutgoing: true
    )
}
