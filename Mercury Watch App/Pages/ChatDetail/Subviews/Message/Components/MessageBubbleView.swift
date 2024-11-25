//
//  MessageBubbleView.swift
//  Mercury Watch App
//
//  Created by Alessandro Alberti on 16/07/24.
//

import SwiftUI
import TDLibKit

struct MessageBubbleView<Content> : View where Content : View {
    
    enum BubbleStyle: Equatable {
        case plain
        case fullScreen(caption: String? = nil)
        case clearBackground
    }
    
    let model: MessageModel
    var style: BubbleStyle = .plain
    
    @ViewBuilder var content: () -> Content
    
    var bubbleColor: Color {
        model.stateStyle == .failed ? .red.opacity(0.7) :
        model.isOutgoing ? .blue.opacity(0.7) :
            .white.opacity(0.2)
    }
    
    var isFullscreen: Bool {
        if case .fullScreen(_) = style {
            return true
        } else {
            return false
        }
    }
    
    func shouldShowCaptionBackgroud(_ caption: String?) -> Bool {
        model.reactions.count > 1 || caption?.isEmpty == false
    }
    
    var body: some View {
        
        Group {
            switch style {
                
            case .plain, .clearBackground:
                VStack(alignment: .leading) {
                    
                    if !model.isSenderHidden {
                        senderView()
                    }
                    
                    if let reply = model.reply {
                        ReplyView(model: reply)
                    }
                    
                    content()
                    
                    HStack {
                        reactionsView()
                        // Horizontal spacing for timeView
                        if model.reactions.count <= 1 {
                            Spacer()
                                .frame(width: 80, height: 0)
                        }
                    }
                    
                    // Vertical spacing for timeView
                    if model.reactions.count != 1 {
                        Spacer()
                            .frame(width: 0, height: 20)
                    }
                }
                .overlay {
                    timeView()
                        .frame(
                            maxWidth: .infinity,
                            maxHeight: .infinity,
                            alignment: .bottomTrailing
                        )
                }
                .padding()
                
            case .fullScreen(let caption):
                VStack(alignment: .leading) {
                    
                    content()
                        .overlay {
                            if !model.isSenderHidden {
                                senderView()
                            }
                        }
                    
                    if shouldShowCaptionBackgroud(caption) {
                        VStack(alignment: .leading) {
                            if let caption {
                                Text(caption)
                            }
                            reactionsView()
                            
                            if model.reactions.count != 1 {
                                Spacer()
                                    .frame(width: 0, height: 20)
                            }
                        }
                        .padding(.bottom)
                        .padding(.horizontal)
                    }
                    
                }
                .overlay {
                    FitStack(hAlignment: .bottom) {
                        let isBlurredBg = !shouldShowCaptionBackgroud(caption)
                        if model.reactions.count == 1 {
                            reactionsView(blurredBg: isBlurredBg)
                        }
                        timeView(blurredBg: isBlurredBg)
                            .frame(maxWidth: .infinity, alignment: .trailing)
                    }
                    .frame(
                        maxWidth: .infinity,
                        maxHeight: .infinity,
                        alignment: .bottomLeading
                    )
                    .padding(.bottom)
                    .padding(.horizontal)
                }
            }
        }
        .padding(
            model.isOutgoing ? .trailing : .leading,
            style == .clearBackground ? 0 : 5
        )
        .if(isFullscreen) { view in
            view.clipShape(
                MessageBubbleShape(isOutgoing: model.isOutgoing)
            )
        }
        .background {
            if style != .clearBackground {
                MessageBubbleShape(isOutgoing: model.isOutgoing)
                    .foregroundStyle(bubbleColor)
            }
        }
        .frame(
            maxWidth: .infinity,
            alignment: model.isOutgoing ? .trailing : .leading
        )
    }
    
