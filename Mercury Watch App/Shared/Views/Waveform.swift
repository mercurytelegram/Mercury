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
    static let suggestedOutputRange: ClosedRange<Float> = 0.01...1
    static let dBInputRange: ClosedRange<Float> = -60...0
    static let dataInputRange: ClosedRange<Float> = 0...255
    
    let data: [Float]
    let highlightIndex: Int
    let highlightOpacity: Double
    let normalizationRanges: (input: ClosedRange<Float>, output: ClosedRange<Float>)
    
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
    ///     - normalizationRanges: set as `input` the range of `data` values and provide as `output` the values you want to display in waveform
    init(
        data: [Float],
        highlightIndex: Int? = nil,
        highlightOpacity: Double = 0.2,
        numSamples: Int = suggestedSamples,
        normalizationRanges: (input: ClosedRange<Float>, output: ClosedRange<Float>)
    ) {
        
        self.highlightIndex = highlightIndex ?? numSamples
        self.highlightOpacity = highlightOpacity
        self.normalizationRanges = normalizationRanges
        
        // Convert the Data object to an array of UInt8 (bytes)
        let byteCount = data.count

        // Calculate the size of each section
        let sectionSize = byteCount / numSamples

        // Array to hold the float values
        var floatArray: [Float] = []
        
        let minInput = normalizationRanges.input.lowerBound
        let maxInput = normalizationRanges.input.upperBound
        let minOutput = normalizationRanges.output.lowerBound
        let maxOutput = normalizationRanges.output.upperBound
       
        // Process each section
        for i in 0..<numSamples {
            let start = i * sectionSize
            let end = min(start + sectionSize, byteCount)
            let section = data[start..<end]

            // Calculate the average of the section
            let sum = section.reduce(0) { $0 + $1 }
            let average = Float(sum) / Float(section.count)

            // Normalize the average to the range
            let x = (maxOutput - minOutput) * (average - minInput)
            let y = (maxInput - minInput)
            let normalizedValue = x / y + minOutput

            // Append the rescaled value to the float array
            floatArray.append(normalizedValue)
        }
        
        self.data = floatArray
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
        .chartXAxis(.hidden)
        .chartYAxis(.hidden)
    }
    
}

#Preview {
    Waveform(data: Array(repeating: 3.0, count: 50), 
             highlightIndex: 10,
             normalizationRanges: (input: 0...0, output: 0...0))
}
