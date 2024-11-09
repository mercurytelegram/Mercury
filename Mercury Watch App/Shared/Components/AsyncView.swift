//
//  AsyncView.swift
//  Mercury Watch App
//
//  Created by Alessandro Alberti on 11/7/24.
//

import SwiftUI

struct AsyncView<Content: View, Placeholder: View>: View {
    @State private var content: Content? = nil
    var placeholder: () -> Placeholder
    let getContent: () async throws -> Content?
    
    init(
        placeholder: @escaping () -> Placeholder = { ProgressView() },
        getContent: @escaping () async throws -> Content?
    ) {
        self.getContent = getContent
        self.placeholder = placeholder
    }
    
    var body: some View {
        if let content {
            content
        } else {
            placeholder()
                .task {
                    self.content = try? await getContent()
                }
        }
    }
}

#Preview("Loader") {
    AsyncView() {
        let second: UInt64 = 1_000_000_000
        try? await Task.sleep(nanoseconds: 3 * second)
        return Image("astro")
            .resizable()
            .aspectRatio(contentMode: .fit)
    }
}

#Preview("Placeholder") {
    AsyncView(placeholder: { Text("placeholder...") }) {
        let second: UInt64 = 1_000_000_000
        try? await Task.sleep(nanoseconds: 3 * second)
        return Image("astro")
            .resizable()
            .aspectRatio(contentMode: .fit)
    }
    .aspectRatio(contentMode: .fit)
}
