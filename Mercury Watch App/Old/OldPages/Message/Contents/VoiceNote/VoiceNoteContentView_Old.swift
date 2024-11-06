//
//  MessageVoiceNote.swift
//  Mercury Watch App
//
//  Created by Marco Tammaro on 09/07/24.
//

import SwiftUI
import TDLibKit
import DSWaveformImageViews

struct VoiceNoteContentView_Old: View {
    
    @ObservedObject var vm: VoiceNoteContentViewModel
    @EnvironmentObject var messageVM: MessageViewModel_Old
    
    init(message: MessageVoiceNote) {
        self.vm = VoiceNoteContentViewModel(message: message)
    }
    
    var body: some View {
        
        HStack(alignment: .top, spacing: 5) {
            
            Button(action: {
                vm.play()
                messageVM.markContentAsOpened()
            }, label: {
                
                ZStack {
                    ProgressView()
                        .opacity(vm.loading ? 1 : 0)
                        .foregroundStyle(messageVM.replyBackgroundColor)
                    Image(systemName: vm.playing ? "pause.fill" : "play.fill")
                        .opacity(vm.loading ? 0 : 1)
                        .foregroundStyle(messageVM.replyBackgroundColor)
                }
                .font(.system(size: 24))
                .padding(12)
                .background(messageVM.replyForegroundColor)
                .clipShape(Circle())
                
            })
            .frame(width: 42, height: 42)
            .buttonStyle(.plain)
            
            VStack(alignment: .leading) {
                
                var elapsedTime: String {
                    let time = vm.message.voiceNote.duration
                    let seconds = Int(time % 60)
                    let minutes = Int(time / 60)
                    return String(format:"%02d:%02d", minutes, seconds)
                }
                
                if let url = vm.fileUrl {
                    WaveformView(
                        audioURL: url,
                        configuration: .init(
                            style: .striped(.init(color: UIColor(messageVM.replyForegroundColor))),
                            verticalScalingFactor: 0.4
                        )
                    )
                    .frame(height: 42, alignment: .leading)
                }
                
                HStack {
                    Text(elapsedTime)
                        .font(.system(size: 15))
                        .bold()
                    
                    if !vm.message.isListened {
                        Circle()
                            .frame(width: 6, height: 6)
                    }
                    
                }
                .foregroundStyle(messageVM.replyForegroundColor)
                
            }
        }
    }
}

//#Preview {
//    VoiceNoteContentView(message: <#MessageVoiceNote#>)
//}
