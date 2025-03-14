//
//  ChatListViewModel+Updates.swift
//  Mercury Watch App
//
//  Created by Marco Tammaro on 10/11/24.
//

import TDLibKit
import SwiftUI

extension ChatListViewModel {
    
    @MainActor
    func updateChatRemovedFromList(_ update: UpdateChatRemovedFromList) {
        let chatId = update.chatId
        withAnimation {
            self.chats.removeAll { c in c.id == chatId }
        }
    }
    
    @MainActor
    func updateUserStatus(_ update: UpdateUserStatus) {
        let userId = update.userId
        let status = update.status
        
        let index = self.chats.firstIndex { c in c.avatar.userId == userId }
        guard let index, index != -1 else { return }
        
        withAnimation {
            switch status {
            case .userStatusOnline(_):
                self.chats[index].avatar.isOnline = true
            case .userStatusOffline(_):
                self.chats[index].avatar.isOnline = false
            default:
                break
            }
        }
    }
    
    func updateChatAction(_ update: UpdateChatAction) {
        
        let chatId: Int64 = update.chatId
        let sender: MessageSender = update.senderId
        let action: ChatAction = update.action
        
        // If the chat does not belongs to the current folder, return
        guard self.chats.contains(where: { $0.id == chatId })
        else { return }
        
        Task.detached {
            do {
                guard let chat = try await TDLibManager.shared.client?.getChat(chatId: chatId)
                else { return }
                
                var messageStyle: ChatCellModel.MessageStyle? = nil
                
                // Check if action is available
                if let action = action.description {
                    
                    var action = action
                    if chat.isGroup,
                       let username = await sender.username(),
                       let name = username.split(separator: " ").first {
                        let attributedName = AttributedString(name)
                        let attributedAction = AttributedString(" is ") + action
                        action = attributedName + attributedAction
                    }
                    
                    messageStyle = .action(action)
                }
                
                // Otherwise, if available, use lastMessage as fallback
                if messageStyle == nil, let lastMessage = chat.lastMessage?.description {
                    messageStyle = .message(lastMessage)
                }
                
                await MainActor.run { [messageStyle] in
                    let index = self.chats.firstIndex { c in c.id == chatId }
                    guard let index, index != -1 else { return }
                    
                    withAnimation {
                        self.chats[index].messageStyle = messageStyle
                    }
                }
                
            } catch {
                self.logger.log(error, level: .error)
            }
        }
    }
    
    func updateChatLastMessage(_ update: UpdateChatLastMessage) {
        let chatId = update.chatId
        let message = update.lastMessage
        
        guard let message else { return }
        
        Task.detached {
            
            do {
                
                guard let chat = try await TDLibManager.shared.client?.getChat(chatId: chatId)
                else { return }
                
                // If the chat does not belongs to the current folder, return
                guard chat.positions.contains(where: { self.folder.chatList == $0.list })
                else { return }
                
                // Update message time
                let date = Date(timeIntervalSince1970: TimeInterval(message.date))
                
                // Update message content
                var desc = message.description
                if chat.isGroup,
                   let username = await message.senderId.username() {
                    var attributedUsername = AttributedString(username + ": ")
                    attributedUsername.foregroundColor = .white
                    desc = attributedUsername + message.description
                }
                
                await MainActor.run { [desc] in
                    
                    let index = self.chats.firstIndex { c in c.id == chatId }
                    
                    if let index, index != -1 {
                        // Chat already shown, update content
                        self.chats[index].messageStyle = .message(desc)
                        self.chats[index].time = date.stringDescription
                        
                    } else {
                        // Chat not shown, add to chat list
                        let model = self.chatCellModelFrom(chat)
                        self.chats.append(model)
                    }
                    
                    if let position = chat.positions.first(where: { $0.list == self.folder.chatList }) {
                        let positonUpdate = UpdateChatPosition(chatId: update.chatId, position: position)
                        self.updateChatPosition(positonUpdate)
                    }
                }
                
            } catch {
                self.logger.log(error, level: .error)
            }
            
        }
    }
    
