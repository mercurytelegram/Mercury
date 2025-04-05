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
class ChatDetailViewModel: TDLibViewModel {
    
    enum InsertAt { case first, last, index(_ value: Int)}
    
    var chatId: Int64
    
    var chatName: String?
    var isLoadingInitialMessages: Bool = false
    var isLoadingMoreMessages: Bool = false
    
    var showAudioMessageView: Bool = false
    var showStickersView: Bool = false
    var showOptionsView: Bool = false
    var showChatInfoView: Bool = false
    
    var canSendVoiceNotes: Bool?
    var canSendText: Bool?
    var canSendStickers: Bool?
    
    var messages: [MessageModel] = []
    var selectedMessage: MessageModel?
    var avatar: AvatarModel?
    
    var sendService: SendMessageService?
    
    var chatAction: ChatAction?
    var chatActionTimer: Timer?
    
    var messageToReadId: Int64? = nil
    
    init(chatId: Int64) {
        self.chatId = chatId
        super.init()
        
        self.chatActionTimer = Timer.scheduledTimer(
            withTimeInterval: 1,
            repeats: true,
            block: { [weak self] _ in
                guard let self else { return }
                self.setChatAction(self.chatAction)
            }
        )
        
        self.loadInitialChatData()
    }
    
    deinit {
        chatActionTimer?.invalidate()
        chatActionTimer = nil
    }
    
    func loadInitialChatData() {
        
        self.isLoadingInitialMessages = true
        
        Task.detached(priority: .high) {
            do {
             
                guard let chat = try await TDLibManager.shared.client?.getChat(chatId: self.chatId)
                else { return }
                
                let lastReadMessageId: Int64? = chat.lastReadInboxMessageId
                
                await MainActor.run {
                    self.sendService = SendMessageService(chat: chat)
                    self.chatName = chat.title
                    self.canSendVoiceNotes = chat.permissions.canSendVoiceNotes
                    self.canSendText = chat.permissions.canSendBasicMessages
                    self.canSendStickers = chat.permissions.canSendOtherMessages
                    self.avatar = chat.toAvatarModel()
                }
                
                let firstBatchMessages = await self.requestMessages(
                    fromId: lastReadMessageId,
                    direction: .all
                )
                
                await MainActor.run { [lastReadMessageId] in
                    for msg in firstBatchMessages {
                        self.insertMessage(at: .first, message: msg)
                    }
                    
                    withAnimation {
                        self.isLoadingInitialMessages = false
                    }
                    
                    // Calculate the id of the first unread message 
                    for message in self.messages {
                        if let lastRead = lastReadMessageId,
                           self.messageToReadId == nil,
                           message.id > lastRead {
                            self.messageToReadId = message.id
                            break
                        }
                    }
                    
                }
                
            } catch {
                self.logger.log(error, level: .error)
                self.isLoadingInitialMessages = false
            }
        }
    }
    
    override func updateHandler(update: Update) {
        super.updateHandler(update: update)
        DispatchQueue.main.async {
            switch update {
            case .updateUserStatus(let update):
                self.updateUserStatus(update)
            case .updateNewMessage(let update):
                self.updateNewMessage(update)
            case .updateDeleteMessages(let update):
                self.updateDeleteMessages(update)
            case .updateMessageSendFailed(let update):
                self.updateMessageSendFailed(update)
            case .updateMessageSendSucceeded(let update):
                self.updateMessageSendSucceeded(update)
            case .updateMessageContent(let update):
                self.updateMessageContent(messageId: update.messageId)
            case .updateMessageInteractionInfo(let update):
                self.updateMessageInteractionInfo(update)
            case .updateChatReadOutbox(let update):
                self.updateChatReadOutbox(update)
            case .updateMessageContentOpened(let update):
                self.updateMessageContentOpened(update)
            default:
                break
            }
        }
    }
     
    /// Do not call this function manually, it is periodically called from a task
    private func setChatAction(_ action: ChatAction?) {
        Task.detached(priority: .background) {
            do {
                try await TDLibManager.shared.client?.sendChatAction(
                    action: action,
                    businessConnectionId: nil,
                    chatId: self.chatId,
                    messageThreadId: 0
                )
            } catch {
                self.logger.log(error, level: .error)
            }
        }
    }
    
}


// MARK: - Mock
@Observable
class ChatDetailViewModelMock: ChatDetailViewModel {
    init() {
        super.init(chatId: 0)
        canSendText = true
        canSendVoiceNotes = true
        canSendStickers = true
        
        chatName = "Astro"
        avatar = .astro
    }
    
    override func loadInitialChatData() {
        self.messages = [
            .init(
                id: 0,
                isSenderHidden: true,
                date: .iPhonePresentationDate,
                isOutgoing: false,
                content: .text("Hello World 👋")
            ),
            .init(
                id: 1,
                isSenderHidden: true,
                date: .iPhonePresentationDate,
                isOutgoing: false,
                content: .text("Landed on Mercury? 👽")
            ),
            .init(
                id: 2,
                isSenderHidden: true,
                date: .appleWatchPresentationDate,
                isOutgoing: true,
                content: .text("Yes, it's amazing! 😍")
            ),
//            
//            .init(
//                id: 3,
//                isSenderHidden: true,
//                date: .now,
//                isOutgoing: false,
//                content: .voiceNote(model: .init(getPlayer: {
//                    PlayerServiceMock()
//                }))
//            ),
        ]
    }
}
