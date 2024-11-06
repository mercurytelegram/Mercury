//
//  PinnedMessageView.swift
//  Mercury Watch App
//
//  Created by Alessandro Alberti on 30/08/24.
//

import SwiftUI

struct PillMessageView: View {
    
    var text: String
    
    private var attributed: AttributedString {
        get {
            let attr = try? AttributedString(
                markdown: text,
                options: .init(
                    interpretedSyntax: .inlineOnlyPreservingWhitespace
                )
            )
            
            return attr ?? AttributedString(text)
        }
    }
    
    var body: some View {
        Text(attributed)
            .multilineTextAlignment(.center)
            .font(.footnote)
            .padding()
            .padding(.horizontal)
            .background {
                RoundedRectangle(cornerRadius: 30)
                    .foregroundStyle(.ultraThinMaterial)
            }
    }
}

#Preview {
    ScrollView {
        PillMessageView(text: "**You**\npinned a message")
        Group {
            PillMessageView(text: "Marco pinned a message")
            PillMessageView(text: "Alesandro changed the group name to \"test\"")
        }
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(.blue.opacity(0.3))
}


