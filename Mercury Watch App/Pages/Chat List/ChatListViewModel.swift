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
    @Published var isLoading = true
    @Published var showSettings = false
    var isMock = false
    
    override func updateHandler(update: Update) {
        super.updateHandler(update: update)
        DispatchQueue.main.async {
            switch update {
            
            // Chat list update
            case .updateNewChat(let update):
                self.insertNewChat(update.chat)
                self.updateCounters(chatId: update.chat.id,
                                    reactionCount: update.chat.unreadReactionCount,
                                    mentionCount: update.chat.unreadMentionCount,
                                    unreadCount: update.chat.unreadCount)
            
            // Chat metadata update
            case .updateUserStatus(let update):
                self.updateUserStatus(userId: update.userId, status: update.status)
            case .updateChatLastMessage(let update):
                self.updateLastMessage(update: update)
            case .updateChatPosition(let update):
                self.updateChatPosition(chatId: update.chatId, positions: [update.position])
                
            // Chat Counters update
            case .updateChatReadInbox(let update):
                self.updateCounters(chatId: update.chatId, unreadCount: update.unreadCount)
            case .updateChatUnreadMentionCount(let update):
                self.updateCounters(chatId: update.chatId, mentionCount: update.unreadMentionCount)
            case .updateChatUnreadReactionCount(let update):
                self.updateCounters(chatId: update.chatId, reactionCount: update.unreadReactionCount)
            
            // Chat Action update
            case .updateChatAction(let update):
                self.setChatAction(chatId: update.chatId, sender: update.senderId, action: update.action)
                
            default:
                break
            }
        }
    }
    
    override func connectionStateUpdate(state: ConnectionState) {
        guard state == .connectionStateReady else { return }
        self.requestChats()
    }
    
    func requestChats() {
        Task {
            do {
                let result = try await TDLibManager.shared.client?.loadChats(chatList: .chatListMain, limit: 10)
                print("[CLIENT] [\(type(of: self))] [\(#function)] \(String(describing: result))")
                
            } catch {
                print("[CLIENT] [\(type(of: self))] [\(#function)] error: \(error)")
            }
            
            DispatchQueue.main.async {
                self.isLoading = false
            }
        }
    }
    
    func insertNewChat(_ chat: Chat) {
        self.chats.append(.from(chat))
        self.chats = self.chats.sorted()
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
            
            if chats[index].td.type.isGroup,
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
    
    func updateLastMessage(update: UpdateChatLastMessage) {

        let chatId = update.chatId
        let message = update.lastMessage
        let newPositions = update.positions
        
        let index = self.chats.firstIndex { c in c.td.id == chatId }
        guard let message, let index, index != -1 else { return }
        
        // Update message content
        self.chats[index].message = message.description
        
        // Update message time
        let date = Date(timeIntervalSince1970: TimeInterval(message.date))
        self.chats[index].time = date.stringDescription
        
        // Update message sender if group chat
        Task {
            var desc = message.description
            if chats[index].td.type.isGroup,
               let username = await message.senderId.username() {
                var attributedUsername = AttributedString(username + ": ")
                attributedUsername.foregroundColor = .white
                desc = attributedUsername + message.description
            }
            
            await MainActor.run { [desc] in
                self.chats[index].message = desc
                self.updateChatPosition(chatId: chatId, positions: newPositions)
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
    
    func getChatVM(for chat: ChatCellModel) -> ChatDetailViewModel {
        ChatDetailViewModel(chat: chat)
    }
    
    func getSendMsgVM(for chat: ChatCellModel) -> SendMessageViewModel {
        SendMessageViewModel(chat: chat)
    }
    
}
