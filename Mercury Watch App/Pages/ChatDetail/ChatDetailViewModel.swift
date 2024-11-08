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
    
    var chatId: Int64? {
        didSet { initialize() }
    }
    
    var chatName: String?
    var isLoadingInitialMessages: Bool = false
    var isLoadingMoreMessages: Bool = false
    
    var showAudioMessageView: Bool = false
    var showStickersView: Bool = false
    var showOptionsView: Bool = false
    
    var canSendVoiceNotes: Bool?
    var canSendText: Bool?
    var canSendStickers: Bool?
    
    var messages: [MessageModel] = []
    var selectedMessage: MessageModel?
    var avatar: AvatarModel?
    
    var sendService: SendMessageService?
    var lastReadInboxMessageId: Int64?
    
    var chatAction: ChatAction?
    var chatActionTimer: Timer?
    
    fileprivate func initialize() {
        
        self.chatActionTimer = Timer.scheduledTimer(
            withTimeInterval: 1,
            repeats: true,
            block: { [weak self] _ in
                guard let self else { return }
                self.setChatAction(self.chatAction)
            }
        )
        
        Task.detached(priority: .high) {
            do {
             
                guard let chat = try await TDLibManager.shared.client?.getChat(chatId: self.chatId)
                else { return }
                
                await MainActor.run {
                    self.chatName = chat.title
                    self.canSendVoiceNotes = chat.permissions.canSendVoiceNotes
                    self.canSendText = chat.permissions.canSendBasicMessages
                    self.canSendStickers = chat.permissions.canSendOtherMessages
                    self.lastReadInboxMessageId = chat.lastReadInboxMessageId
                    
                    let letters: String = "\(chat.title.prefix(1))"
                    self.avatar = AvatarModel(tdImage: chat.photo, letters: letters)
                    
                }
                
                self.sendService = self.sendService ?? SendMessageService(chat: chat)
                
                let newMessages = await self.requestMessages(firstBatch: true)
                await MainActor.run {
                    for msg in newMessages {
                        self.insertMessage(at: .first, message: msg)
                    }
                }
                
            } catch {
                self.logger.log(error, level: .error)
            }
        }
    }
    
    deinit {
        chatActionTimer?.invalidate()
        chatActionTimer = nil
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
    
    func getImage(_ message: Message) async -> Image? {
        switch message.content {
        case .messagePhoto( let msg):
            if let imageFile = msg.photo.sizes.first {
                return await FileService.getImage(for: imageFile.photo)
            }
            return nil
        default:
            return nil
        }
        
    }

}


// MARK: - Mock
@Observable
class ChatDetailViewModelMock: ChatDetailViewModel {
    override func initialize() {}
}
