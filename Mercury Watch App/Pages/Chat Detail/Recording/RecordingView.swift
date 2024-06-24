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
    
    var body: some View {
        
        VStack {
            chart
        }
        .navigationTitle("\(Int(vm.elapsedTime))")
        .defaultScrollAnchor(.bottom)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Send", systemImage: "arrow.up") {
                    
                }
                .foregroundStyle(.white, .blue)
            }
            ToolbarItemGroup(placement: .bottomBar) {
                
                Button("Record", systemImage: "square.fill") {
                    vm.stopRecordingAudio()
                }
                .controlSize(.large)
                .foregroundStyle(.white, .blue)
                
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
        
        let paddedData = vm.waveformData + Array(
            repeating: RecordingViewModel.zeroValue,
            count: RecordingViewModel.chunks
        )
        
        Chart(Array(paddedData.enumerated()), id: \.0) { index, magnitude in
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
