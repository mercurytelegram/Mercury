//
//  ChatViewModel.swift
//  Mercury Watch App
//
//  Created by Marco Tammaro on 14/05/24.
//

import Foundation
import TDLibKit
import SwiftUI

class ChatDetailViewModel: TDLibViewModel {
    
    @Published var isLoadingInitialMessages = true
    @Published var messages: [Message] = []
    @Published var showStickersView = false
    
    var canSendVoiceNotes: Bool {
        return self.chat.td.permissions.canSendVoiceNotes
    }
    
    var canSendText: Bool {
        return self.chat.td.permissions.canSendBasicMessages
    }
    
    var canSendStickers: Bool {
        return self.chat.td.permissions.canSendOtherMessages
    }
    
    let chat: ChatCellModel
    init(chat: ChatCellModel) {
        self.chat = chat
        super.init()
        self.requestInitialMessage()
    }
    
    func getMessageVM(for message: Message) -> MessageViewModel {
        MessageViewModel(message: message, chat: chat.td)
    }
    
    override func updateHandler(update: Update) {
        super.updateHandler(update: update)
        switch update {
        case .updateChatLastMessage(let update):
            self.updateLastMessage(chatId: update.chatId, message: update.lastMessage)
        case .updateDeleteMessages(let update):
            self.updateDeleteMessages(chatId: update.chatId, messageIds: update.messageIds)
        default:
            break
        }
    }
    
    func updateLastMessage(chatId: Int64, message: Message?) {
        guard chatId == self.chat.td.id else { return }
        
        DispatchQueue.main.async {
            if let message {
                self.insertMessage(at: .last, message: message)
            }
        }
    }
    
    func updateDeleteMessages(chatId: Int64, messageIds: [Int64]) {
        guard chatId == self.chat.td.id else { return }
        
        DispatchQueue.main.async {
            
            for id in messageIds {
                withAnimation {
                    self.messages.removeAll(where: { $0.id == id })
                }
            }

        }
    }
    
    func requestInitialMessage() {
        
        Task {
            do {
                let result = try await TDLibManager.shared.client?.getChatHistory(
                    chatId: chat.td.id,
                    fromMessageId: nil,
                    limit: 30,
                    offset: 0,
                    onlyLocal: false
                )
                
                if let resultMessages = result?.messages {
                    DispatchQueue.main.async {
                        
                        for elem in resultMessages.reversed() {
                            self.insertMessage(at: .last, message: elem)
                        }
                        
                        Task {
                            if resultMessages.count == 1 {
                                await self.requestMoreMessages()
                            }
                            
                            DispatchQueue.main.async {
                                self.isLoadingInitialMessages = false
                            }
                        }
                    }
                }
                
            } catch {
                self.logger.log(error, level: .error)
            }
        }
        
    }
    
    func requestMoreMessages(limit: Int = 30) async {
        self.logger.log("loading \(limit) messages")
        
        let result2 = try? await TDLibManager.shared.client?.getChatHistory(
            chatId: chat.td.id,
            fromMessageId: self.messages.first?.id,
            limit: limit,
            offset: 0,
            onlyLocal: false
        )
        
        DispatchQueue.main.async {
            for elem in result2?.messages ?? [] {
                self.insertMessage(at: .first, message: elem)
            }
        }
    }
    
    
    enum InsertAt { case first, last}
    func insertMessage(at: InsertAt, message: Message) {
        
        if message.errorSending { return }
        
        // if message has been already shown, update it bu removing the old one
        self.messages.removeAll(where: { $0.id == message.id })
        
        // if a message has been sent, use the local file path to update it
        if let msgFilePath = message.contentLocalFilePath {
            self.messages.removeAll(where: { $0.contentLocalFilePath == msgFilePath })
        }
        
        withAnimation {
            switch at {
            case .first:
                self.messages.insert(message, at: 0)
            case .last:
                self.messages.append(message)
            }
        }
    }
    
    func onOpenChat() {
        Task {
            do {
                try await TDLibManager.shared.client?.openChat(chatId: self.chat.td.id)
            } catch {
                self.logger.log(error, level: .error)
            }
        }
    }
    
    func onCloseChat() {
        Task {
            do {
                try await TDLibManager.shared.client?.closeChat(chatId: self.chat.td.id)
            } catch {
                self.logger.log(error, level: .error)
            }
        }
    }
    
    func didVisualize(_ id: Int64) {
        Task {
            do {
                try await TDLibManager.shared.client?.viewMessages(
                    chatId: self.chat.td.id,
                    forceRead: true,
                    messageIds: [id],
                    source: nil
                )
            } catch {
                self.logger.log(error, level: .error)
            }
        }
    }

    
}
