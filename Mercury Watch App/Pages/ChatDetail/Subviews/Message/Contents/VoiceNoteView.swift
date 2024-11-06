//
//  MessageVoiceNote.swift
//  Mercury Watch App
//
//  Created by Marco Tammaro on 09/07/24.
//

import SwiftUI
import TDLibKit
import DSWaveformImageViews

struct VoiceNoteView: View {
    
    let model: VoiceNoteModel
    let isOutgoing: Bool
    let onPress: () -> Void
    
    init(model: VoiceNoteModel, isOutgoing: Bool, onPress: @escaping () -> Void) {
        self.model = model
        self.isOutgoing = isOutgoing
        self.onPress = onPress
    }
    
    var replyForegroundColor: Color {
        isOutgoing ? .white : .blue
    }
    
    var replyBackgroundColor: Color {
        isOutgoing ? .blue : .white
    }
    
    var body: some View {
        
        HStack(alignment: .top, spacing: 5) {
            
            Button(
                action: onPress,
                label: {
                    
                    ZStack {
                        ProgressView()
                            .opacity(model.isLoading ? 1 : 0)
                            .foregroundStyle(replyBackgroundColor)
                        Image(systemName: model.isPlaying ? "pause.fill" : "play.fill")
                            .opacity(model.isLoading ? 0 : 1)
                            .foregroundStyle(replyBackgroundColor)
                    }
                    .font(.system(size: 24))
                    .padding(12)
                    .background(replyForegroundColor)
                    .clipShape(Circle())
                    
                })
            .frame(width: 42, height: 42)
            .buttonStyle(.plain)
            
            VStack(alignment: .leading) {
                
                var elapsedTime: String {
                    let time = model.seconds
                    let seconds = Int(time % 60)
                    let minutes = Int(time / 60)
                    return String(format:"%02d:%02d", minutes, seconds)
                }
                
                if let url = model.audioUrl {
                    WaveformView(
                        audioURL: url,
                        configuration: .init(
                            style: .striped(.init(color: UIColor(replyForegroundColor))),
                            verticalScalingFactor: 0.4
                        )
                    )
                    .frame(height: 42, alignment: .leading)
                }
                
                HStack {
                    Text(elapsedTime)
                        .font(.system(size: 15))
                        .bold()
                    
                    if !model.isListened {
                        Circle()
                            .frame(width: 6, height: 6)
                    }
                    
                }
                .foregroundStyle(replyForegroundColor)
                
            }
        }
    }
}

struct VoiceNoteModel {
    var audioUrl: URL?
    var isPlaying: Bool = false
    var isLoading: Bool
    var isListened: Bool
    var seconds: Int = 0
}

#Preview {
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
