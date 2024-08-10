//
//  ReactionsView.swift
//  Mercury Watch App
//
//  Created by Alessandro Alberti on 10/08/24.
//

import SwiftUI

struct ReactionsView: View {
    var reaction: Reaction
    
    var body: some View {
        HStack {
            Text(reaction.emoji)
            Text("\(reaction.count)")
        }
        .padding(.vertical, 3)
        .padding(.horizontal, 6)
        .background {
            Capsule()
                .foregroundStyle(reaction.isSelected ? .blue : .white.opacity(0.2))
        }
    }
}

struct Reaction: Hashable {
    let emoji: String
    let count: Int
    let isSelected: Bool
}

#Preview {
    HStack {
        ReactionsView(reaction: Reaction(emoji: "🔥", count: 3, isSelected: true))
        ReactionsView(reaction: Reaction(emoji: "👍", count: 2, isSelected: false))
    }
}
