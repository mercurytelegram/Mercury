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
    @State private var images: [TDImage] = []
    
    var shouldShowAvatars: Bool {
        reaction.count <= 3 && !images.isEmpty
    }
    
    var body: some View {
        HStack(spacing: 2) {
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
            if reaction.count <= 3 {
                await loadUserImages()
            }
        }
    }
    
    @ViewBuilder
    func avatarsView() -> some View {
        HStack(spacing: 0) {
            ForEach(images.indices, id: \.self) { index in
                AvatarView(image: images[index])
                    .frame(width: 20, height: 20)
                    .padding(.leading, index == 0 ? 0 : -10)
                    .zIndex(Double(images.count - index))
            }
        }
    }
    
    func loadUserImages() async {
        
        guard !isPreview else {
            let tmpImages = [TDImageMock("tim"), TDImageMock("craig"), TDImageMock("lisa")]
            for i in 0 ..< reaction.count {
                images.append(tmpImages[i])
            }
            return
        }
        
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
    VStack {
        ReactionsView(reaction: Reaction(emoji: "🔥", count: 3, isSelected: true))
        ReactionsView(reaction: Reaction(emoji: "❤️", count: 1, isSelected: false))
        ReactionsView(reaction: Reaction(emoji: "👍", count: 4, isSelected: false))
    }
    .scaleEffect(1.5)
}



