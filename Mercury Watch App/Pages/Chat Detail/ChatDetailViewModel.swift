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
    @Published var showAudioMessageView: Bool = false
    @Published var showStickersView = false
    @Published var showOptionsView = false
    @Published var selectedMessage: Message?
    
    var chatAction: ChatAction?
    var chatActionTimer: Timer?
    
    var localRemoteIdMap: [Int64 : Int64] = [:]
    
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
    let sendService: SendMessageService
    
    init(chat: ChatCellModel, sendService: SendMessageService? = nil) {
        self.chat = chat
        self.sendService = sendService ?? SendMessageService(chat: chat.td)
        super.init()
        self.requestInitialMessage()
        
        chatActionTimer = Timer.scheduledTimer(
            withTimeInterval: 1,
            repeats: true,
            block: { [weak self] _ in
                guard let self else { return }
                self.setChatAction(self.chatAction)
            }
        )
    }
    
    deinit {
        chatActionTimer?.invalidate()
        chatActionTimer = nil
    }
    
    func getMessageVM(for message: Message) -> MessageViewModel {
        MessageViewModel(message: message, chat: chat)
    }
    
    override func updateHandler(update: Update) {
        super.updateHandler(update: update)
        switch update {
        case .updateNewMessage(let update):
            self.updateNewMessage(chatId: update.message.chatId, message: update.message)
        case .updateDeleteMessages(let update):
            self.updateDeleteMessages(chatId: update.chatId, messageIds: update.messageIds)
        case .updateMessageSendFailed(let update):
            self.localRemoteIdMap[update.oldMessageId] = update.message.id
        case .updateMessageSendSucceeded(let update):
            self.localRemoteIdMap[update.oldMessageId] = update.message.id
        default:
            break
        }
    }
    
    func updateNewMessage(chatId: Int64, message: Message?) {
        guard let message, chatId == self.chat.td.id
        else { return }
        
        // A message with same ID already exist, its updates will
        // be managed by itself, no need to insert a new one
        if messages.contains(where: { $0.id == message.id }) {
            return
        }
        
        DispatchQueue.main.async {
            self.insertMessage(at: .last, message: message)
            self.localRemoteIdMap[message.id] = 0
        }
    }
    
    func updateDeleteMessages(chatId: Int64, messageIds: [Int64]) {
        guard chatId == self.chat.td.id else { return }
        
        DispatchQueue.main.async {
            for id in messageIds {
                withAnimation {
                    
                    // Remove messages from other client (remote id == local id)
                    self.messages.removeAll(where: { $0.id == id })
                    
                    // Remove messages sent from mercury (remote id != local id)
                    if let idMapResult = self.localRemoteIdMap.first(where: { $1 == id }) {
                        self.messages.removeAll(where: { $0.id == idMapResult.key })
                    }
                    
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
    
    
    enum InsertAt { case first, last, index(_ value: Int)}
    func insertMessage(at: InsertAt, message: Message) {
        
        if message.errorSending { return }
        
        // if message has been already shown, update it by removing the old one
        self.messages.removeAll(where: { $0.id == message.id })
        
        withAnimation {
            switch at {
            case .first:
                self.messages.insert(message, at: 0)
            case .last:
                self.messages.append(message)
            case .index(let value):
                self.messages.insert(message, at: value)
            }
        }
    }
    
    func onOpenChat() {
        chatAction = nil
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
    
    func showInputController() {
        
        self.chatAction = .chatActionTyping
        
        WKExtension.shared()
            .visibleInterfaceController?
            .presentTextInputController(withSuggestions: [],
                                        allowedInputMode: .plain) { result in
                
                self.chatAction = nil
                guard let result = result as? [String],
                      let text = result.first
                else { return }
                
                self.sendService.sendTextMessage(text)
                
            }
    }
    
    func showVoiceRecording() {
        self.chatAction = .chatActionRecordingVoiceNote
        self.showAudioMessageView = true
    }
    
    func showStickersSelection() {
        self.showStickersView = true
    }
    
    /// Do not call this function manually, it is periodically called from a task
    private func setChatAction(_ action: ChatAction?) {
        Task.detached(priority: .background) {
            do {
                try await TDLibManager.shared.client?.sendChatAction(
                    action: action,
                    businessConnectionId: nil,
                    chatId: self.chat.td.id,
                    messageThreadId: 0
                )
            } catch {
                self.logger.log(error, level: .error)
            }
        }
    }
}
