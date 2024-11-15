//
//  ReactionView.swift
//  Mercury Watch App
//
//  Created by Alessandro Alberti on 10/08/24.
//

import SwiftUI
import TDLibKit

struct ReactionView: View {
    var reaction: ReactionModel
    var avatarMaxNumber = 3
    var blurredBg: Bool = false
    @State private var images: [TDImage] = []
    
    var shouldShowAvatars: Bool {
        reaction.count <= avatarMaxNumber && !images.isEmpty
    }
    
    var bgColor: AnyShapeStyle {
        reaction.isSelected ? AnyShapeStyle(.blue) :
        AnyShapeStyle(.white
            .opacity(blurredBg ? 0.8 : 0.2)
            .blendMode(blurredBg ? .overlay : .normal)
        )
    }
    
    var body: some View {
        HStack(spacing: 2) {
            Text(reaction.emoji)
                .frame(minWidth: 20)
            
            if shouldShowAvatars {
                avatarsView()
            } else {
                Text("\(reaction.count)")
            }
        }
        .padding(.vertical, 3)
        .padding(.horizontal, 6)
        .background {
            ZStack {
                if blurredBg {
                    Capsule()
                        .foregroundStyle(.ultraThinMaterial)
                }
                Capsule()
                    .foregroundStyle(bgColor)
            }
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
                    .if(index != 0) { view in
                            view.mask {
                                Rectangle()
                                    .overlay {
                                        Circle()
                                            .frame(width: 21, height: 21)
                                            .blendMode(.destinationOut)
                                            .offset(x: -11)
                                    }
                            }
                    }
                    .padding(.leading, index == 0 ? 0 : -8)
                    .zIndex(Double(images.count - index))
                    
            }
        }
    }
    
    func loadUserImages() async {
        
        guard !isPreview else {
            let tmpImages = [TDImageMock("alessandro"), TDImageMock("marco"), TDImageMock("astro")]
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

struct ReactionModel: Hashable {
    let emoji: String
    let count: Int
    let isSelected: Bool
    var recentUsers: [Int64] = []
}

#Preview {
    VStack {
        ReactionView(reaction: ReactionModel(emoji: "🔥", count: 3, isSelected: true))
        ReactionView(reaction: ReactionModel(emoji: "❤️", count: 1, isSelected: false))
        ReactionView(reaction: ReactionModel(emoji: "👍", count: 4, isSelected: false))
    }
    .scaleEffect(1.5)
}



