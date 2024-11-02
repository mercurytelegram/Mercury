//
//  StepView.swift
//  Mercury Watch App
//
//  Created by Alessandro Alberti on 2/11/24.
//

import SwiftUI

struct StepView: View {
    var steps: [String]
    
    var body: some View {
        VStack {
            ForEach(steps.indices, id: \.self) { index in
                infoCell(number: index + 1, text: steps[index])
                    .padding(.vertical)
            }
        }
    }
    
    func infoCell(number: Int, text: String) -> some View {
        HStack {
            Image(systemName: "\(number).circle.fill")
                .font(.title)
                .foregroundStyle(.white, .blue)
            Text(text)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
    
}

#Preview {
    ScrollView {
        StepView(steps: [
            "Open Telegram on your phone",
            "Go to Settings → Devices → Link Desktop Device",
            "Point your phone at the QR code to confirm login"
        ])
    }
}

