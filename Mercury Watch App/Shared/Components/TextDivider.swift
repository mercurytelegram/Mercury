//
//  TextDivider.swift
//  Mercury Watch App
//
//  Created by Alessandro Alberti on 1/17/25.
//

import SwiftUI

struct TextDivider: View {
    let text: String
    
    init(_ text: String) {
        self.text = text
    }
    
    var body: some View {
        HStack {
            Rectangle()
                .frame(height: 1)
                .foregroundStyle(.secondary)
            Text(text)
            Rectangle()
                .frame(height: 1)
                .foregroundStyle(.secondary)
        }
    }
}

#Preview {
    TextDivider("hello")
}
