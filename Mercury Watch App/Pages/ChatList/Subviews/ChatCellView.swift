//
//  ChatCellView.swift
//  Mercury
//
//  Created by Marco Tammaro on 03/11/24.
//

import SwiftUI

struct ChatCellView: View {
    
    let model: ChatCellModel
    let onPressMuteButton: () -> Void
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                AvatarView(model: model.avatar)
                    .frame(width: 50, height: 50)
                VStack(alignment: .leading) {
                    title()
                    HStack {
                        if model.unreadBadgeStyle != nil {
                            unreadBadge()
                        }
                        Text(model.time)
                            .font(.caption)
                            .foregroundStyle(.tertiary)
                    }
                }
                .padding(.leading, 5)
            }
            
            if model.messageStyle != nil {
                messageText()
            }
        }
        .padding(.vertical)
        .swipeActions(
            allowsFullSwipe: false,
            content: muteButton
        )
    }
    
    @ViewBuilder
    func title() -> some View {
        
        let isMutedText = model.isMuted
        ? Text(Image(systemName: "speaker.slash.fill"))
        : Text("")
        
        Group {
            Text(model.title)
                .font(.headline)
            +
            isMutedText
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .lineLimit(2)
    }
    
    @ViewBuilder
    func unreadBadge() -> some View {
        switch model.unreadBadgeStyle {
        case .mention:
            Image(systemName: "at.circle.fill")
                .font(.title3)
                .foregroundStyle(.white, .blue)
            
        case .reaction:
            Image(systemName: "heart.circle.fill")
                .font(.title3)
                .foregroundStyle(.white, .red)
            
        case .message(let count):
            Text("\(count)")
                .font(.system(size: 16))
                .fontDesign(.rounded)
                .fontWeight(.medium)
                .padding(.horizontal, 5)
                .background {
                    let size: CGFloat = 22
                    RoundedRectangle(cornerRadius: size)
                        .frame(height: size)
                        .frame(minWidth: size)
                        .foregroundStyle(.blue)
                }
                .frame(minWidth: 25)
                .padding(.vertical, 1)
            
        default:
            EmptyView()
        }
    }
    
    @ViewBuilder
    func messageText() -> some View {
        switch model.messageStyle {
        case .message(let text):
            Text(text)
                .lineLimit(3)
                .foregroundStyle(.secondary)
        
        case .action(let action):
            HStack(spacing: 10) {
                Image(systemName: "ellipsis")
                    .symbolEffect(
                        .variableColor,
                        isActive: true
                    )
                    .foregroundColor(.blue)
                Text(action)
                    .lineLimit(3)
                    .foregroundColor(.blue)
            }
            
        default:
            EmptyView()
        }
    }
    
    @ViewBuilder
    func muteButton() -> some View {
        Button(action: onPressMuteButton) {
            model.isMuted
                ? Label("Unmute", systemImage: "speaker.wave.3.fill")
                : Label("Mute", systemImage: "speaker.slash.fill")
        }
        .tint(.orange)
    }
}

struct ChatCellModel: Identifiable {
    var id: Int64?
    var position: Int64?
    
    var title: String
    var time: String
    var avatar: AvatarModel
    var isMuted: Bool
    
    var messageStyle: MessageStyle?
    var unreadBadgeStyle: UnreadStyle?
    
    enum MessageStyle {
        case message(_ text: AttributedString)
        case action(_ action: AttributedString)
    }
    
    enum UnreadStyle {
        case mention
        case reaction
        case message(count: Int)
    }
}

#Preview("Plain") {
    let model = ChatCellModel(
        title: "Alessandro",
        time: "09:41",
        avatar: .alessandro,
        isMuted: false,
        messageStyle: nil,
        unreadBadgeStyle: nil
    )
    
    ChatCellView(model: model) {}
}

#Preview("With message") {
    let model = ChatCellModel(
        title: "Alessandro",
        time: "09:41",
        avatar: .alessandro,
        isMuted: false,
        messageStyle: .message("Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua."),
        unreadBadgeStyle: nil
    )
    
    ChatCellView(model: model) {}
}

#Preview("With action") {
    let model = ChatCellModel(
        title: "Alessandro",
        time: "09:41",
        avatar: .alessandro,
        isMuted: false,
        messageStyle: .action("is typing"),
        unreadBadgeStyle: nil
    )
    
    ChatCellView(model: model) {}
}


#Preview("Unread message") {
    let model = ChatCellModel(
        title: "Marco",
        time: "09:41",
        avatar: .marco,
        isMuted: false,
        messageStyle: .message("Lorem ipsum dolor sit amet."),
        unreadBadgeStyle: .message(count: 3)
    )
    
    ChatCellView(model: model) {}
}

#Preview("Unread mention") {
    let model = ChatCellModel(
        title: "Marco",
        time: "09:41",
        avatar: .marco,
        isMuted: false,
        messageStyle: .message("Lorem ipsum dolor sit amet."),
        unreadBadgeStyle: .mention
    )
    
    ChatCellView(model: model) {}
}

#Preview("Unread reaction") {
    let model = ChatCellModel(
        title: "Marco",
        time: "09:41",
        avatar: .marco,
        isMuted: false,
        messageStyle: .message("Lorem ipsum dolor sit amet."),
        unreadBadgeStyle: .reaction
    )
    
    ChatCellView(model: model) {}
}

#Preview("Muted") {
    let model = ChatCellModel(
        title: "A very long chat title",
        time: "09:41",
        avatar: .marco,
        isMuted: true,
        messageStyle: .message("Lorem ipsum dolor sit amet.")
    )
    
    ChatCellView(model: model) {}
}
