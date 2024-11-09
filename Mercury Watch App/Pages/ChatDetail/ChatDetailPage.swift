//
//  LoginPage.swift
//  Mercury Watch App
//
//  Created by Marco Tammaro on 02/11/24.
//

import SwiftUI

struct ChatDetailPage: View {
    
    @State
    @Mockable(mockInit: ChatDetailViewModel.init)
    var vm = ChatDetailViewModel.init
    
    init(chatId: Int64?) {
        vm.chatId = chatId
    }
    
    var body: some View {
        
        ScrollViewReader { proxy in
            ScrollView {
                
                if vm.isLoadingInitialMessages {
                    ProgressView()
                } else {
                    
                    Button("Load more") {
                        vm.onPressLoadMore(proxy)
                    }
                    .padding()
                    
                   messageList()
                        .onAppear { vm.onMessageListAppear(proxy) }
                        .padding(.bottom)
                }
                
            }
            .defaultScrollAnchor(.bottom)
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
                    toolbarActions()
                }
            }
            .containerBackground(for: .navigation) {
                background()
            }
            .navigationTitle {
                Text(vm.chatName ?? "")
                    .foregroundStyle(.white)
            }
            .onAppear(perform: vm.onOpenChat)
            .onDisappear(perform: vm.onCloseChat)
            
        }
        .sheet(isPresented: $vm.showChatInfoView) {
            AlertView.inDevelopment("chat info is")
        }
        .sheet(isPresented: $vm.showStickersView) {
            AlertView.inDevelopment("stickers are")
        }
//        .sheet(isPresented: $vm.showAudioMessageView) {
//            AudioMessageView(isPresented: $vm.showAudioMessageView, action: $vm.chatAction, chat: vm.chat) { filePath, duration in
//                vm.sendService.sendVoiceNote(filePath, Int(duration))
//            }
//        }
//        .sheet(isPresented: $vm.showOptionsView) {
//            MessageOptionsView(isPresented: $vm.showOptionsView, message: vm.selectedMessage ?? .preview(), chat: vm.chat.td)
//        }
        
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
                    vm.onMessageAppear(message.id)
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
                .blue.opacity(0.5),
                .blue.opacity(0.1)
            ]
        )
        
        Rectangle()
            .foregroundStyle(gradient)
    }
    
}

#Preview {
    ChatDetailPage(chatId: 0)
}
