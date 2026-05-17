//
//  MessageOptionsView.swift
//  Mercury Watch App
//
//  Created by Alessandro Alberti on 11/09/24.
//

import SwiftUI
import TDLibKit

struct MessageOptionsSubpage: View {
    
    @State
    @Mockable
    var vm: MessageOptionsViewModel
    
    @Binding var isPresented: Bool
    
    init(isPresented: Binding<Bool>, model: MessageOptionsModel) {
        self._isPresented = isPresented
        _vm = Mockable.state(
            value: { MessageOptionsViewModel(model: model) },
            mock: { MessageOptionsViewModelMock() }
        )
    }
    
    var body: some View {
        ScrollView {
            ScrollView(.horizontal) {
                HStack(spacing: 8) {
                ForEach(vm.emojis, id: \.self) { emoji in
                    Button(action: {
                        Task {
                            await vm.sendReaction(emoji)
                            await MainActor.run {
                                isPresented = false
                            }
                        }
                    }, label: {
                        Text(emoji)
                            .font(.system(size: 30))
                            .background {
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(.white.opacity(0.2))
                                    .opacity(vm.selectedEmoji == emoji ? 1 : 0)
                                    
                            }
                    })
                    .buttonStyle(PlainButtonStyle())
                }
            }
            }
            .scrollIndicators(.hidden)
            .padding(.horizontal)
            
            messageActions()
            
            if vm.shouldDisplayReportButton {
                Button(action: {
                    vm.showReportMessageOptions = true
                }, label: {
                    Label("Report content", systemImage: "exclamationmark.triangle")
                })
                .tint(.red)
            }
        }
        .sheet(isPresented: $vm.showReportMessageOptions) {
            List {
                ForEach(vm.reportMessageOptions, id: \.self) { option in
                    Button(option.description) {
                        vm.reportMessage(option)
                    }
                }
                .navigationTitle("Reason")
            }
        }
        .sheet(isPresented: $vm.showForwardTargetPicker) {
            MessageTargetPickerSubpage(title: "Forward to", showsHideSenderToggle: true) { chatId, hideSender in
                vm.forwardMessage(to: chatId, asCopy: hideSender)
                isPresented = false
            }
        }

    }
    
    @ViewBuilder
    private func messageActions() -> some View {
        VStack(spacing: 6) {
            Button {
                vm.replyToMessage()
                isPresented = false
            } label: {
                Label("Reply", systemImage: "arrowshape.turn.up.left.fill")
            }
            
            Button {
                vm.showForwardTargetPicker = true
            } label: {
                Label("Forward", systemImage: "arrowshape.turn.up.right.fill")
            }
            
            Button {
                vm.pinMessage()
                isPresented = false
            } label: {
                Label("Pin", systemImage: "pin.fill")
            }
            
            Button(role: .destructive) {
                vm.deleteMessage()
                isPresented = false
            } label: {
                Label("Delete", systemImage: "trash.fill")
            }
        }
        .padding(.horizontal)
    }
}

struct MessageOptionsModel {
    var chatId: Int64
    var messageId: Int64
    var sendService: SendMessageService
    var chatType: ChatType?
    var onReply: (() -> Void)?
    var onDeleted: (() -> Void)?
    var onPinned: (() -> Void)?
}

private struct MessageTargetPickerSubpage: View {
    let title: String
    var showsHideSenderToggle: Bool = false
    let onSelectChat: (Int64, Bool) -> Void
    
    @State private var vm = MessageTargetPickerViewModel()
    @State private var hideSender: Bool = false
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            Group {
                if vm.isLoading {
                    ProgressView()
                } else if vm.chats.isEmpty {
                    Text("No chats")
                        .foregroundStyle(.secondary)
                } else {
                    List {
                        if showsHideSenderToggle {
                            Toggle(isOn: $hideSender) {
                                Label("Hide sender", systemImage: "person.crop.circle.badge.xmark")
                            }
                        }
                        
                        ForEach(vm.chats) { chat in
                            Button {
                                onSelectChat(chat.id, hideSender)
                                dismiss()
                            } label: {
                                HStack(spacing: 10) {
                                    AvatarView(model: chat.avatar)
                                        .frame(width: 36, height: 36)
                                    VStack(alignment: .leading) {
                                        Text(chat.title)
                                            .fontWeight(.semibold)
                                            .lineLimit(1)
                                        if let subtitle = chat.subtitle {
                                            Text(subtitle)
                                                .font(.caption2)
                                                .foregroundStyle(.secondary)
                                                .lineLimit(1)
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle(title)
            .searchable(text: $vm.searchText, prompt: "Search chats")
            .onChange(of: vm.searchText) { _, newValue in
                vm.search(newValue)
            }
            .task {
                await vm.loadRecentChats()
            }
        }
    }
}

@Observable
private class MessageTargetPickerViewModel {
    var chats: [MessageTargetModel] = []
    var isLoading: Bool = false
    var searchText: String = ""
    
    private var searchTask: Task<Void, Never>?
    
    func loadRecentChats() async {
        guard chats.isEmpty else { return }
        await MainActor.run { self.isLoading = true }
        let ids = (try? await TDLibManager.shared.client?.getChats(chatList: .chatListMain, limit: 25))?.chatIds ?? []
        await loadChats(ids: ids)
    }
    
    func search(_ query: String) {
        searchTask?.cancel()
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
        searchTask = Task {
            try? await Task.sleep(nanoseconds: 300_000_000)
            guard !Task.isCancelled else { return }
            if trimmed.isEmpty {
                await loadRecentChats()
                return
            }
            await MainActor.run { self.isLoading = true }
            let localIds = (try? await TDLibManager.shared.client?.searchChats(limit: 15, query: trimmed))?.chatIds ?? []
            let serverIds = (try? await TDLibManager.shared.client?.searchChatsOnServer(limit: 15, query: trimmed))?.chatIds ?? []
            let publicIds = (try? await TDLibManager.shared.client?.searchPublicChats(query: trimmed))?.chatIds ?? []
            await loadChats(ids: unique(localIds + serverIds + publicIds))
        }
    }
    
    private func loadChats(ids: [Int64]) async {
        let models = await withTaskGroup(of: MessageTargetModel?.self) { group in
            for id in ids {
                group.addTask {
                    guard let chat = try? await TDLibManager.shared.client?.getChat(chatId: id)
                    else { return nil }
                    return MessageTargetModel(chat: chat)
                }
            }
            
            var results: [MessageTargetModel] = []
            for await model in group {
                if let model { results.append(model) }
            }
            return results
        }
        
        await MainActor.run {
            self.chats = models
            self.isLoading = false
        }
    }
    
    private func unique(_ ids: [Int64]) -> [Int64] {
        var seen = Set<Int64>()
        return ids.filter { seen.insert($0).inserted }
    }
}

private struct MessageTargetModel: Identifiable {
    let id: Int64
    let title: String
    let subtitle: String?
    let avatar: AvatarModel
    
    init(chat: Chat) {
        self.id = chat.id
        self.title = chat.title
        if let lastMessage = chat.lastMessage {
            self.subtitle = String(lastMessage.description.characters)
        } else {
            self.subtitle = nil
        }
        self.avatar = chat.toAvatarModel()
    }
}

#Preview {
    Rectangle()
        .foregroundStyle(.blue.opacity(0.8))
        .ignoresSafeArea()
        .sheet(isPresented: .constant(true), content: {
            MessageOptionsSubpage(
                isPresented: .constant(true),
                model: .init(
                    chatId: 0,
                    messageId: 0,
                    sendService: SendMessageServiceMock { _ in }
                )
            )
        })
}
    
