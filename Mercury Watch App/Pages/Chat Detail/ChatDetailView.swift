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
    
    @StateObject var vm: ChatDetailViewModel
    @StateObject var sendMsgVM: SendMessageViewModel
    
    @State var image: Image?
    @State var showAudioMessageView: Bool = false
    
    init(chat: ChatCellModel, useMock: Bool = false) {
        if useMock {
            self._vm = StateObject(wrappedValue: MockChatDetailViewModel(chat: chat))
            self._sendMsgVM = StateObject(wrappedValue: MockSendMessageViewModel(chat: chat))
        } else {
            self._vm = StateObject(wrappedValue: ChatDetailViewModel(chat: chat))
            self._sendMsgVM = StateObject(wrappedValue: SendMessageViewModel(chat: chat))
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
                        MessageView(vm.getMessageVM(for: message))
                            .id(message.id)
                            .scrollTransition(.animated.threshold(.visible(0.2))) { content, phase in
                                content
                                    .scaleEffect(phase.isIdentity ? 1 : 0.7)
                                    .opacity(phase.isIdentity ? 1 : 0)
                            }
                    }
                    .padding(.bottom)
                }
                
            }
            .defaultScrollAnchor(.bottom)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    AvatarView(model: vm.chat.avatar)
                        .onTapGesture {}
                }
                ToolbarItemGroup(placement: .bottomBar) {
                    
                    TextFieldLink {
                        Image(systemName: "keyboard.fill")
                    } onSubmit: { value in
                        sendMsgVM.sendTextMessage(value)
                    }
                    
                    Button("Record", systemImage: "mic.fill") {
                        showAudioMessageView = true
                    }
                    .controlSize(.large)
                    .background {
                        Circle().foregroundStyle(.ultraThinMaterial)
                    }
                    
                    Button("Stickers", systemImage: "face.smiling.inverse") {
                        vm.showStickersView = true
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
        }
        .sheet(isPresented: $showAudioMessageView) {
            AudioMessageView(isPresented: $showAudioMessageView, chat: vm.chat)
        }
        .sheet(isPresented: $vm.showStickersView) {
            AlertView.inDevelopment("stickers are")
        }
    }
    
    func getImage(_ message: Message) async -> Image? {
        switch message.content {
        case .messagePhoto( let msg):
            if let imageFile = msg.photo.sizes.first {
                return await FileService.getImage(for: imageFile.photo)
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
