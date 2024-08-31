//
//  ChatsListModel.swift
//  Mercury Watch App
//
//  Created by Marco Tammaro on 08/05/24.
//

import Foundation
import TDLibKit
import Combine
import SwiftUI

class ChatListViewModel: TDLibViewModel {
    
    @Published var chats: [ChatCellModel] = []
    @Published var isLoading = false
    @Published var showSettings = false
    @Published var showNewMessage = false
    @Published var folders: [ChatFolder] = [.main, .archive]
    var isMock = false
    
    private(set) var currentFolder: ChatFolder = .main
    
    override func updateHandler(update: Update) {
        super.updateHandler(update: update)
        DispatchQueue.main.async {
            switch update {
            
            // Chat metadata update
            case .updateUserStatus(let update):
                self.updateUserStatus(userId: update.userId, status: update.status)
            case .updateChatLastMessage(let update):
                self.updateLastMessage(chatId: update.chatId,
                                       message: update.lastMessage,
                                       newPositions: update.positions)
            case .updateChatPosition(let update):
                self.updateChatPosition(chatId: update.chatId, positions: [update.position])
            case .updateChatReadOutbox(let update):
                self.updateChatReadOutbox(chatId: update.chatId, lastReadMessageId: update.lastReadOutboxMessageId)
                
            // Chat Counters update
            case .updateChatReadInbox(let update):
                self.updateCounters(chatId: update.chatId, unreadCount: update.unreadCount)
            case .updateChatUnreadMentionCount(let update):
                self.updateCounters(chatId: update.chatId, mentionCount: update.unreadMentionCount)
            case .updateChatUnreadReactionCount(let update):
                self.updateCounters(chatId: update.chatId, reactionCount: update.unreadReactionCount)
            case .updateMessageUnreadReactions(let update):
                self.updateCounters(chatId: update.chatId, reactionCount: update.unreadReactionCount)
                
            // Chat Action update
            case .updateChatAction(let update):
                self.setChatAction(chatId: update.chatId, sender: update.senderId, action: update.action)
                
            // Chat Folders update
            case .updateChatFolders(let update):
                self.updateChatFolders(update: update)
            default:
                break
            }
        }
    }
    
    override func connectionStateUpdate(state: ConnectionState) {
        guard state == .connectionStateReady || state == .connectionStateConnecting else { return }
        
        // if state is connecting, request chats will load cached chats
        // if state is ready, request chats will load chats from server
        self.requestChats()
    }
    
    func requestChats() {
        Task {
            
            do {
                let result = try await TDLibManager.shared.client?.getChats(chatList: currentFolder.chatList, limit: 10)
                
                for id in result?.chatIds ?? [] {
                    guard let chat = try await TDLibManager.shared.client?.getChat(chatId: id) else { continue }
                    await MainActor.run {
                        
                        if !chats.contains(where: { $0.td.id == id}) {
                            chats.append(.from(chat))
                        }
                        
                        self.updateLastMessage(chatId: chat.id, message: chat.lastMessage, newPositions: chat.positions)
                        self.updateCounters(
                            chatId: chat.id,
                            reactionCount: chat.unreadReactionCount,
                            mentionCount: chat.unreadMentionCount,
                            unreadCount: chat.unreadCount
                        )
                    }
                }
                self.logger.log(result)
                
            } catch {
                self.logger.log(error, level: .error)
            }
            
            DispatchQueue.main.async {
                self.isLoading = self.chats.isEmpty
            }
        }
    }
    
    func setChatAction(chatId: Int64, sender: MessageSender, action: ChatAction) {
        
        let index = self.chats.firstIndex { c in c.td.id == chatId }
        guard let index, index != -1 else { return }
        
        guard let message = action.description else {
            self.chats[index].action = nil
            return
        }
        
        Task {
            var action = message
            
            if chats[index].td.isGroup,
               let username = await sender.username(),
               let name = username.split(separator: " ").first {
                let attributedName = AttributedString(name)
                let attributedAction = AttributedString(" is ") + message
                action = attributedName + attributedAction
            }
            
            action.foregroundColor = .blue
            await MainActor.run { [action] in
                self.chats[index].action = action
            }
        }
        
    }
    
