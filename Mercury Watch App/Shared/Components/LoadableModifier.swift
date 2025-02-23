//
//  LoadableModifier.swift
//  Mercury
//
//  Created by Marco Tammaro on 23/02/25.
//

import SwiftUI

struct LoadableModifier: ViewModifier {
    let isLoading: Bool
    func body(content: Content) -> some View {
        ZStack {
            content
            
            if isLoading {
                Rectangle()
                    .foregroundStyle(.thinMaterial)
                    .ignoresSafeArea(edges: .all)
                ProgressView()
            }
        }
    }
}
