//
//  ChatView.swift
//  Mercury Watch App
//
//  Created by Alessandro Alberti on 14/05/24.
//

import SwiftUI
import Combine
import TDLibKit

struct ChatDetailView: View {
    @StateObject var vm: ChatDetailViewModel_Old
    @State var image: Image?
    
    init(chat: ChatCellModel_Old, useMock: Bool = false) {
        if useMock {
            self._vm = StateObject(wrappedValue: MockChatDetailViewModel(chat: chat))
        } else {
            self._vm = StateObject(wrappedValue: ChatDetailViewModel_Old(chat: chat))
        }
    }
    
    var body: some View {
        ScrollViewReader { proxy in
            ScrollView {
                
                if vm.isLoadingInitialMessages {
                    ProgressView()
                } else {
                    
                    Button("Load more") {
                        Task {
                            let lastMessage = vm.messages.first
                            await vm.requestMoreMessages()
                            DispatchQueue.main.async {
                                proxy.scrollTo(lastMessage?.id, anchor: .bottom)
                            }
                        }
                    }
                    .padding()
                 
                    ForEach(vm.messages) { message in
                        MessageView_Old(message: message, chat: vm.chat)
                            .id(message.id)
                            .scrollTransition(.animated.threshold(.visible(0.2))) { content, phase in
                                content
                                    .scaleEffect(phase.isIdentity ? 1 : 0.7)
                                    .opacity(phase.isIdentity ? 1 : 0)
                            }
                            .onAppear {
                                vm.didVisualize(message.id)
                            }
                            .onTapGesture(count: 2) {
                                vm.selectedMessage = message
                                vm.showOptionsView = true
                            }

                    }
                    .padding(.bottom)
                    .onAppear {
                        // Scroll to the first unread message
                        let lastReadInboxMessageId = vm.chat.lastReadInboxMessageId
                        for message in vm.messages {
                            if message.id >= lastReadInboxMessageId {
                                proxy.scrollTo(message.id)
                                break
                            }
                        }
                    }
                }
                
            }
            .defaultScrollAnchor(.bottom)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    AvatarView_Old(model: vm.chat.avatar)
                        .onTapGesture {}
                }
                ToolbarItemGroup(placement: .bottomBar) {
                    
                    if vm.canSendText {
                        Button("Stickers", systemImage: "keyboard.fill") {
                            vm.showInputController()
                        }
                    }
                    
                    if vm.canSendVoiceNotes {
                        Button("Record", systemImage: "mic.fill") {
                            vm.showVoiceRecording()
                        }
                        .controlSize(.large)
                        .background {
                            Circle().foregroundStyle(.ultraThinMaterial)
                        }
                    }
                    
                    if vm.canSendStickers {
                        Button("Stickers", systemImage: "face.smiling.inverse") {
                            vm.showStickersSelection()
                        }
                    }
                    
                }
            }
            .containerBackground(for: .navigation){
                Rectangle()
                    .foregroundStyle(
                        Gradient(colors: [
                            .blue.opacity(0.5),
                            .blue.opacity(0.1)
                        ])
                    )
            }
            .navigationTitle {
                Text(vm.chat.td.title)
                    .foregroundStyle(.white)
            }
            .onAppear(perform: vm.onOpenChat)
            .onDisappear(perform: vm.onCloseChat)

        }
        .sheet(isPresented: $vm.showAudioMessageView) {
            AudioMessageView_Old(isPresented: $vm.showAudioMessageView, action: $vm.chatAction, chat: vm.chat) { filePath, duration in
                vm.sendService.sendVoiceNote(filePath, Int(duration))
            }
        }
        .sheet(isPresented: $vm.showStickersView) {
            AlertView.inDevelopment("stickers are")
        }
        .sheet(isPresented: $vm.showOptionsView) {
            MessageOptionsView_Old(isPresented: $vm.showOptionsView, message: vm.selectedMessage ?? .preview(), chat: vm.chat.td)
        }
    }
    
    func getImage(_ message: Message) async -> Image? {
        switch message.content {
        case .messagePhoto( let msg):
            if let imageFile = msg.photo.sizes.first {
                guard let uiImage = await FileService.getImage(for: imageFile.photo)
                else { return nil }
                return Image(uiImage: uiImage)
            }
            return nil
        default:
            return nil
        }
        
    }
    
}

#Preview {
    NavigationStack {
        ChatDetailView(
            chat: .preview(
                title: "iOS Devs",
                sender: "Alessandro",
                color: .orange
            ),
            useMock: true)
    }
    
}
