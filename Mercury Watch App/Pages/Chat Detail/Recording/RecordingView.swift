//
//  RecordingView.swift
//  Mercury Watch App
//
//  Created by Marco Tammaro on 21/06/24.
//

import SwiftUI
import Charts
import AVFAudio

struct RecordingView: View {
    
    @StateObject var vm = RecordingViewModel()
    @Binding var isPresented: Bool
    
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
        case .recStopped, .playStopped:
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
        case .recStopped, .playStopped:
            return "Play"
        case .playStarted:
            return "Pause"
        case .sending:
            return "Loading"
        }
    }
    
    var body: some View {
        
        chart
        .navigationTitle(elapsedTime)
        .defaultScrollAnchor(.bottom)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Send", systemImage: "arrow.up") {
                    if vm.state == .sending { return }
                    vm.didPressSendButton()
                }
                .foregroundStyle(.white, .blue)
            }
            
            ToolbarItemGroup(placement: .bottomBar) {
                
                if vm.state != .sending {
                    Button(
                        mainActionTitle,
                        systemImage: mainActionIcon
                    ) {
                        vm.didPressMainAction()
                    }
                    .controlSize(.large)
                    .foregroundStyle(.white, .blue)
                    
                } else {
                    ProgressView()
                        .controlSize(.large)
                }
                
            }
        }
        .background {
            Rectangle()
                .foregroundStyle(
                    Gradient(colors: [
                        .blue.opacity(0.7),
                        .blue.opacity(0.2)]
                    ))
                .ignoresSafeArea()
        }
        .task {
            let hasPermission = await AVAudioApplication.requestRecordPermission()
            await MainActor.run {
                isPresented = hasPermission
                if hasPermission { vm.startRecordingAudio() }
            }
        }
        
    }
    
    @ViewBuilder
    var chart: some View {
        
        Chart(Array(vm.waveformData.enumerated()), id: \.0) { index, magnitude in
            BarMark(
                x: .value("Frequency", String(index)),
                y: .value("Magnitude", magnitude),
                stacking: .center
            )
            .clipShape(
                RoundedRectangle(cornerRadius: 25)
            )
            
           
        }
        .chartXAxis(.hidden)
        .chartYAxis(.hidden)
        .chartYScale(domain: -RecordingViewModel.maxValue...RecordingViewModel.maxValue)
    }
    
}

#Preview {
    Text("background")
        .sheet(isPresented: .constant(true), content: {
            RecordingView(isPresented: .constant(true))
        })
}