    // MARK: - SenderView
    @ViewBuilder
    func senderView() -> some View {
        let sender = model.sender ?? "placeholder"
        
        Text(sender)
            .fontWeight(.semibold)
            .foregroundStyle(model.senderColor ?? .clear)
            .redacted(reason: sender == "placeholder" ? .placeholder : [])
            .if(isFullscreen) { view in
                view
                    .frame(
                        maxWidth: .infinity,
                        maxHeight: .infinity,
                        alignment: .topLeading
                    )
                    .padding()
                    .background {
                        ZStack {
                            Rectangle()
                                .foregroundStyle(.ultraThinMaterial)
                            Rectangle()
                                .foregroundStyle(.white.opacity(0.5).blendMode(.overlay))
                        }
                        .frame(height: 35)
                        .frame(maxHeight: .infinity, alignment: .top)
                    }
            }
    }
    
    // MARK: - ReactionsView
    @ViewBuilder
    func reactionsView(blurredBg: Bool = false) -> some View {
        FlowLayout {
            ForEach(model.reactions, id: \.self) { reaction in
                ReactionView(
                    reaction: reaction,
                    avatarMaxNumber: model.reactions.count > 1 ? 2 : 3,
                    blurredBg: blurredBg
                )
                .transition(.opacity
                    .combined(with: .scale(0.5, anchor: .leading))
                )
            }
        }
    }
    
    @ViewBuilder
    func timeView(blurredBg: Bool = false) -> some View {
        HStack {
            Text(model.time)
                .font(.system(size: 15))
                .foregroundStyle(.secondary)
            
            if let style = model.stateStyle {
                StateIconView(style: style)
            }
        }
        .padding(.horizontal, blurredBg ? 5 : 0)
        .padding(.vertical, blurredBg ? 2 : 0)
        .background {
            if blurredBg {
                Capsule()
                    .foregroundStyle(.ultraThinMaterial)
            }
        }
    }
    
}


// MARK: - Previews

#Preview("Plain") {
    ScrollView {
        MessageBubbleView(
            model: .mock(),
            style: .plain
        ) {
            Text("Message")
        }
        MessageBubbleView(
            model: .mock(sender: "Alessandro"),
            style: .plain
        ) {
            Text("Message")
        }
        MessageBubbleView(
            model: .mock(),
            style: .plain
        ) {
            Text("Loooong Message")
        }
        MessageBubbleView(
            model: .mock(reactions: [
                ReactionModel(emoji: "👍", count: 1, isSelected: false),
            ]),
            style: .plain
        ) {
            Text("Reaction")
        }
        MessageBubbleView(
            model: .mock(reactions: [
                ReactionModel(emoji: "👍", count: 3, isSelected: false),
            ]),
            style: .plain
        ) {
            Text("Reaction")
        }
        MessageBubbleView(
            model: .mock(isOutgoing: false, reactions: [
                ReactionModel(emoji: "👍", count: 2, isSelected: false),
                ReactionModel(emoji: "❤️", count: 1, isSelected: true),
            ]),
            style: .plain
        ) {
            Text("Reactions")
        }
        
        MessageBubbleView(
            model: .mock(isOutgoing: false, reactions: [
                ReactionModel(emoji: "👍", count: 2, isSelected: false),
                ReactionModel(emoji: "❤️", count: 1, isSelected: false),
                ReactionModel(emoji: "🔥", count: 1, isSelected: false),
                ReactionModel(emoji: "🎉", count: 1, isSelected: true),
            ]),
            style: .plain
        ) {
            Text("A lot of reactions")
        }
    }
}

#Preview("FullScreen") {
    ScrollView {
        MessageBubbleView(
            model: .mock(),
            style: .fullScreen(caption: "Caption")
        ) {
            Image("astro")
                .resizable()
                .scaledToFill()
        }
        
        MessageBubbleView(
            model: .mock(sender: "Alessandro", reactions: [
                ReactionModel(emoji: "👍", count: 2, isSelected: false)
            ]),
            style: .fullScreen()
        ) {
            Image("astro")
                .resizable()
                .scaledToFill()
        }
        
        MessageBubbleView(
            model: .mock(sender: "Alessandro", reactions: [
                ReactionModel(emoji: "👍", count: 2, isSelected: false),
                ReactionModel(emoji: "❤️", count: 1, isSelected: false),
                ReactionModel(emoji: "🔥", count: 1, isSelected: false),
                ReactionModel(emoji: "🎉", count: 1, isSelected: true),
            ]),
            style: .fullScreen()
        ) {
            Image("astro")
                .resizable()
                .scaledToFill()
        }
        
    }
}

