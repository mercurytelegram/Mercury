//
//  BubbleStyle.swift
//  Mercury Watch App
//
//  Created by Alessandro Alberti on 16/07/24.
//

import SwiftUI
import TDLibKit

struct MessageBubbleView<Content> : View where Content : View {
    
    enum BubbleStyle: Equatable {
        case plain
        case fullScreen(caption: String)
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
    
    var body: some View {
        
        Group {
            switch style {
                
            case .plain, .clearBackground:
                VStack(alignment: .leading) {
                    
                    if model.sender != nil {
                        senderView()
                    }
                    
                    if let reply = model.reply {
                        ReplyView(model: reply)
                    }
                    
                    content()
                    
                    //Spacing for the footerView
                    Spacer()
                        .frame(height: model.reactions.isEmpty ? 15 : 30)
                }
                .frame(
                    minWidth: model.reactions.isEmpty ? 80 : 130,
                    alignment: .leading
                )
                .overlay {
                    footerView()
                        .frame(
                            maxHeight: .infinity,
                            alignment: .bottom
                        )
                }
                .padding()
                
            case .fullScreen(let caption):
                VStack(alignment: .leading) {
                    
                    content()
                        .overlay { senderView() }
                    
                    if !caption.isEmpty {
                        VStack(alignment: .leading) {
                            Text(caption)
                            footerView()
                        }
                        .padding(.bottom)
                        .padding(.horizontal)
                    }
                    
                }
                .overlay {
                    if caption.isEmpty {
                        footerView(blurredBg: true)
                            .frame(
                                maxWidth: .infinity,
                                maxHeight: .infinity,
                                alignment: .bottomLeading
                            )
                            .padding()
                    }
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
    
    @ViewBuilder
    func senderView() -> some View {
        let sender = model.sender ?? "placeholder"
        
        Text(sender)
            .fontWeight(.semibold)
            .foregroundStyle(model.senderColor)
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
    
    @ViewBuilder
    func footerView(blurredBg: Bool = false) -> some View {
        HStack(alignment: .bottom) {
            ForEach(model.reactions, id: \.self) { reaction in
                ReactionView(
                    reaction: reaction,
                    blurredBg: blurredBg
                )
                .transition(.opacity
                    .combined(with: .scale(0.5, anchor: .leading))
                )
            }
            
            Spacer()
            
            HStack {
                Text(model.time)
                    .font(.system(size: 15))
                    .foregroundStyle(.secondary)
                
                if let style = model.stateStyle {
                    StateIconView(style: style)
                }
            }
        }
    }
    
}

//#Preview("Regular") {
//    VStack {
//        MessageBubbleView {
//            Text("Hello")
//        }
//        .environmentObject(
//            MessageViewModelMock(
//                message: .preview(
//                    reaction: .preview(emoji: "👋")
//                ),
//                name: "Craig Federighi",
//                showSender: true
//            ) as MessageViewModel
//        )
//        
//        MessageBubbleView {
//            Text("World")
//        }
//        .environmentObject(
//            MessageViewModelMock(
//                message: .preview(
//                    reaction: nil,
//                    isOutgoing: true)
//            ) as MessageViewModel
//        )
//    }
//}
//
//#Preview("FullScreen") {
//    
//    return MessageBubbleView(style: .fullScreen) {
//        Image("astro")
//            .resizable()
//            .aspectRatio(contentMode: .fill)
//            .frame(height: 150)
//    }
//    .environmentObject(
//        MessageViewModelMock(
//            message: .preview(
//                reaction: .preview(count: 3)
//            ),
//            name: "Craig Federighi",
//            showSender: true
//        ) as MessageViewModel
//    )
//}
//
//#Preview("FullScreen Caption") {
//    
//    return MessageBubbleView(
//        style: .fullScreen,
//        caption: "This is a caption") {
//            Image("astro")
//                .resizable()
//                .aspectRatio(contentMode: .fill)
//                .frame(height: 100)
//                .clipped()
//        }
//        .environmentObject(
//            MessageViewModelMock(
//                message: .preview(
//                    isOutgoing: true),
//                name: "Craig Federighi",
//                showSender: true
//            ) as MessageViewModel
//        )
//}
//
//#Preview("HideBackground") {
//    MessageBubbleView (style: .hideBackground){
//        Text("😃")
//            .font(.largeTitle)
//    }
//    .environmentObject(
//        MessageViewModelMock(
//            name: "Craig Federighi",
//            showSender: true
//        ) as MessageViewModel
//    )
//}
//
//#Preview("Status") {
//    ScrollView {
//        MessageBubbleView {
//            Text("Sending test")
//        }
//        .environmentObject(
//            MessageViewModelMock(
//                message: .preview(
//                    isOutgoing: true),
//                state: .sending
//            ) as MessageViewModel
//        )
//        
//        MessageBubbleView {
//            Text("Delivered test")
//        }
//        .environmentObject(
//            MessageViewModelMock(
//                message: .preview(
//                    isOutgoing: true),
//                state: .delivered
//            ) as MessageViewModel
//        )
//        
//        MessageBubbleView {
//            Text("Seen test")
//        }
//        .environmentObject(
//            MessageViewModelMock(
//                message: .preview(
//                    isOutgoing: true),
//                state: .seen
//            ) as MessageViewModel
//        )
//        
//        MessageBubbleView {
//            Text("Failed test")
//        }
//        .environmentObject(
//            MessageViewModelMock(
//                message: .preview(
//                    isOutgoing: true),
//                state: .failed
//            ) as MessageViewModel
//        )
//        
//        MessageBubbleView {
//            Text("Loading name message")
//        }
//        .environmentObject(
//            MessageViewModelMock(
//                name: "placeholder",
//                showSender: true
//            ) as MessageViewModel
//        )
//    }
//}
//
