//
//  LoginPage.swift
//  Mercury Watch App
//
//  Created by Marco Tammaro on 02/11/24.
//

import SwiftUI

struct ChatDetailPage: View {

    @State
    @Mockable
    var vm: ChatDetailViewModel
    let onOpenURL: ((URL) -> OpenURLAction.Result)?
    @State private var activeVideoNoteId: Int64? = nil
    @State private var activeVideoNote: VideoNoteModel? = nil

    private var isVideoNoteViewerPresented: Bool {
        activeVideoNote != nil
    }

    init(
        chatId: Int64,
        messageThreadId: Int64? = nil,
        onOpenURL: ((URL) -> OpenURLAction.Result)? = nil
    ) {
        self.onOpenURL = onOpenURL
        _vm = Mockable.state(
            value: { ChatDetailViewModel(chatId: chatId, messageThreadId: messageThreadId) },
            mock: { ChatDetailViewModelMock() }
        )
    }

    var body: some View {

        ScrollViewReader { proxy in

            ZStack {
                Group {
                    if vm.isLoadingInitialMessages {
                        ProgressView()
                    } else {
                        ScrollView {

                            if vm.isLoadingMoreMessages {
                                ProgressView()
                            } else {
                                Button("Load more") {
                                    vm.onPressLoadMore(proxy)
                                }
                            }

                            messageList()
                                .onAppear { vm.onMessageListAppear(proxy) }
                                .padding(.vertical, 2)

                        }
                        .defaultScrollAnchor(.bottom)
                        .scrollDisabled(isVideoNoteViewerPresented)
                    }
                }
                .blur(radius: isVideoNoteViewerPresented ? 8 : 0)

                if let activeVideoNote {
                    VideoNoteViewerOverlay(
                        model: activeVideoNote,
                        onDismiss: { closeVideoNote() }
                    )
                }
                
                if !isVideoNoteViewerPresented {
                    VStack {
                        if let pinnedMessage = vm.pinnedMessage {
                            pinnedMessageBanner(pinnedMessage, proxy: proxy)
                        }
                        Spacer()
                        if let replyToMessage = vm.replyToMessage {
                            replyComposerBanner(replyToMessage)
                        }
                    }
                    .padding(.horizontal, 4)
                }
            }
            .navigationBarBackButtonHidden(isVideoNoteViewerPresented)
            .toolbar {

                ToolbarItem(placement: .topBarLeading) {
                    if isVideoNoteViewerPresented {
                        Button {
                            closeVideoNote()
                        } label: {
                            viewerBackButtonLabel()
                        }
                        .buttonStyle(.plain)
                    }
                }

                if !isVideoNoteViewerPresented, let avatar = vm.avatar {
                    ToolbarItem(placement: .topBarTrailing) {
                        AvatarView(model: avatar)
                            .onTapGesture {
                                vm.onPressAvatar()
                            }
                    }
                }

                ToolbarItemGroup(placement: .bottomBar) {
                    if !vm.isChatBlocked { toolbarActions() }
                }
            }
            .containerBackground(for: .navigation) {
                background()
            }
            .navigationTitle {
                Text(isVideoNoteViewerPresented ? "" : vm.chatName ?? "")
                    .foregroundStyle(.white)
            }
            .toolbarForegroundStyle(.white, for: .navigationBar)
            .toolbar(
                isVideoNoteViewerPresented ? .hidden : .automatic,
                for: .bottomBar
            )
            .onAppear(perform: vm.onOpenChat)
            .onDisappear(perform: vm.onCloseChat)
        }
        .overlay {
            if vm.isChatBlocked {
                blockView()
            } else if vm.canJoinChat {
                joinView()
            }
        }
        .sheet(isPresented: $vm.showChatInfoView) {
            if let profileDetailType = vm.getProfileDetailPageType() {
                ProfileDetailPage(type: profileDetailType)
            }
        }
        .sheet(isPresented: $vm.showStickersView) {
            StickersPickerSubpage(
                isPresented: $vm.showStickersView,
                sendService: vm.sendService,
                replyTo: vm.inputReplyToMessage(),
                onSent: vm.clearReply
            )
        }
        .sheet(isPresented: $vm.showAudioMessageView) {
            if let sendService = vm.sendService {
                VoiceNoteRecordSubpage(
                    isPresented: $vm.showAudioMessageView,
                    action: $vm.chatAction,
                    sendService: sendService,
                    replyTo: vm.inputReplyToMessage(),
                    onSent: vm.clearReply
                )
            }
        }
        .sheet(isPresented: $vm.showQuickRepliesView) {
            QuickRepliesSubpage(
                replies: vm.quickReplyTemplates,
                onSelectReply: vm.sendQuickReply
            )
        }
        .sheet(isPresented: $vm.showOptionsView) {
            if let messageId = vm.selectedMessage?.id, let sendService = vm.sendService {
                MessageOptionsSubpage(
                    isPresented: $vm.showOptionsView,
                    model: .init(
                        chatId: vm.chatId,
                        messageId: messageId,
                        sendService: sendService,
                        chatType: vm.chatType,
                        onReply: {
                            if let selectedMessage = vm.selectedMessage {
                                vm.didSelectReply(to: selectedMessage)
                            }
                        },
                        onDeleted: {
                            if let selectedMessage = vm.selectedMessage {
                                vm.messages.removeAll { $0.id == selectedMessage.id }
                            }
                        },
                        onPinned: {
                            Task { await vm.loadPinnedMessage() }
                        }
                    )
                )
            }
        }
        .environment(\.openURL, OpenURLAction { url in
            onOpenURL?(url) ?? .systemAction
        })
    }

