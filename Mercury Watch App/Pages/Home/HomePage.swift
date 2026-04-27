//
//  LoginPage.swift
//  Mercury Watch App
//
//  Created by Marco Tammaro on 02/11/24.
//

import SwiftUI

struct HomePage: View {
    
    @State
    @Mockable(mockInit: HomeViewModelMock.init)
    var vm = HomeViewModel.init
    
    var body: some View {
        NavigationStack(path: $vm.navigationPath) {
            List {
                NavigationLink {
                    SettingsPage()
                } label: {
                    UserCellView(model: vm.userCellModel)
                }
                
                Section {
                    ForEach(AppState.shared.folders, id: \.self) { folder in
                        NavigationLink(value: folder) {
                            Label {
                                Text(folder.title)
                            } icon: {
                                Image(systemName: folder.iconName)
                                    .font(.caption)
                                    .foregroundStyle(folder.color)
                            }
                        }
                        .listItemTint(folder.color)
                    }
                }
                
            }
            .navigationTitle("Mercury")
            .navigationDestination(for: ChatFolder.self) { folder in
                ChatListPage(folder: folder)
            }
            .navigationDestination(for: ChatCellModel.self) { chat in
                if let id = chat.id {
                    if chat.isForum == true {
                        ForumTopicsPage(chatId: id)
                    } else {
                        ChatDetailPage(chatId: id, messageThreadId: chat.messageThreadId)
                    }
                }
            }
        }
    }
}


#Preview(traits: .mock()) {
    HomePage()
}

import TDLibKit

struct ChatRouterPage: View {
    let chatId: Int64
    let messageThreadId: Int64?
    @State private var isForum: Bool?
    
    init(chatId: Int64, messageThreadId: Int64?, isForum: Bool? = nil) {
        self.chatId = chatId
        self.messageThreadId = messageThreadId
        _isForum = State(initialValue: isForum)
    }
    
    var body: some View {
        Group {
            if let isForum {
                if isForum {
                    ForumTopicsPage(chatId: chatId)
                } else {
                    ChatDetailPage(chatId: chatId, messageThreadId: messageThreadId)
                }
            } else {
                VStack {
                    ProgressView()
                }
                .navigationTitle("Loading...")
                .task {
                    do {
                        guard let chat = try await TDLibManager.shared.client?.getChat(chatId: chatId) else {
                            self.isForum = false
                            return
                        }
                        if case .chatTypeSupergroup(let data) = chat.type,
                           let supergroup = try await TDLibManager.shared.client?.getSupergroup(supergroupId: data.supergroupId) {
                            self.isForum = supergroup.isForum
                        } else {
                            self.isForum = false
                        }
                    } catch {
                        self.isForum = false
                    }
                }
            }
        }
    }
}
