//
//  ChatCellView.swift
//  Mercury Watch App
//
//  Created by Marco Tammaro on 03/11/24.
//

import SwiftUI

struct ChatCellView: View {
    
    let model: ChatCellModel
    let onPressPinButton: () -> Void
    let onPressMuteButton: () -> Void
    var onPressReadButton: () -> Void = {}
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                avatar()
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
            edge: .leading,
            allowsFullSwipe: false,
            content: pinButton
        )
        .swipeActions(
            edge: .trailing,
            allowsFullSwipe: false,
            content: trailingButtons
        )
    }
    
    @ViewBuilder
    func avatar() -> some View {
        AvatarView(model: model.avatar)
            .frame(width: 50, height: 50)
    }
    
    @ViewBuilder
    func title() -> some View {
        
        let isMutedText = model.isMuted
            ? Text(Image(systemName: "speaker.slash.fill"))
            : Text("")
        
        let typeText: Text = switch model.chatType {
        case .savedMessages:  Text("")
        case .secretChat:     Text(Image(systemName: "lock.fill"))
        case .channel:        Text(Image(systemName: "megaphone.fill"))
        case .bot:            Text(Image(systemName: "cpu"))
        case .deletedAccount: Text(Image(systemName: "person.slash.fill"))
        default:              Text("")
        }
        
        let hasTypeIcon = model.chatType != .unknown
            && model.chatType != .privateUser
            && model.chatType != .group
            && model.chatType != .savedMessages
        
        Group {
            if hasTypeIcon {
                typeText
                    .font(.caption2)
                    .foregroundColor(.secondary)
                + Text(" ")
                + Text(model.title)
                    .font(.headline)
                + Text(" ")
                + isMutedText
                    .font(.caption)
                    .foregroundColor(.secondary)
            } else {
                Text(model.title)
                    .font(.headline)
                + Text(" ")
                + isMutedText
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .lineLimit(2)
    }
    
    @ViewBuilder
    func unreadBadge() -> some View {
        let size: CGFloat = 22
        Group {
            switch model.unreadBadgeStyle {
            case .mention:
                Image(systemName: "at.circle.fill")
                    .resizable()
                    .frame(width: size, height: size)
                    .foregroundStyle(.white, .blue)
                
            case .reaction:
                Image(systemName: "heart.circle.fill")
                    .resizable()
                    .frame(width: size, height: size)
                    .foregroundStyle(.white, .red)
                
            case .message(let count):
                Text("\(count)")
                    .font(.system(size: 16))
                    .fontDesign(.rounded)
                    .fontWeight(.medium)
                    .padding(.horizontal, 5)
                    .background {
                        RoundedRectangle(cornerRadius: size)
                            .frame(height: size)
                            .frame(minWidth: size)
                            .foregroundStyle(.blue)
                    }
                
            default:
                EmptyView()
            }
        }
        .frame(minWidth: 25)
        .padding(.vertical, 1)
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
    func pinButton() -> some View {
        Button(action: onPressPinButton) {
            model.isPinned
                ? Label("Unpin", systemImage: "pin.slash.fill")
                : Label("Pin", systemImage: "pin.fill")
        }
        .tint(.green)
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
    
    @ViewBuilder
    func readButton() -> some View {
        Button(action: onPressReadButton) {
            model.isUnread
                ? Label("Read", systemImage: "envelope.open.fill")
                : Label("Unread", systemImage: "envelope.badge.fill")
        }
        .tint(.blue)
    }
    
    @ViewBuilder
    func trailingButtons() -> some View {
        muteButton()
        readButton()
    }
}

// MARK: - Model

struct ChatCellModel: Identifiable {
    
    var id: Int64?
    var messageThreadId: Int64?
    var position: Int64?
    
    var title: String
    var time: String
    var avatar: AvatarModel
    var isMuted: Bool
    var isPinned: Bool
    var isMarkedAsUnread: Bool = false
    
    var messageStyle: MessageStyle?
    var unreadBadgeStyle: UnreadStyle?
    
    var chatType: ChatType = .unknown
    var isForum: Bool? = nil
    
    var isUnread: Bool {
        isMarkedAsUnread || unreadBadgeStyle != nil
    }
    
    // MARK: ChatType
    
    enum ChatType: Equatable {
        case savedMessages
        case privateUser
        case deletedAccount
        case bot
        case secretChat
        case group
        case channel
        case unknown
    }
    
    // MARK: MessageStyle
    
    enum MessageStyle {
        case message(_ text: AttributedString)
        case action(_ action: AttributedString)
    }
    
    // MARK: UnreadStyle
    
    enum UnreadStyle {
        case mention
        case reaction
        case message(count: Int)
    }
}

// MARK: - Hashable

extension ChatCellModel: Hashable {
    public func hash(into hasher: inout Hasher) {
        return hasher.combine(id)
    }

    static func == (lhs: ChatCellModel, rhs: ChatCellModel) -> Bool {
        return lhs.id == rhs.id &&
               lhs.messageThreadId == rhs.messageThreadId &&
               lhs.position == rhs.position &&
               lhs.title == rhs.title &&
               lhs.time == rhs.time &&
               lhs.avatar == rhs.avatar &&
               lhs.isMuted == rhs.isMuted &&
               lhs.isMarkedAsUnread == rhs.isMarkedAsUnread &&
               lhs.messageStyle == rhs.messageStyle &&
               lhs.unreadBadgeStyle == rhs.unreadBadgeStyle &&
               lhs.chatType == rhs.chatType &&
               lhs.isForum == rhs.isForum
    }
}

extension ChatCellModel.MessageStyle: Equatable {
    static func == (lhs: ChatCellModel.MessageStyle, rhs: ChatCellModel.MessageStyle) -> Bool {
        switch (lhs, rhs) {
        case (.message(let t1), .message(let t2)): return t1 == t2
        case (.action(let a1), .action(let a2)):   return a1 == a2
        default: return false
        }
    }
}

extension ChatCellModel.UnreadStyle: Equatable {
    static func == (lhs: ChatCellModel.UnreadStyle, rhs: ChatCellModel.UnreadStyle) -> Bool {
        switch (lhs, rhs) {
        case (.mention, .mention):                         return true
        case (.reaction, .reaction):                       return true
        case (.message(let c1), .message(let c2)):         return c1 == c2
        default:                                           return false
        }
    }
}

// MARK: - Previews

#Preview("Plain") {
    let model = ChatCellModel(
        title: "Alessandro",
        time: "09:41",
        avatar: .alessandro,
        isMuted: false,
        isPinned: false
    )
    ChatCellView(model: model) {} onPressMuteButton: {}
}

#Preview("Saved Messages") {
    let model = ChatCellModel(
        title: "Saved Messages",
        time: "10:00",
        avatar: .alessandro,
        isMuted: false,
        isPinned: true,
        messageStyle: .message("Your cloud storage"),
        chatType: .savedMessages
    )
    ChatCellView(model: model) {} onPressMuteButton: {}
}

#Preview("Secret Chat") {
    let model = ChatCellModel(
        title: "Marco",
        time: "09:41",
        avatar: .marco,
        isMuted: false,
        isPinned: false,
        messageStyle: .message("This is encrypted 🔒"),
        chatType: .secretChat
    )
    ChatCellView(model: model) {} onPressMuteButton: {}
}

