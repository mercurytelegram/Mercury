//
//  ChatDetailViewModel+Updates.swift
//  Mercury
//
//  Created by Marco Tammaro on 08/11/24.
//

import SwiftUI
import TDLibKit

extension ChatDetailViewModel {
    func updateNewMessage(_ update: UpdateNewMessage) {
        
        let chatId = update.message.chatId
        let messageData = update.message
        
        guard chatId == self.chatId else { return }
        
        // A message with same ID already exist, its updates will
        // be managed by itself, no need to insert a new one
        if messages.contains(where: { $0.id == messageData.id }) {
            return
        }
        
        Task.detached {
            let message = await self.messageModelFrom(messageData)
            
            await MainActor.run {
                self.insertMessage(at: .last, message: message)
            }
        }
    }
    
    @MainActor
    func updateDeleteMessages(_ update: UpdateDeleteMessages) {
        
        let chatId = update.chatId
        let messageIds = update.messageIds
        
        guard chatId == self.chatId else { return }
        
        withAnimation {
            self.messages.removeAll(where: { messageIds.contains($0.id) })
        }
    }
    
    func updateUserStatus(_ update: UpdateUserStatus) {
        
        let userId = update.userId
        let status = update.status
        
        Task.detached {
            do {
                
                guard let chat = try await TDLibManager.shared.client?.getChat(chatId: self.chatId)
                else { return }
                
                var chatUserId: Int64? = nil
                if case .chatTypePrivate(let data) = chat.type {
                    chatUserId = data.userId
                }
                
                guard userId == chatUserId else { return }
                
                await MainActor.run {
                    switch status {
                    case .userStatusOnline(_):
                        self.avatar?.isOnline = true
                    case .userStatusOffline(_):
                        self.avatar?.isOnline = false
                    default:
                        break
                    }
                }
                
            } catch {
                self.logger.log(error, level: .error)
            }
        }
    }
    
    @MainActor
    func updateMessageSendFailed(_ update: UpdateMessageSendFailed) {
        let index = self.messages.firstIndex(where: { $0.id == update.oldMessageId})
        guard let index, index != -1 else { return }
        
        self.messages[index].id = update.message.id
        self.messages[index].stateStyle = .failed
    }
    
    @MainActor
    func updateMessageSendSucceeded(_ update: UpdateMessageSendSucceeded) {
        let index = self.messages.firstIndex(where: { $0.id == update.oldMessageId})
        guard let index, index != -1 else { return }
        
        self.messages[index].id = update.message.id
        self.messages[index].stateStyle = .delivered
    }
    
    func updateMessageContentOpened(_ update: UpdateMessageContentOpened) {
        
        let messageId = update.messageId
        
        guard self.messages.contains(where: { $0.id == messageId })
        else { return }
        
        Task.detached {
            do {
                
                let messageData = try await TDLibManager.shared.client?.getMessage(chatId: self.chatId, messageId: messageId)
                guard let messageData else { return }
                
                let message = await self.messageModelFrom(messageData)
                
                await MainActor.run {
                    let index = self.messages.firstIndex(where: { $0.id == messageId })
                    guard let index, index != -1 else { return }
                    
                    withAnimation {
                        self.messages[index] = message
                    }
                }
                
            } catch {
                self.logger.log(error, level: .error)
            }
        }
    }
    
    @MainActor
    func updateMessageInteractionInfo(_ update: UpdateMessageInteractionInfo) {
        
        let messageId = update.messageId
        
        let index = self.messages.firstIndex(where: { $0.id == messageId })
        guard let index, index != -1 else { return }
        
        withAnimation {
            if let reactions = update.interactionInfo?.reactions?.reactions {
                self.messages[index].reactions = self.reactionsModelFrom(reactions)
            } else {
                self.messages[index].reactions = []
            }
        }
    }
    
    func updateMessageContent(messageId: Int64) {
        
        guard self.messages.contains(where: { $0.id == messageId })
        else { return }
        
        Task.detached {
            do {
                
                let messageData = try await TDLibManager.shared.client?.getMessage(chatId: self.chatId, messageId: messageId)
                guard let messageData else { return }
                
                let message = await self.messageModelFrom(messageData)
                
                await MainActor.run {
                    let index = self.messages.firstIndex(where: { $0.id == messageId })
                    guard let index, index != -1 else { return }
                    
                    withAnimation {
                        self.messages[index] = message
                    }
                }
                
            } catch {
                self.logger.log(error, level: .error)
            }
        }
    }
    
    @MainActor
    func updateChatReadOutbox(_ update: UpdateChatReadOutbox) {
        
        let latestReadMessageId = update.lastReadOutboxMessageId
        
        for (index, message) in self.messages.enumerated() {
            if message.stateStyle == .delivered && message.id <= latestReadMessageId {
                withAnimation {
                    self.messages[index].stateStyle = .seen
                }
            }
        }
    }
    
}
