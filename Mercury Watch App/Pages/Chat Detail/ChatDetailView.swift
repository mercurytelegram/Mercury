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
                    }.padding()
                 
                    ForEach(vm.messages) { message in
                        MessageView(vm.getMessageVM(for: message))
                            .id(message.id)
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
                    
                    Button("Record", systemImage: "mic.fill") {}
                        .controlSize(.large)
                    
                    Button("Stickers", systemImage: "face.smiling.inverse") {}
                }
            }
            .background {
                
                Rectangle()
                    .foregroundStyle(
                        Gradient(colors: [
                            .blue.opacity(0.7),
                            .blue.opacity(0.2)]
                        ))
                    .ignoresSafeArea()
            }
            .navigationTitle(vm.chat.td.title)
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
