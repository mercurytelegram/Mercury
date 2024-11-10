//
//  LoginPage.swift
//  Mercury Watch App
//
//  Created by Marco Tammaro on 02/11/24.
//

import SwiftUI

struct ChatListPage: View {
    
    @State
    @Mockable
    var vm: ChatListViewModel
    
    init(folder: ChatFolder) {
        _vm = Mockable.state(
            value: { ChatListViewModel(folder: folder) },
            mock: { ChatListViewModelMock() }
        )
    }
    
    var body: some View {
        if vm.isLoading {
            ProgressView()
        } else {
            
            List(vm.chats) { chat in
                NavigationLink(value: chat) {
                    ChatCellView(model: chat) {
                        vm.didPressMute(on: chat)
                    }
                }
            }
            .listStyle(.carousel)
            .navigationTitle(vm.folder.title)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("New Chat", systemImage: "square.and.pencil") {
                        vm.didPressOnNewMessage()
                    }
                }
            }
            .sheet(isPresented: $vm.showNewMessage) {
                AlertView.inDevelopment("new messages are")
            }
        }
    }
}

#Preview(traits: .mock()) {
    NavigationStack {
        ChatListPage(folder: .main)
    }
}
