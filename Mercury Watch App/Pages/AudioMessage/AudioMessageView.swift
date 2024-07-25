//
//  RecordingView.swift
//  Mercury Watch App
//
//  Created by Marco Tammaro on 21/06/24.
//

import SwiftUI
import Charts
import AVFAudio

struct AudioMessageView: View {
    
    @StateObject var vm: AudioMessageViewModel
    @Binding var isPresented: Bool
    
    init(isPresented: Binding<Bool>, chat: ChatCellModel) {
        self._vm = StateObject(wrappedValue: AudioMessageViewModel(chat: chat))
        self._isPresented = isPresented
    }
    
    var elapsedTime: String {
        let time = vm.elapsedTime
        let seconds = Int(time.truncatingRemainder(dividingBy: 60))
        let minutes = Int(time / 60)
        return String(format:"%02d:%02d", minutes, seconds)
    }
    
    var mainActionIcon: String {
        switch vm.state {
        case .recStarted:
            return "square.fill"
        case .recStopped, .playPaused:
            return "play.fill"
        case .playStarted:
            return "pause.fill"
        case .sending:
            return "ellipsis"
        }
    }
    
    var mainActionTitle: String {
        switch vm.state {
        case .recStarted:
            return "Stop"
        case .recStopped, .playPaused:
            return "Play"
        case .playStarted:
            return "Pause"
        case .sending:
            return "Loading"
        }
    }
    
    var body: some View {
        
        Waveform(
            data: vm.state == .recStarted ? vm.waveformData.suffix(Waveform.suggestedSamples) : vm.waveformData,
            highlightIndex: vm.hightlightIndex
        )
        .navigationTitle(elapsedTime)
        .defaultScrollAnchor(.bottom)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Send", systemImage: "arrow.up") {
                    Task {
                        await vm.didPressSendButton()
                        await MainActor.run {
                            isPresented = false
                        }
                    }
                }
                .foregroundStyle(.white, .blue)
            }
            
            ToolbarItemGroup(placement: .bottomBar) {
                
                Button(
                    mainActionTitle,
                    systemImage: mainActionIcon
                ) {
                    vm.didPressMainAction()
                }
                .controlSize(.large)
                .foregroundStyle(.white, .blue)
                
            }
        }
        .task {
            // Dismiss audio message if no recording permission
            isPresented = await vm.onAppear()
        }
        
    }
    
}

#Preview {
    Text("background")
        .sheet(isPresented: .constant(true), content: {
            AudioMessageView(isPresented: .constant(true), chat: .preview())
        })
}
