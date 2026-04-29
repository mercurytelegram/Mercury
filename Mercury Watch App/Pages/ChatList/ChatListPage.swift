//
//  ChatListPage.swift
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
            
            List {
                ForEach(vm.filteredChats) { chat in
                    NavigationLink(value: chat) {
                        ChatCellView(model: chat) {
                            vm.didPressPin(on: chat)
                        } onPressMuteButton: {
                            vm.didPressMute(on: chat)
                        } onPressReadButton: {
                            vm.didPressRead(on: chat)
                        }
                    }
                    .listItemTint(chat.isPinned ? .blue : nil)
                }
                
                if vm.isSearchingGlobally {
                    ProgressView()
                }
            }
            .listStyle(.carousel)
            .navigationTitle(vm.folder.title)
            .searchable(text: $vm.searchText, prompt: "Search chats")
            .onChange(of: vm.searchText) { _, newValue in
                vm.didUpdateSearchText(newValue)
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("New Chat", systemImage: "square.and.pencil") {
                        vm.didPressOnNewMessage()
                    }
                }
            }
            .sheet(isPresented: $vm.showNewMessage) {
                NewChatPage { _ in
                    vm.initChatList()
                }
            }
            .sheet(item: $vm.muteOptionsChat) { chat in
                MuteChatOptionsPage(
                    chat: chat,
                    onSelectDuration: { duration in
                        vm.didSelectMuteDuration(duration, for: chat)
                    },
                    onUnmute: {
                        vm.didPressUnmute(on: chat)
                    }
                )
            }
        }
    }
}

private struct MuteChatOptionsPage: View {
    let chat: ChatCellModel
    let onSelectDuration: (ChatListViewModel.MuteDuration) -> Void
    let onUnmute: () -> Void
    
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            List {
                if chat.isMuted {
                    Button {
                        onUnmute()
                        dismiss()
                    } label: {
                        Label("Unmute", systemImage: "speaker.wave.3.fill")
                    }
                }
                
                Section {
                    ForEach(ChatListViewModel.MuteDuration.allCases) { duration in
                        Button {
                            onSelectDuration(duration)
                            dismiss()
                        } label: {
                            Label(duration.title, systemImage: "speaker.slash.fill")
                        }
                    }
                }
            }
            .navigationTitle("Mute")
        }
    }
}

#Preview(traits: .mock()) {
    NavigationStack {
        ChatListPage(folder: .main)
    }
}
