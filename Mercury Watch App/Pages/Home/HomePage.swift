//
//  LoginPage.swift
//  Mercury Watch App
//
//  Created by Marco Tammaro on 02/11/24.
//

import SwiftUI
import TDLibKit

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
                
                Button {
                    vm.openSavedMessages()
                } label: {
                    Label {
                        Text("Saved Messages")
                    } icon: {
                        Image(systemName: "bookmark.fill")
                            .font(.caption)
                            .foregroundStyle(.green)
                    }
                }
                .listItemTint(.green)
                
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
                        ChatDetailPage(
                            chatId: id,
                            messageThreadId: chat.messageThreadId,
                            onOpenURL: vm.openURL
                        )
                    }
                }
            }
            .navigationDestination(for: Int64.self) { chatId in
                ChatRouterPage(
                    chatId: chatId,
                    messageThreadId: nil,
                    onOpenURL: vm.openURL
                )
            }
            .navigationDestination(for: ChatNavigationTarget.self) { target in
                ChatRouterPage(
                    chatId: target.chatId,
                    messageThreadId: target.messageThreadId,
                    onOpenURL: vm.openURL
                )
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("New Chat", systemImage: "square.and.pencil") {
                        vm.didPressNewChat()
                    }
                }
            }
            .sheet(isPresented: $vm.showNewChat) {
                NewChatPage { chatId in
                    vm.openChat(chatId)
                }
            }
            .sheet(item: $vm.webLinkNotice) { notice in
                AlertView(
                    symbolSystemName: "safari",
                    tint: .blue,
                    title: "Open on iPhone",
                    description: "watchOS doesn't allow Mercury to open \(notice.host) in an in-app browser."
                )
            }
            .environment(\.openURL, OpenURLAction { url in
                vm.openURL(url)
            })
        }
    }
}

struct ChatNavigationTarget: Hashable {
    let chatId: Int64
    let messageThreadId: Int64?
}

struct ChatRouterPage: View {
    let chatId: Int64
    let messageThreadId: Int64?
    let onOpenURL: ((URL) -> OpenURLAction.Result)?
    @State private var isForum: Bool?
    
    init(
        chatId: Int64,
        messageThreadId: Int64?,
        isForum: Bool? = nil,
        onOpenURL: ((URL) -> OpenURLAction.Result)? = nil
    ) {
        self.chatId = chatId
        self.messageThreadId = messageThreadId
        self.onOpenURL = onOpenURL
        _isForum = State(initialValue: isForum)
    }
    
    var body: some View {
        Group {
            if let isForum {
                if isForum && messageThreadId == nil {
                    ForumTopicsPage(chatId: chatId)
                } else {
                    ChatDetailPage(
                        chatId: chatId,
                        messageThreadId: messageThreadId,
                        onOpenURL: onOpenURL
                    )
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

struct NewChatPage: View {
    
    @State private var vm = NewChatViewModel()
    @Environment(\.dismiss) private var dismiss
    
    let onOpenChat: (Int64) -> Void
    
    var body: some View {
        NavigationStack {
            Group {
                if vm.isLoading {
                    ProgressView()
                } else if let error = vm.error {
                    Text(error)
                        .foregroundStyle(.red)
                        .multilineTextAlignment(.center)
                        .padding()
                } else if vm.users.isEmpty {
                    Text("No contacts")
                        .foregroundStyle(.secondary)
                } else {
                    List(vm.users) { user in
                        Button {
                            Task {
                                guard let chatId = await vm.openChat(with: user.id)
                                else { return }
                                dismiss()
                                onOpenChat(chatId)
                            }
                        } label: {
                            HStack(spacing: 10) {
                                AvatarView(model: user.avatar)
                                    .frame(width: 40, height: 40)
                                VStack(alignment: .leading) {
                                    Text(user.title)
                                        .fontWeight(.semibold)
                                    if let subtitle = user.subtitle {
                                        Text(subtitle)
                                            .font(.caption)
                                            .foregroundStyle(.secondary)
                                    }
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("New Chat")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
        .task {
            await vm.loadContacts()
        }
    }
}

@Observable
class NewChatViewModel: TDLibViewModel {
    
    var users: [NewChatUserModel] = []
    var isLoading: Bool = false
    var error: String?
    
    func loadContacts() async {
        guard users.isEmpty else { return }
        
        await MainActor.run {
            self.isLoading = true
            self.error = nil
        }
        
        do {
            let result = try await TDLibManager.shared.client?.searchContacts(
                limit: 50,
                query: ""
            )
            let userIds = result?.userIds ?? []
            let models = await withTaskGroup(of: NewChatUserModel?.self) { group in
                for userId in userIds {
                    group.addTask {
                        guard let user = try? await TDLibManager.shared.client?.getUser(userId: userId)
                        else { return nil }
                        return NewChatUserModel(user: user)
                    }
                }
                
                var results: [NewChatUserModel] = []
                for await model in group {
                    if let model { results.append(model) }
                }
                return results.sorted { $0.title < $1.title }
            }
            
            await MainActor.run {
                self.users = models
                self.isLoading = false
            }
        } catch {
            await MainActor.run {
                self.error = error.localizedDescription
                self.isLoading = false
            }
        }
    }
    
    func openChat(with userId: Int64) async -> Int64? {
        do {
            let chat = try await TDLibManager.shared.client?.createPrivateChat(
                force: false,
                userId: userId
            )
            return chat?.id
        } catch {
            await MainActor.run {
                self.error = error.localizedDescription
            }
            return nil
        }
    }
}

struct NewChatUserModel: Identifiable {
    let id: Int64
    let title: String
    let subtitle: String?
    let avatar: AvatarModel
    
    init(user: User) {
        self.id = user.id
        self.title = user.fullName.trimmingCharacters(in: .whitespaces)
        self.subtitle = user.mainUserName ?? user.statusDescription
        self.avatar = user.toAvatarModel()
    }
}

#Preview(traits: .mock()) {
    HomePage()
}