    func updateLastMessage(chatId: Int64, message: Message?, newPositions: [ChatPosition]) {
        
        let index = self.chats.firstIndex { c in c.td.id == chatId }
        guard let message, let index, index != -1 else { return }
        
        // Update message time
        let date = Date(timeIntervalSince1970: TimeInterval(message.date))
        self.chats[index].time = date.stringDescription
        
        // Update message sender if group chat
        Task {
            var desc = message.description
            if chats[index].td.isGroup,
               let username = await message.senderId.username() {
                var attributedUsername = AttributedString(username + ": ")
                attributedUsername.foregroundColor = .white
                desc = attributedUsername + message.description
            }
            
            await MainActor.run { [desc] in
                withAnimation {
                    self.chats[index].message = desc
                    self.updateChatPosition(chatId: chatId, positions: newPositions)
                }
            }
        }
        
    }
    
    func updateCounters(
        chatId: Int64,
        reactionCount: Int? = nil,
        mentionCount: Int? = nil,
        unreadCount: Int? = nil
    ) {
        
        let chatId = chatId
        let index = self.chats.firstIndex { c in c.td.id == chatId }
        guard let index, index != -1 else { return }
        
        if let reactionCount, reactionCount != 0 {
            self.chats[index].showUnreadMention = false
            self.chats[index].showUnreadReaction = true
            self.chats[index].unreadCount = reactionCount
        }
        
        else if let mentionCount, mentionCount != 0 {
            self.chats[index].showUnreadMention = true
            self.chats[index].showUnreadReaction = false
            self.chats[index].unreadCount = mentionCount
        }
        
        else if let unreadCount, unreadCount != 0 {
            self.chats[index].showUnreadMention = false
            self.chats[index].showUnreadReaction = false
            self.chats[index].unreadCount = unreadCount
        } 
        
        else {
            self.chats[index].showUnreadMention = false
            self.chats[index].showUnreadReaction = false
            self.chats[index].unreadCount = 0
        }
        
    }
    
    func updateUserStatus(userId: Int64, status: UserStatus) {

        let userId = userId
        let index = self.chats.firstIndex { c in c.userId == userId }
        if index == nil || index == -1 { return }
        
        switch status {
        case .userStatusOnline(_):
            self.chats[index!].avatar.isOnline = true
        case .userStatusOffline(_):
            self.chats[index!].avatar.isOnline = false
        default:
            break
        }
    }
    
    func updateChatPosition(chatId: Int64, positions: [ChatPosition]) {
        
        let position = positions.first { p in
            p.list == .chatListMain
        }
        
        let index = self.chats.firstIndex {
            c in c.td.id == chatId
        }
        
        guard let position, let index, index != -1 else { return }
        
        withAnimation {
            if position.order == 0 {
                self.chats.remove(at: index)
            } else {
                self.chats[index].position = position.order.rawValue
                self.chats = self.chats.sorted()
            }
        }
    }
    
    func updateChatReadOutbox(chatId: Int64, lastReadMessageId: Int64) {
        
        let index = self.chats.firstIndex {
            c in c.td.id == chatId
        }
        
        guard let index, index != -1 else { return }
        
        withAnimation {
            self.chats[index].lastReadOutboxMessageId = lastReadMessageId
        }
    }
    
    func updateChatFolders(update: UpdateChatFolders) {
        self.folders = [.main, .archive]
        for chatFolderInfo in update.chatFolders {
            let chatList = ChatList.chatListFolder(ChatListFolder(chatFolderId: chatFolderInfo.id))
            let folder = ChatFolder(title: chatFolderInfo.title, chatList: chatList)
            
            DispatchQueue.main.async {
                withAnimation {
                    // To leave Archive in the last position
                    self.folders.insert(folder, at: self.folders.count - 1)
                }
            }
        }
    }
    
    func getChatVM(for chat: ChatCellModel) -> ChatDetailViewModel {
        ChatDetailViewModel(chat: chat)
    }
    
    func selectChatFolder(_ chat: ChatFolder) {
        guard chat != currentFolder else { return }
        
        self.currentFolder = chat
        self.chats = []
        self.isLoading = true
        self.requestChats()
    }
    
}
