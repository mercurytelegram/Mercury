//
//  SendingLoaderView.swift
//  Mercury Watch App
//
//  Created by Alessandro Alberti on 16/07/24.
//

import SwiftUI

struct SendingLoaderView: View {
    @State private var animating = false
    
    var body: some View {
        Image(systemName: "arrow.triangle.2.circlepath")
            .rotationEffect(animating ? .degrees(360) : .zero)
            .font(.system(size: 15))
            .foregroundStyle(.secondary)
            .onAppear {
                withAnimation(.linear(duration: 1.8).repeatForever(autoreverses: false)) {
                    animating = true
                }
            }
    }
}

#Preview {
    SendingLoaderView()
}
