//
//  LoginViewModel.swift
//  Mercury Watch App
//
//  Created by Marco Tammaro on 02/11/24.
//

import Foundation
import TDLibKit
import SwiftUI

@Observable
class ChatListViewModel: TDLibViewModel {
    
    var folder: ChatFolder? {
        didSet { self.initChatList() }
    }
    
    var chats: [ChatCellModel] = []
    var isLoading: Bool = false
    var showNewMessage: Bool = false
    
    func didPressMute(on chat: ChatCellModel) {}
    
    func didPressOnNewMessage() {
        self.showNewMessage = true
    }
    
    override func updateHandler(update: Update) {
        super.updateHandler(update: update)
        
        DispatchQueue.main.async {
            switch update {
                
            case .updateChatRemovedFromList(let update):
                self.updateChatRemovedFromList(update)
            
            // Chat metadata update
            case .updateUserStatus(let update):
                self.updateUserStatus(update)
            case .updateChatLastMessage(let update):
                self.updateChatLastMessage(update)
            case .updateChatPosition(let update):
                self.updateChatPosition(update)

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
                self.updateChatAction(update)
              
            default:
                break
            }
        }
    }
    
    fileprivate func initChatList() {
        
        Task.detached(priority: .high) {
            
            await MainActor.run {
                self.isLoading = true
            }
            
            let chatsData = await self.loadChats()
            let chatsModels = chatsData
                .map { self.chatCellModelFrom($0) }
                .sorted(by: self.chatSortingLogic)
            
            await MainActor.run {
                self.chats = chatsModels
                self.isLoading = false
            }
            
        }
    }
    
    private func loadChats(limit: Int = 10) async -> [Chat] {
        
        var chatsData = [Chat]()
        
        guard let chatList = folder?.chatList
        else { return [] }
        
        do {
            
            let result = try await TDLibManager.shared.client?.getChats(
                chatList: chatList,
                limit: limit
            )
            
            guard let result else { return [] }
            
            for id in result.chatIds {
                guard let chat = try await TDLibManager.shared.client?.getChat(chatId: id)
                else { continue }
                
                chatsData.append(chat)
            }
            
            self.logger.log(result)
            
        } catch {
            self.logger.log(error, level: .error)
        }
        
        return chatsData
        
    }
    
    private func chatCellModelFrom(_ chat: Chat) -> ChatCellModel {
        
        let date = Date(fromUnixTimestamp: chat.lastMessage?.date ?? 0)
        
        var userId: Int64? = nil
        if case .chatTypePrivate(let data) = chat.type {
            userId = data.userId
        }
        
        let letters: String = "\(chat.title.prefix(1))"
        let avatar = AvatarModel(tdImage: chat.photo, letters: letters, userId: userId)
        let position = chat.positions.first(where: { $0.list == folder?.chatList })?.order.rawValue
        
        var messageStyle: ChatCellModel.MessageStyle? = nil
        if let message = chat.lastMessage?.description {
            messageStyle = .message(message)
        }
        
        var unreadBadgeStyle: ChatCellModel.UnreadStyle? = nil
        if chat.unreadMentionCount != 0 {
            unreadBadgeStyle = .mention
        } else if chat.unreadReactionCount != 0 {
            unreadBadgeStyle = .reaction
        } else if chat.unreadCount != 0 {
            unreadBadgeStyle = .message(count: chat.unreadCount)
        }
        
        return ChatCellModel(
            id: chat.id,
            position: position,
            title: chat.title,
            time: date.stringDescription,
            avatar: avatar,
            messageStyle: messageStyle,
            unreadBadgeStyle: unreadBadgeStyle
        )
    }
 
    private func chatSortingLogic(elem1: ChatCellModel, elem2: ChatCellModel) -> Bool {
        guard let p1 = elem1.position, let p2 = elem2.position
        else { return true }
        
        // Sorting also by id does not update correctly the group chat's position
        return p1 > p2 // && elem1.id > elem2.id
    }
    
}

//MARK: - Updates handler
extension ChatListViewModel {
    
    private func updateChatRemovedFromList(_ update: UpdateChatRemovedFromList) {
        let chatId = update.chatId
        withAnimation {
            self.chats.removeAll { c in c.id == chatId }
        }
    }
    
    @MainActor
    private func updateUserStatus(_ update: UpdateUserStatus) {
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
    
    private func updateChatAction(_ update: UpdateChatAction) {
        
        let chatId: Int64 = update.chatId
        let sender: MessageSender = update.senderId
        let action: ChatAction = update.action
        
        // If the chat does not belongs to the current folder, return
        guard self.chats.contains(where: { $0.id == chatId })
        else { return }
        
        Task {
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
    
    private func updateChatLastMessage(_ update: UpdateChatLastMessage) {
        let chatId = update.chatId
        let message = update.lastMessage
        
        // If the chat does not belongs to the current folder, return
        guard self.chats.contains(where: { $0.id == chatId })
        else { return }
        
        guard let message else { return }
        
        Task {
            
            do {
                
                guard let chat = try await TDLibManager.shared.client?.getChat(chatId: chatId)
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
                    guard let index, index != -1 else { return }
                    
                    self.chats[index].messageStyle = .message(desc)
                    self.chats[index].time = date.stringDescription
                    
                    if let position = chat.positions.first(where: { $0.list == folder?.chatList }) {
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
    private func updateChatPosition(_ update: UpdateChatPosition) {
        let chatId = update.chatId
        let position = update.position
        
        let index = self.chats.firstIndex { c in c.id == chatId }
        guard let index, index != -1 else { return }
        
        withAnimation {
            if position.order == 0 {
                self.chats.remove(at: index)
            } else {
                self.chats[index].position = position.order.rawValue
                self.chats = self.chats.sorted(by: chatSortingLogic)
            }
        }
    }
    
    @MainActor
    private func updateCounters(
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
    
}


// MARK: - Mock
@Observable
class ChatListViewModelMock: ChatListViewModel {
    override init() {
        super.init()
        
        self.chats = [
            .init(
                id: 0,
                title: "Alessandro",
                time: "10:09",
                avatar: .alessandro,
                messageStyle: .message("Lorem ipsum dolor sit amet."),
                unreadBadgeStyle: .message(count: 3)
            ),
            .init(
                id: 1,
                title: "Marco",
                time: "09:41",
                avatar: .marco,
                messageStyle: .action("is typing"),
                unreadBadgeStyle: .reaction
            ),
        ]
    }
    
    override func connectionStateUpdate(state: ConnectionState) {}
    override func updateHandler(update: Update) {}
    override func initChatList() {}
}
