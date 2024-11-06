//
//  BubbleStyle.swift
//  Mercury Watch App
//
//  Created by Alessandro Alberti on 16/07/24.
//

import SwiftUI
import TDLibKit

struct MessageBubbleView_Old<Content> : View where Content : View {
    @EnvironmentObject var vm: MessageViewModel_Old
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
                    
                    if vm.showReply {
                        ReplyView_Old(message: vm.message)
                    }
                    content()
                    
                    //Spacing for the footerView
                    Spacer()
                        .frame(height: vm.hasReactions ? 30 : 15)
                }
                .frame(minWidth: vm.hasReactions ? 130 : 80, alignment: .leading)
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
        .padding(vm.message.isOutgoing ? .trailing : .leading,
                 style == .hideBackground ? 0 : 5)
        .if(style == .fullScreen) { view in
            view.clipShape(BubbleShape_Old(myMessage: vm.message.isOutgoing))
        }
        .background {
            if style != .hideBackground {
                BubbleShape_Old(myMessage: vm.message.isOutgoing)
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
                ReactionsView_Old(reaction: reaction, blurredBg: blurredBg)
                    .transition(.opacity.combined(with: .scale(0.5, anchor: .leading)))
            }
            
            Spacer()
            
            HStack {
                Text(vm.time)
                    .font(.system(size: 15))
                    .foregroundStyle(.secondary)
                
                switch vm.state {
                case .sending:
                    SendingLoaderView_Old()
                case .delivered:
                    Image(systemName: "checkmark")
                        .font(.footnote)
                case .seen:
                    seenIcon()
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
    
    @ViewBuilder
    func seenIcon() -> some View {
        ZStack {
            Image(systemName: "checkmark")
                .font(.footnote)
                
            Image(systemName: "checkmark")
                .font(.footnote)
                .offset(x: 5)
                .mask(alignment: .leading) {
                    Rectangle()
                        .offset(x: 10, y: -4)
                        .rotationEffect(Angle(degrees: 33))
                        
                }
        }
        .offset(x: -3)
    }
}

#Preview("Regular") {
    VStack {
        MessageBubbleView_Old {
            Text("Hello")
        }
        .environmentObject(
            MessageViewModelMock(
                message: .preview(
                    reaction: .preview(emoji: "👋")
                ),
                name: "Craig Federighi",
                showSender: true
            ) as MessageViewModel_Old
        )
        
        MessageBubbleView_Old {
            Text("World")
        }
        .environmentObject(
            MessageViewModelMock(
                message: .preview(
                    reaction: nil,
                    isOutgoing: true)
            ) as MessageViewModel_Old
        )
    }
}

#Preview("FullScreen") {
    
    return MessageBubbleView_Old(style: .fullScreen) {
        Image("astro")
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
        ) as MessageViewModel_Old
    )
}

#Preview("FullScreen Caption") {
    
    return MessageBubbleView_Old(
        style: .fullScreen,
        caption: "This is a caption") {
            Image("astro")
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
            ) as MessageViewModel_Old
        )
}

#Preview("HideBackground") {
    MessageBubbleView_Old (style: .hideBackground){
        Text("😃")
            .font(.largeTitle)
    }
    .environmentObject(
        MessageViewModelMock(
            name: "Craig Federighi",
            showSender: true
        ) as MessageViewModel_Old
    )
}

#Preview("Status") {
    ScrollView {
        MessageBubbleView_Old {
            Text("Sending test")
        }
        .environmentObject(
            MessageViewModelMock(
                message: .preview(
                    isOutgoing: true),
                state: .sending
            ) as MessageViewModel_Old
        )
        
        MessageBubbleView_Old {
            Text("Delivered test")
        }
        .environmentObject(
            MessageViewModelMock(
                message: .preview(
                    isOutgoing: true),
                state: .delivered
            ) as MessageViewModel_Old
        )
        
        MessageBubbleView_Old {
            Text("Seen test")
        }
        .environmentObject(
            MessageViewModelMock(
                message: .preview(
                    isOutgoing: true),
                state: .seen
            ) as MessageViewModel_Old
        )
        
        MessageBubbleView_Old {
            Text("Failed test")
        }
        .environmentObject(
            MessageViewModelMock(
                message: .preview(
                    isOutgoing: true),
                state: .failed
            ) as MessageViewModel_Old
        )
        
        MessageBubbleView_Old {
            Text("Loading name message")
        }
        .environmentObject(
            MessageViewModelMock(
                name: "placeholder",
                showSender: true
            ) as MessageViewModel_Old
        )
    }
}

