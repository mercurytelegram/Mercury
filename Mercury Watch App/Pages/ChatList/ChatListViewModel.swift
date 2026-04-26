//
//  ChatListViewModel.swift
//  Mercury Watch App
//
//  Created by Marco Tammaro on 02/11/24.
//

import Foundation
import TDLibKit
import SwiftUI

@Observable
class ChatListViewModel: TDLibViewModel {
    
    var folder: ChatFolder
    
    var chats: [ChatCellModel] = []
    var senders: [Int64:String] = [:]
    var isLoading: Bool = false
    var showNewMessage: Bool = false
    
    init(folder: ChatFolder) {
        self.folder = folder
        super.init()
        self.initChatList()
    }
    
    func didPressPin(on chat: ChatCellModel) {
        guard let id = chat.id else { return }
        pinChat(id, isPinned: chat.isPinned)
    }
    
    func didPressMute(on chat: ChatCellModel) {
        guard let id = chat.id else { return }
        muteChat(id)
    }
    
    func didPressOnNewMessage() {
        self.showNewMessage = true
    }
    
    // MARK: - Update Handler
    
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
            case .updateChatTitle(let update):
                self.updateChatTitle(update)
            case .updateChatPhoto(let update):
                self.updateChatPhoto(update)
            case .updateChatPosition(let update):
                self.updateChatPosition(update)
            case .updateChatNotificationSettings(let update):
                self.updateChatNotificationSettings(update)

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
    
    // MARK: - Init Chat List
    
    func initChatList() {
        Task.detached(priority: .high) {
            
            await MainActor.run { self.isLoading = true }
            
            let myId = try? await TDLibManager.shared.client?.getMe().id
            
            let ids = await self.loadChatIds()
            let chatsData = await self.loadChats(ids: ids)
            
            let chatsModels = chatsData
                .map { self.chatCellModelFrom($0, currentUserId: myId) }
                .sorted(by: self.chatSortingLogic)
            
            await MainActor.run {
                self.chats = chatsModels
                self.isLoading = false
            }
            
            let refinements = await withTaskGroup(of: (Int64, ChatCellModel.ChatType?, String?, String?, AttributedString?, Bool?).self) { group in
                for chat in chatsData {
                    group.addTask {
                        var rType: ChatCellModel.ChatType? = nil
                        var rTitle: String? = nil
                        var rLetters: String? = nil
                        var rDesc: AttributedString? = nil
                        var rIsForum: Bool? = nil
                        
                        if let userId = chat.privateUserId,
                           let user = try? await TDLibManager.shared.client?.getUser(userId: userId) {
                            switch user.type {
                            case .userTypeDeleted:
                                rType = .deletedAccount
                                rTitle = "Deleted Account"
                                rLetters = "?"
                            case .userTypeBot:
                                rType = .bot
                            default:
                                break
                            }
                        }
                        
                        if chat.isGroup {
                            if let message = chat.lastMessage,
                               let username = await message.senderId.username() {
                                var attributedUsername = AttributedString(username + ": ")
                                attributedUsername.foregroundColor = .white
                                rDesc = attributedUsername + message.description
                            }
                        }
                        
                        if case .chatTypeSupergroup(let data) = chat.type,
                           let supergroup = try? await TDLibManager.shared.client?.getSupergroup(supergroupId: data.supergroupId) {
                            rIsForum = supergroup.isForum
                        }
                        
                        return (chat.id, rType, rTitle, rLetters, rDesc, rIsForum)
                    }
                }
                
                var results: [(Int64, ChatCellModel.ChatType?, String?, String?, AttributedString?, Bool?)] = []
                for await result in group {
                    results.append(result)
                }
                return results
            }
            
            await MainActor.run {
                for (id, rType, rTitle, rLetters, rDesc, rIsForum) in refinements {
                    guard let index = self.chats.firstIndex(where: { $0.id == id }) else { continue }
                    
                    if let rType { self.chats[index].chatType = rType }
                    if let rTitle { self.chats[index].title = rTitle }
                    if let rLetters { self.chats[index].avatar.letters = rLetters }
                    if let rDesc { self.chats[index].messageStyle = .message(rDesc) }
                    if let rIsForum { self.chats[index].isForum = rIsForum }
                }
            }
        }
    }
    
