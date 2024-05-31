//
//  ChatList.swift
//  Mercury Watch App
//
//  Created by Marco Tammaro on 08/05/24.
//

import SwiftUI

struct ChatListView: View {
    
    @StateObject var vm: ChatListViewModel

    init(useMock: Bool = false) {
        self._vm = StateObject(wrappedValue: useMock ? MockChatListViewModel() : ChatListViewModel())
    }
    
    var body: some View {
        
        NavigationStack {
            
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
                .navigationTitle {
                    Text("Mercury")
                        .foregroundStyle(.blue)
                }
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        Button("Settings", systemImage: "ellipsis") {
                            vm.showSettings = true
                        }
                        .foregroundStyle(.blue)
                    }
                }
                .sheet(isPresented: $vm.showSettings) {
                    SettingsView(isPresented: $vm.showSettings)
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        ChatListView(useMock: true)
    }
}
