//
//  ChatList.swift
//  Mercury Watch App
//
//  Created by Marco Tammaro on 08/05/24.
//

import SwiftUI

struct ChatListView: View {
    
    @StateObject var vm: ChatListViewModel
    
    var body: some View {
        
        if vm.isLoading {
            ProgressView()
        } else {
            
            List(vm.chats, id: \.td.id) { chat in
                NavigationLink {
                    ChatDetailView(chat: chat, useMock: vm.isMock)
                } label: {
                    ChatCellView(model: chat)
                }
            }
            .listStyle(.carousel)
            .navigationTitle(vm.folder)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("New Chat", systemImage: "square.and.pencil") {}
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        ChatListView(vm: MockChatListViewModel())
    }
}


