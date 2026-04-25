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
    
    init(chatId: Int64) {
        _vm = Mockable.state(
            value: { ChatDetailViewModel(chatId: chatId) },
            mock: { ChatDetailViewModelMock() }
        )
    }
    
    var body: some View {
        
        ScrollViewReader { proxy in
            
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
                }
            }
            .toolbar {
                
                if let avatar = vm.avatar {
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
                Text(vm.chatName ?? "")
                    .foregroundStyle(.white)
            }
            .toolbarForegroundStyle(.white, for: .navigationBar)
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
            MessageView(model: message)
                .id(message.id)
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
    
}

#Preview(traits: .mock()) {
    NavigationView {
        ChatDetailPage(chatId: 0)
    }
}
