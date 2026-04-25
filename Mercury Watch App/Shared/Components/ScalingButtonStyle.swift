//
//  ScalingButtonStyle.swift
//  Mercury Watch App
//
//  Created by Alessandro Alberti on 2/10/25.
//

import SwiftUI

struct ScalingButtonStyle: ButtonStyle {
    var scaleAmount: Double = 0.8
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? scaleAmount : 1)
            .animation(.bouncy,
                       value: configuration.isPressed
            )
        
    }
}

extension ButtonStyle where Self == ScalingButtonStyle {
    static var scaling: Self { Self() }
}

#Preview {
    Button(action: {}) {
        Text("Tap me")
    }
    .buttonStyle(.scaling)
}
