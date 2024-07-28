//
//  Waveform.swift
//  Mercury Watch App
//
//  Created by Marco Tammaro on 29/06/24.
//

import SwiftUI
import Charts

struct Waveform: View {
    
    let data: [Float]
    let highlightIndex: Int
    let highlightOpacity: Double
    let numSamples: Int
    
    /// - Parameters:
    ///
    ///     - data: The data do display, values should be in 0...1 range
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
    
    var body: some View {
        Chart {
            ForEach(data.indices, id: \.self) { index in
                BarMark(
                    x: .value("Frequency", String(index)),
                    y: .value("Magnitude", data[index]),
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

/// Waveform utils
extension Waveform {
    
    typealias MinMax = (min: Float, max: Float)
    
    static let suggestedSamples = 21
    static let outputNormalizationRange: MinMax = (0.1, 1.0)
    
    static func normalize(
        _ values: [Float],
        from: MinMax,
        to: MinMax = Waveform.outputNormalizationRange
    ) -> [Float] {
        return values.map { value in
            return Waveform.normalize(value, from: from, to: to)
        }
    }
    
    static func normalize(
        _ value: Float,
        from: MinMax,
        to: MinMax = Waveform.outputNormalizationRange
    ) -> Float {
        // Calculate the normalized value
        let normalizedValue = (value - from.min) / (from.max - from.min)
        
        // Scale the normalized value to the end range
        let scaledValue = (normalizedValue * (to.max - to.min)) + to.min
        
        return scaledValue
    }
    
    static func aggregate(_ data: [Float], numSamples: Int = Waveform.suggestedSamples) -> [Float] {
        let segmentSize = data.count / numSamples

        return (0..<numSamples).map { i in
            let start = i * segmentSize
            let end = min(start + segmentSize, data.count)
            let segment = data[start..<end]
            return segment.reduce(0, +) / Float(segment.count)
        }
    }
}

#Preview {
    Waveform(
        data: Array(0..<200).map { _ in Float.random(in: 1...255) },
        highlightIndex: 10
    )
}
