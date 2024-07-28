//
//  MessageVoiceNote.swift
//  Mercury Watch App
//
//  Created by Marco Tammaro on 09/07/24.
//

import SwiftUI
import TDLibKit

struct VoiceNoteContentView: View {
    
    @StateObject var vm: VoiceNoteContentViewModel
    @State private var showPlayAudioAlert: Bool = false
    
    init(message: MessageVoiceNote) {
        self._vm = StateObject(wrappedValue: VoiceNoteContentViewModel(message: message))
    }
    
    var body: some View {
        
        HStack(alignment: .top, spacing: 5) {
            
            Button(action: {
                showPlayAudioAlert = true
            }, label: {
                
                ZStack {
                    ProgressView().opacity(vm.loading ? 1 : 0)
                    Image(systemName: vm.playing ? "pause.fill" : "play.fill").opacity(vm.loading ? 0 : 1)
                }
                .font(.system(size: 24))
                .padding(12)
                .background(Color.blue)
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
            
                Waveform(data: vm.waveformData)
                .frame(height: 42, alignment: .leading)
                
                Text(elapsedTime)
                    .font(.system(size: 15))
                    .bold()
                    .foregroundStyle(.blue)
            }
        }
        .sheet(isPresented: $showPlayAudioAlert) {
            AlertView.inDevelopment("play audio is")
        }
    }
}

//#Preview {
//    VoiceNoteContentView(message: <#MessageVoiceNote#>)
//}
