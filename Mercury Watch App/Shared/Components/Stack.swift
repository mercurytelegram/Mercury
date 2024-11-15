//
//  Stack.swift
//  Mercury Watch App
//
//  Created by Alessandro Alberti on 11/15/24.
//

import SwiftUI

struct Stack<Content: View>: View {
    let content: () -> Content
    let type: StackType
    
    init (
        _ type: StackType,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.content = content
        self.type = type
    }
    
    var body: some View {
        switch type {
        case .vertical(let alignment):
            VStack(alignment: alignment) { content() }
            
        case .horizontal(let alignment):
            HStack(alignment: alignment) { content() }
        }
    }
    
    enum StackType {
        case vertical(alignment: HorizontalAlignment = .center)
        case horizontal(alignment: VerticalAlignment = .center)
    }
}

#Preview("HStack") {
    Stack(.horizontal()) {
        Text("Hello, World!")
        Spacer()
        Text("Hello, World!")
    }
}

#Preview("VStack") {
    Stack(.vertical()) {
        Text("Hello, World!")
        Spacer()
        Text("Hello, World!")
    }
    .frame(width: 80)
}
