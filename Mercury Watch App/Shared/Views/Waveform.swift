//
//  Waveform.swift
//  Mercury Watch App
//
//  Created by Marco Tammaro on 29/06/24.
//

import SwiftUI
import Charts

struct Waveform: View {
    
    static let suggestedSamples = 21
    
    let data: [Float]
    let highlightIndex: Int
    let highlightOpacity: Double
    let numSamples: Int
    
    /// Convert the provided data into an array of `numSamples` float sample by normalizing each value between `minValue` and `maxValue`
    ///
    /// - Warning: data count sould be major or euqal to `numSamples`
    ///
    /// - Parameters:
    ///
    ///     - data: The data do display
    ///     - highlightIndex: The index of the last bar to highlight, if nil all the bars will be highlighted
    ///     - highlightOpacity: The opacity value applied to not highlighted bars
    ///     - numSamples: The numer of bars to show in the waveform
    init(
        data: [Float],
        highlightIndex: Int? = nil,
        highlightOpacity: Double = 0.2,
        numSamples: Int = suggestedSamples
    ) {
        self.data = data
        self.highlightIndex = highlightIndex ?? numSamples
        self.highlightOpacity = highlightOpacity
        self.numSamples = numSamples
    }
    
    private var normalizedData: [Float] {
        guard let min = data.min(), let max = data.max(), max != min else {
            return Array(repeating: 0.5, count: data.count)
        }
        return data.map { ($0 - min) / (max - min) }
    }
    
    private var aggregatedData: [Float] {
        let segmentSize = data.count / numSamples
        return (0..<numSamples).map { i in
            let start = i * segmentSize
            let end = min(start + segmentSize, data.count)
            let segment = normalizedData[start..<end]
            return segment.reduce(0, +) / Float(segment.count)
        }
    }
    
    var body: some View {
        Chart {
            ForEach(aggregatedData.indices, id: \.self) { index in
                BarMark(
                    x: .value("Frequency", String(index)),
                    y: .value("Magnitude", aggregatedData[index]),
                    stacking: .center
                )
                .opacity(index < highlightIndex ? 1.0 : highlightOpacity)
                .clipShape(
                    RoundedRectangle(cornerRadius: 25)
                )
            }
        }
        .chartYScale(domain: -0.5...0.5)
        .chartXAxis(.hidden)
        .chartYAxis(.hidden)
    }
}

#Preview {
    Waveform(
        data: Array(0..<200).map { _ in Float.random(in: 1...255) },
        highlightIndex: 10
    )
}
