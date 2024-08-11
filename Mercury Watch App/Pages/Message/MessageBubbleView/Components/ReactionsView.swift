//
//  ReactionsView.swift
//  Mercury Watch App
//
//  Created by Alessandro Alberti on 10/08/24.
//

import SwiftUI
import TDLibKit

struct ReactionsView: View {
    var reaction: Reaction
    @State private var images: [ProfilePhoto] = []
    
    var shouldShowAvatars: Bool {
        reaction.count < 3 && !images.isEmpty
    }
    
    var body: some View {
        HStack {
            Text(reaction.emoji)
            
            if shouldShowAvatars {
                avatarsView()
            } else {
                Text("\(reaction.count)")
            }
        }
        .padding(.vertical, 3)
        .padding(.horizontal, 6)
        .background {
            Capsule()
                .foregroundStyle(reaction.isSelected ? .blue : .white.opacity(0.2))
        }
        .task {
            if reaction.count < 3 {
                await loadUserImages()
            }
        }
    }
    
    @ViewBuilder
    func avatarsView() -> some View {
        HStack {
            if images.count >= 1 {
                AvatarView(image: images[0])
                    .frame(width: 20, height: 20)
                    .zIndex(2.0)
            }
            if images.count >= 2 {
                AvatarView(image: images[1])
                    .foregroundStyle(.red)
                    .frame(width: 20, height: 20)
                    .padding(.leading, -15)
                    .zIndex(1.0)
            }
        }
    }
    
    func loadUserImages() async {
        for userId in reaction.recentUsers {
            guard let user = try? await TDLibManager.shared.client?.getUser(userId: userId) else { return }
            guard let photo = user.profilePhoto else { return }
            await MainActor.run {
                images.append(photo)
            }
        }
    }
}

struct Reaction: Hashable {
    let emoji: String
    let count: Int
    let isSelected: Bool
    var recentUsers: [Int64] = []
}

#Preview {
    HStack {
        ReactionsView(reaction: Reaction(emoji: "🔥", count: 3, isSelected: true))
        //ReactionsView(reaction: Reaction(emoji: "👍", count: 2, isSelected: false))
    }
}