    @ViewBuilder
    func messageList() -> some View {
        ForEach(vm.messages) { message in
            MessageView(
                model: message,
                onVideoNoteOpen: { videoNote in
                    openVideoNote(videoNote, messageId: message.id)
                },
                onOpenOptions: {
                    vm.openMessageOptions(for: message)
                },
                onReactionTap: { reaction in
                    vm.toggleReaction(reaction, on: message)
                }
            )
                .id(message.id)
                .opacity(activeVideoNoteId == message.id ? 0 : 1)
                .zIndex(message.content.isVideoNote ? 1 : 0)
                .scrollTransition(.animated.threshold(.visible(0.2))) { content, phase in
                    content
                        .scaleEffect(phase.isIdentity ? 1 : 0.7)
                        .opacity(phase.isIdentity ? 1 : 0)
                }
                .onAppear {
                    vm.onMessageAppear(message)
                }
                .onTapGesture(count: 2) {
                    vm.onDublePressOf(message)
                }
                .contentShape(Rectangle())
                .simultaneousGesture(
                    LongPressGesture(minimumDuration: 0.45)
                        .onEnded { _ in
                            vm.openMessageOptions(for: message)
                        }
                )
        }
    }

    private func openVideoNote(_ model: VideoNoteModel, messageId: Int64) {
        activeVideoNoteId = messageId
        activeVideoNote = model
    }

    private func closeVideoNote() {
        activeVideoNoteId = nil
        activeVideoNote = nil
    }
    
    @ViewBuilder
    private func pinnedMessageBanner(_ message: MessageModel, proxy: ScrollViewProxy) -> some View {
        Button {
            vm.scrollToPinnedMessage(proxy)
        } label: {
            HStack(spacing: 4) {
                Image(systemName: "pin.fill")
                    .font(.system(size: 8, weight: .semibold))
                Text(message.content.previewText)
                    .lineLimit(1)
                    .font(.system(size: 9, weight: .medium))
            }
            .frame(maxWidth: 96)
            .padding(.horizontal, 6)
            .padding(.vertical, 2)
            .background(.thinMaterial)
            .clipShape(Capsule())
        }
        .buttonStyle(.plain)
    }
    
