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
    ///     - minValue: the minimum value to which the bar will start
    ///     - maxValue: the maximum value to which the bar will end
    init(
        data: Data,
        highlightIndex: Int? = nil,
        highlightOpacity: Double = 0.5,
        numSamples: Int = 20,
        minValue: Float = 0.1,
        maxValue: Float = 1.0
    ) {
        
        self.highlightIndex = highlightIndex ?? numSamples
        self.highlightOpacity = highlightOpacity
        
        // Convert the Data object to an array of UInt8 (bytes)
        let byteArray = [UInt8](data)
        let byteCount = byteArray.count

        // Calculate the size of each section
        let sectionSize = byteCount / numSamples

        // Array to hold the float values
        var floatArray: [Float] = []

        // Process each section
        for i in 0..<numSamples {
            let start = i * sectionSize
            let end = min(start + sectionSize, byteCount)
            let section = byteArray[start..<end]

            // Calculate the average of the section
            let sum = section.reduce(UInt64(0), { $0 + UInt64($1) })
            let average = Float(sum) / Float(section.count)

            // Normalize the average to the range [0.025, 1.0]
            let normalizedValue = (average / 255.0) * (maxValue - minValue) + minValue

            // Append the normalized value to the float array
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
    Waveform(data: Data(repeating: 25, count: 50), highlightIndex: 10)
}