#Preview("Bot") {
    let model = ChatCellModel(
        title: "NotificationBot",
        time: "08:00",
        avatar: .marco,
        isMuted: true,
        isPinned: false,
        messageStyle: .message("Your order has shipped!"),
        chatType: .bot
    )
    ChatCellView(model: model) {} onPressMuteButton: {}
}

#Preview("Deleted Account") {
    let model = ChatCellModel(
        title: "Deleted Account",
        time: "Yesterday",
        avatar: .marco,
        isMuted: false,
        isPinned: false,
        messageStyle: .message("This account no longer exists"),
        chatType: .deletedAccount
    )
    ChatCellView(model: model) {} onPressMuteButton: {}
}

#Preview("Channel") {
    let model = ChatCellModel(
        title: "Tech News",
        time: "11:30",
        avatar: .marco,
        isMuted: false,
        isPinned: false,
        messageStyle: .message("New article published"),
        unreadBadgeStyle: .message(count: 12),
        chatType: .channel
    )
    ChatCellView(model: model) {} onPressMuteButton: {}
}

#Preview("With message") {
    let model = ChatCellModel(
        title: "Alessandro",
        time: "09:41",
        avatar: .alessandro,
        isMuted: false,
        isPinned: false,
        messageStyle: .message("Lorem ipsum dolor sit amet, consectetur adipiscing elit.")
    )
    ChatCellView(model: model) {} onPressMuteButton: {}
}

#Preview("Unread message") {
    let model = ChatCellModel(
        title: "Marco",
        time: "09:41",
        avatar: .marco,
        isMuted: false,
        isPinned: false,
        messageStyle: .message("Lorem ipsum dolor sit amet."),
        unreadBadgeStyle: .message(count: 3)
    )
    ChatCellView(model: model) {} onPressMuteButton: {}
}

#Preview("Muted") {
    let model = ChatCellModel(
        title: "A very long chat title",
        time: "09:41",
        avatar: .marco,
        isMuted: true,
        isPinned: false,
        messageStyle: .message("Lorem ipsum dolor sit amet.")
    )
    ChatCellView(model: model) {} onPressMuteButton: {}
}