    @MainActor
    func updateChatTitle(_ update: UpdateChatTitle) {
        let chatId = update.chatId
        let title = update.title
        
        let index = self.chats.firstIndex { c in c.id == chatId }
        guard let index, index != -1 else { return }
        
        withAnimation {
            self.chats[index].title = title
            self.chats[index].avatar.letters = String(title.prefix(1))
        }
    }
    
    @MainActor
    func updateChatPhoto(_ update: UpdateChatPhoto) {
        let chatId = update.chatId
        let avatarImage = update.photo?.getAsyncModel()
        
        let index = self.chats.firstIndex { c in c.id == chatId }
        guard let index, index != -1 else { return }
        
        withAnimation {
            self.chats[index].avatar.avatarImage = avatarImage
        }
    }
    
    @MainActor
    func updateChatPosition(_ update: UpdateChatPosition) {
        let chatId = update.chatId
        let position = update.position
        
        // If the chat does not belongs to the current folder, return
        guard position.list == self.folder.chatList
        else { return }
        
        let index = self.chats.firstIndex { c in c.id == chatId }
        
        if let index, index != -1 {
            // Chat already shown, update position
            withAnimation {
                if position.order == 0 {
                    self.chats.remove(at: index)
                } else {
                    self.chats[index].position = position.order.rawValue
                    self.chats[index].isPinned = position.isPinned
                    self.chats = self.chats.sorted(by: chatSortingLogic)
                }
            }
            
        } else {
            // Chat not shown, insert and update position
            Task.detached(priority: .high) {
                
                guard let chat = try await TDLibManager.shared.client?.getChat(chatId: chatId)
                else { return }
                
                let model = self.chatCellModelFrom(chat)
                
                await MainActor.run {
                    withAnimation {
                        self.chats.append(model)
                        self.chats = self.chats.sorted(by: self.chatSortingLogic)
                    }
                }
                
            }

        }
        
    }
    
    @MainActor
    func updateCounters(
        chatId: Int64,
        reactionCount: Int? = nil,
        mentionCount: Int? = nil,
        unreadCount: Int? = nil
    ) {
        
        let index = self.chats.firstIndex { c in c.id == chatId }
        guard let index, index != -1 else { return }
        
        var badgeStyle: ChatCellModel.UnreadStyle? = nil
        if let reactionCount, reactionCount != 0 {
            badgeStyle = .reaction
        }
        else if let mentionCount, mentionCount != 0 {
            badgeStyle = .mention
        }
        else if let unreadCount, unreadCount != 0 {
            badgeStyle = .message(count: unreadCount)
        }
        
        if let badgeStyle {
            withAnimation {
                self.chats[index].unreadBadgeStyle = badgeStyle
            }
            return
        }
        
        // If no badge counter is provided, get the latest unreadCount
        Task {
            
            do {
                guard let chat = try await TDLibManager.shared.client?.getChat(chatId: chatId)
                else { return }
                
                let index = self.chats.firstIndex { c in c.id == chatId }
                guard let index, index != -1 else { return }
                
                await MainActor.run {
                    withAnimation {
                        if chat.unreadCount == 0 {
                            self.chats[index].unreadBadgeStyle = nil
                        } else {
                            self.chats[index].unreadBadgeStyle = .message(count: chat.unreadCount)
                        }
                    }
                }
                
            } catch {
                self.logger.log(error, level: .error)
            }
        }
    }
    
    @MainActor
    func updateChatNotificationSettings(_ update: UpdateChatNotificationSettings) {
        let chatId = update.chatId
        let isMuted = update.notificationSettings.muteFor != 0
        
        let index = self.chats.firstIndex { c in c.id == chatId }
        guard let index, index != -1 else { return }
        
        withAnimation {
            self.chats[index].isMuted = isMuted
        }
    }
    
}
