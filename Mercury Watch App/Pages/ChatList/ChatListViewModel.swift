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
    
    var folder: ChatFolder
    
    var chats: [ChatCellModel] = []
    var isLoading: Bool = false
    var showNewMessage: Bool = false
    
    init(folder: ChatFolder) {
        self.folder = folder
        super.init()
        
        self.initChatList()
    }
    
    func didPressMute(on chat: ChatCellModel) {
        guard let id = chat.id else { return }
        muteChat(id)
    }
    
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
    func initChatList() {
        
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
                
                /// A value of 0 mens unmute
                let unmute = 0
                /// A values above 366 days means mute forever
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
                title: "Alessandro",
                time: "10:09",
                avatar: .alessandro,
                isMuted: false,
                messageStyle: .message("Lorem ipsum dolor sit amet."),
                unreadBadgeStyle: .message(count: 3)
            ),
            .init(
                id: 1,
                title: "Marco",
                time: "09:41",
                avatar: .marco,
                isMuted: false,
                messageStyle: .action("is typing"),
                unreadBadgeStyle: .reaction
            ),
        ]
    }
    
    override func connectionStateUpdate(state: ConnectionState) {}
    override func updateHandler(update: Update) {}
    override func initChatList() {}
}
