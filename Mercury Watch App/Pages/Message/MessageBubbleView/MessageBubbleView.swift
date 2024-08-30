//
//  BubbleStyle.swift
//  Mercury Watch App
//
//  Created by Alessandro Alberti on 16/07/24.
//

import SwiftUI
import TDLibKit

struct MessageBubbleView<Content> : View where Content : View {
    @EnvironmentObject var vm: MessageViewModel
    var style: BubbleStyle = .regular
    var caption: String = ""
    @ViewBuilder var content: () -> Content
    
    var body: some View {
        Group {
            // MARK: Regular
            if style != .fullScreen {
                VStack(alignment: .leading){
                    if vm.showSender {
                        senderView()
                    }
                    content()
                    
                    //Spacing for the footerView
                    Spacer()
                        .frame(height: vm.hasReactions ? 30 : 15)
                }
                .frame(minWidth: vm.hasReactions ? 130 : 50, alignment: .leading)
                .overlay {
                    footerView()
                        .frame(maxHeight: .infinity, alignment: .bottom)
                }
                .padding()
                
            } else {
                // MARK: FullScreen
                VStack(alignment: .leading) {
                    content()
                        .overlay {
                            senderView()
                        }
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
                            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomLeading)
                            .padding()
                    }
                }
            }
        }
        .padding(vm.message.isOutgoing ? .trailing : .leading, 5)
        .if(style == .fullScreen) { view in
            view.clipShape(BubbleShape(myMessage: vm.message.isOutgoing))
        }
        .background {
            if style != .hideBackground {
                BubbleShape(myMessage: vm.message.isOutgoing)
                    .foregroundStyle(vm.bubbleColor)
            }        }
        .frame(maxWidth: .infinity, alignment: vm.message.isOutgoing ? .trailing : .leading)
    }
    
    @ViewBuilder
    func senderView() -> some View {
        Text(vm.userFullName)
            .fontWeight(.semibold)
            .foregroundStyle(vm.titleColor)
            .redacted(reason: vm.userNameRedaction)
            .if(style == .fullScreen) { view in
                view
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
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
            ForEach(vm.reactions, id: \.self){ reaction in
                ReactionsView(reaction: reaction, blurredBg: blurredBg)
                    .transition(.opacity.combined(with: .scale(0.5, anchor: .leading)))
            }
            
            Spacer()
            
            HStack {
                Text(vm.time)
                    .font(.system(size: 15))
                    .foregroundStyle(.secondary)
                
                switch vm.state {
                case .sending:
                    SendingLoaderView()
                case .delivered:
                    Image(systemName: "checkmark")
                        .font(.footnote)
                case .seen:
                    Image(systemName: "eye.fill")
                        .font(.footnote)
                case .failed:
                    Image(systemName: "exclamationmark.circle.fill")
                case .none:
                    EmptyView()
                }
            }
        }
    }
    
    enum BubbleStyle {
        case regular, fullScreen, hideBackground
    }
}

#Preview("Regular") {
    VStack {
        MessageBubbleView {
            Text("Hello")
        }
        .environmentObject(
            MessageViewModelMock(
                message: .preview(
                    reaction: .preview(emoji: "👋")
                ),
                name: "Craig Federighi",
                showSender: true
            ) as MessageViewModel
        )
        
        MessageBubbleView {
            Text("World")
        }
        .environmentObject(
            MessageViewModelMock(
                message: .preview(
                    reaction: nil,
                    isOutgoing: true)
            ) as MessageViewModel
        )
    }
}

#Preview("FullScreen") {
    
    return MessageBubbleView(style: .fullScreen) {
        Image("craig")
            .resizable()
            .aspectRatio(contentMode: .fill)
            .frame(height: 150)
    }
    .environmentObject(
        MessageViewModelMock(
            message: .preview(
                reaction: .preview(count: 3)
            ),
            name: "Craig Federighi",
            showSender: true
        ) as MessageViewModel
    )
}

#Preview("FullScreen Caption") {
    
    return MessageBubbleView(
        style: .fullScreen,
        caption: "This is a caption") {
            Image("craig")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(height: 100)
                .clipped()
        }
        .environmentObject(
            MessageViewModelMock(
                message: .preview(
                    isOutgoing: true),
                name: "Craig Federighi",
                showSender: true
            ) as MessageViewModel
        )
}

#Preview("HideBackground") {
    MessageBubbleView (style: .hideBackground){
        Text("😃")
            .font(.largeTitle)
    }
    .environmentObject(
        MessageViewModelMock(
            name: "Craig Federighi",
            showSender: true
        ) as MessageViewModel
    )
}

#Preview("Status") {
    ScrollView {
        MessageBubbleView {
            Text("Sending test")
        }
        .environmentObject(
            MessageViewModelMock(
                message: .preview(
                    isOutgoing: true),
                state: .sending
            ) as MessageViewModel
        )
        
        MessageBubbleView {
            Text("Delivered test")
        }
        .environmentObject(
            MessageViewModelMock(
                message: .preview(
                    isOutgoing: true),
                state: .delivered
            ) as MessageViewModel
        )
        
        MessageBubbleView {
            Text("Failed test")
        }
        .environmentObject(
            MessageViewModelMock(
                message: .preview(
                    isOutgoing: true),
                state: .failed
            ) as MessageViewModel
        )
        
        MessageBubbleView {
            Text("Loading name message")
        }
        .environmentObject(
            MessageViewModelMock(
                name: "placeholder",
                showSender: true
            ) as MessageViewModel
        )
    }
}

