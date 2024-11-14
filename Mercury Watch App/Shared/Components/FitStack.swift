//
//  FitStack.swift
//  Mercury Watch App
//
//  Created by Alessandro Alberti on 11/14/24.
//

import SwiftUI

struct FitStack<Content: View>: View {
    let content: () -> Content
    let vAlignment: HorizontalAlignment
    let hAlignment: VerticalAlignment
    
    init (
        vAlignment: HorizontalAlignment = .leading,
        hAlignment: VerticalAlignment = .center,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.content = content
        self.vAlignment = vAlignment
        self.hAlignment = hAlignment
    }
    
    var body: some View {
        ViewThatFits {
            HStack(alignment: hAlignment) { content() }
            VStack(alignment: vAlignment) { content() }
        }
    }
}

#Preview("HStack") {
    FitStack() {
        Text("Hello, World!")
        Spacer()
        Text("Hello, World!")
    }
}

#Preview("VStack") {
    FitStack() {
        Text("Hello, World!")
        Spacer()
        Text("Hello, World!")
    }
    .frame(width: 80)
}