    // MARK: - Pin
    
    private func pinChat(_ chatId: Int64, isPinned: Bool) {
        let index = self.chats.firstIndex { c in c.id == chatId }
        guard let index, index != -1 else { return }
        
        let newValue = !isPinned
        let list = self.folder.chatList
        
        withAnimation {
            self.chats[index].isPinned = newValue
        }
        
        Task.detached {
            do {
                try await TDLibManager.shared.client?.toggleChatIsPinned(
                    chatId: chatId,
                    chatList: list,
                    isPinned: newValue
                )
                self.logger.log("IsPinned updated")
            } catch {
                self.logger.log(error, level: .error)
            }
        }
    }
    
    // MARK: - Mute
    
    private func muteChat(_ chatId: Int64) {
        Task.detached {
            do {
                guard let chat = try await TDLibManager.shared.client?.getChat(chatId: chatId)
                else { return }
                
                let currentNotificationSettings = chat.notificationSettings
                let currentIsMuted = currentNotificationSettings.muteFor != 0
                
                let oneHour = 60 * 60
                let oneDay = 24 * oneHour
                let oneYear = oneDay * 365
                let unmute = 0
                let foreverMute = oneYear + (oneDay * 2)
                
                let newNotificationSettings = currentNotificationSettings.copyWith(
                    muteFor: currentIsMuted ? unmute : foreverMute
                )
                
                try await TDLibManager.shared.client?.setChatNotificationSettings(
                    chatId: chat.id,
                    notificationSettings: newNotificationSettings
                )
                
                await MainActor.run {
                    let index = self.chats.firstIndex { c in c.id == chatId }
                    guard let index, index != -1 else { return }
                    withAnimation {
                        self.chats[index].isMuted = !currentIsMuted
                    }
                }
                
                self.logger.log("Notification settings updated")
            } catch {
                self.logger.log(error, level: .error)
            }
        }
    }
}

// MARK: - Mock

@Observable
class ChatListViewModelMock: ChatListViewModel {
    init() {
        super.init(folder: .main)
        
        self.chats = [
            .init(
                id: 0,
                title: "Saved Messages",
                time: "10:00",
                avatar: .alessandro,
                isMuted: false,
                isPinned: true,
                messageStyle: .message("Your cloud storage"),
                chatType: .savedMessages
            ),
            .init(
                id: 1,
                title: "Alessandro",
                time: "10:09",
                avatar: .alessandro,
                isMuted: false,
                isPinned: false,
                messageStyle: .message("Manage multiple chats and folders 📁"),
                unreadBadgeStyle: .message(count: 3)
            ),
            .init(
                id: 2,
                title: "Marco",
                time: "09:41",
                avatar: .marco,
                isMuted: false,
                isPinned: false,
                messageStyle: .action("is typing")
            ),
            .init(
                id: 3,
                title: "Tech News",
                time: "08:30",
                avatar: .marco,
                isMuted: true,
                isPinned: false,
                messageStyle: .message("New article published"),
                chatType: .channel
            ),
            .init(
                id: 4,
                title: "Deleted Account",
                time: "Yesterday",
                avatar: .marco,
                isMuted: false,
                isPinned: false,
                chatType: .deletedAccount
            ),
            .init(
                id: 5,
                title: "NotificationBot",
                time: "08:00",
                avatar: .marco,
                isMuted: true,
                isPinned: false,
                messageStyle: .message("Your order has shipped!"),
                chatType: .bot
            ),
            .init(
                id: 6,
                title: "Secret Mission",
                time: "07:30",
                avatar: .alessandro,
                isMuted: false,
                isPinned: false,
                messageStyle: .message("This is encrypted 🔒"),
                chatType: .secretChat
            ),
            .init(
                id: 7,
                title: "Design Team",
                time: "Mon",
                avatar: .marco,
                isMuted: false,
                isPinned: false,
                messageStyle: .message("Alessandro: I'll review the mockups."),
                chatType: .group
            )
        ]
    }
    
    override func connectionStateUpdate(state: ConnectionState) {}
    override func updateHandler(update: Update) {}
    override func initChatList() {}
}