    @ViewBuilder
    private func replyComposerBanner(_ message: MessageModel) -> some View {
        HStack(spacing: 6) {
            Image(systemName: "arrowshape.turn.up.left.fill")
                .foregroundStyle(.blue)
            Text(message.content.previewText)
                .font(.caption2)
                .lineLimit(1)
            Spacer(minLength: 4)
            Button("Cancel", systemImage: "xmark") {
                vm.clearReply()
            }
            .labelStyle(.iconOnly)
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 5)
        .background(.thinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }

    @ViewBuilder
    func toolbarActions() -> some View {
        if vm.canSendText ?? false {
            Button("Text", systemImage: "keyboard.fill") {
                vm.onPressTextInsert()
            }
            
            Button("Replies", systemImage: "text.bubble.fill") {
                vm.onPressQuickReplies()
            }
        }

        if vm.canSendVoiceNotes ?? false {
            Button("Record", systemImage: "mic.fill") {
                vm.onPressVoiceRecording()
            }
            .controlSize(.large)
            .background {
                Circle().foregroundStyle(.ultraThinMaterial)
            }
        }

        if vm.canSendStickers ?? false {
            Button("Stickers", systemImage: "face.smiling.inverse") {
                vm.onPressStickersSelection()
            }
        }
    }

    @ViewBuilder
    func background() -> some View {

        let gradient = Gradient(
            colors: [
                .bgBlue,
                .bgBlue.opacity(0.2)
            ]
        )

        Rectangle()
            .foregroundStyle(gradient)
    }

    @ViewBuilder
    private func blockView() -> some View {
        VStack {
            Text("You've blocked this user. Messaging is currently disabled.")
                .foregroundStyle(.secondary)
                .padding(.bottom)
                .multilineTextAlignment(.center)

            Button(action: vm.unblockUser, label: {
                Label("Unblock", systemImage: "lock.open.fill")
            })
            .tint(.red)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
        .background {
            Rectangle()
                .fill(.thinMaterial)
                .ignoresSafeArea()
        }

    }
    
    @ViewBuilder
    private func joinView() -> some View {
        VStack {
            Spacer()
            Button {
                vm.joinChat()
            } label: {
                Label(vm.isJoiningChat ? "Joining..." : "Join", systemImage: "person.badge.plus.fill")
            }
            .disabled(vm.isJoiningChat)
            .controlSize(.large)
            .tint(.blue)
            .padding(.bottom)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background {
            Rectangle()
                .fill(.thinMaterial)
                .ignoresSafeArea()
        }
    }

    @ViewBuilder
    private func viewerBackButtonLabel() -> some View {
        let label = Image(systemName: "chevron.left")
            .font(.system(size: 18, weight: .semibold))
            .foregroundStyle(.white)
            .frame(width: 40, height: 40)

        if #available(watchOS 26.0, *) {
            label.glassEffect(.regular, in: Circle())
        } else {
            label
                .background(.ultraThinMaterial, in: Circle())
                .overlay {
                    Circle()
                        .stroke(.white.opacity(0.2), lineWidth: 1)
                }
        }
    }

}

private extension MessageModel.MessageContent {
    var previewText: AttributedString {
        switch self {
        case .text(let text):
            return text
        case .voiceNote:
            return "Voice message"
        case .photo(_, let caption):
            return caption ?? "Photo"
        case .photoAlbum(_, let caption):
            return caption ?? "Photo album"
        case .videoNote:
            return "Video message"
        case .stickerImage(let model):
            return model.emoji.isEmpty ? "Sticker" : AttributedString(model.emoji)
        case .location:
            return "Location"
        case .animation(_, let caption):
            return caption ?? "GIF"
        case .pill(_, _):
            return "Service message"
        }
    }
}

private struct VideoNoteViewerOverlay: View {
    let model: VideoNoteModel
    let onDismiss: () -> Void

    var body: some View {
        ZStack(alignment: .top) {
            Rectangle()
                .fill(.ultraThinMaterial)
                .ignoresSafeArea()

            Color.black.opacity(0.22)
                .ignoresSafeArea()

            VideoNoteView(
                model: model,
                autoplay: true,
                showsCloseButton: false,
                onExpansionChange: { isExpanded in
                    if !isExpanded {
                        onDismiss()
                    }
                },
                onClose: onDismiss
            )
            .frame(maxWidth: .infinity)
            .padding(.top, 42)
        }
        .transition(.opacity.combined(with: .scale(scale: 0.92)))
    }
}

private struct QuickRepliesSubpage: View {
    let replies: [String]
    let onSelectReply: (String) -> Void
    
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            List(replies, id: \.self) { reply in
                Button {
                    onSelectReply(reply)
                    dismiss()
                } label: {
                    Label(reply, systemImage: "arrow.up.message.fill")
                }
            }
            .navigationTitle("Quick Replies")
        }
    }
}

#Preview(traits: .mock()) {
    NavigationView {
        ChatDetailPage(chatId: 0)
    }
}
