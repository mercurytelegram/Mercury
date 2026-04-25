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
    @State private var activeVideoNoteId: Int64? = nil
    @State private var activeVideoNote: VideoNoteModel? = nil

    private var isVideoNoteViewerPresented: Bool {
        activeVideoNote != nil
    }

    init(chatId: Int64) {
        _vm = Mockable.state(
            value: { ChatDetailViewModel(chatId: chatId) },
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
                sendService: vm.sendService
            )
        }
        .sheet(isPresented: $vm.showAudioMessageView) {
            if let sendService = vm.sendService {
                VoiceNoteRecordSubpage(
                    isPresented: $vm.showAudioMessageView,
                    action: $vm.chatAction,
                    sendService: sendService
                )
            }
        }
        .sheet(isPresented: $vm.showOptionsView) {
            if let messageId = vm.selectedMessage?.id, let sendService = vm.sendService {
                MessageOptionsSubpage(
                    isPresented: $vm.showOptionsView,
                    model: .init(
                        chatId: vm.chatId,
                        messageId: messageId,
                        sendService: sendService,
                        chatType: vm.chatType
                    )
                )
            }
        }
    }

    @ViewBuilder
    func messageList() -> some View {
        ForEach(vm.messages) { message in
            MessageView(
                model: message,
                onVideoNoteOpen: { videoNote in
                    openVideoNote(videoNote, messageId: message.id)
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
    func toolbarActions() -> some View {
        if vm.canSendText ?? false {
            Button("Stickers", systemImage: "keyboard.fill") {
                vm.onPressTextInsert()
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

#Preview(traits: .mock()) {
    NavigationView {
        ChatDetailPage(chatId: 0)
    }
}