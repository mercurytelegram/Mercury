//
//  MessageOptionsViewModel.swift
//  Mercury Watch App
//
//  Created by Alessandro Alberti on 11/09/24.
//

import SwiftUI
import TDLibKit

@Observable
class MessageOptionsViewModel {
    
    var emojis: [String] = []
    var selectedEmoji: String? = nil
    var showReportMessageOptions: Bool = false
    
    var shouldDisplayReportButton: Bool {
        if case .chatTypeBasicGroup(_) = model.chatType { return true }
        if case .chatTypeSupergroup(_) = model.chatType { return true }
        return false
    }
    
    let model: MessageOptionsModel
    let reportMessageOptions: [ReportReason] = [.reportReasonSpam, .reportReasonViolence, .reportReasonPornography, .reportReasonChildAbuse, .reportReasonCopyright, .reportReasonUnrelatedLocation, .reportReasonFake, .reportReasonIllegalDrugs, .reportReasonPersonalDetails]
    
    private let logger = LoggerService(MessageOptionsViewModel.self)
    
    init(model: MessageOptionsModel) {
        self.model = model
        Task.detached(priority: .high) {
            await self.getReactions()
            await self.getSelectedEmoji()
        }
    }
    
    fileprivate func getReactions() async {
        
        let chatId = model.chatId
        let messageId = model.messageId
        
        let reactions = try? await TDLibManager.shared.client?.getMessageAvailableReactions(
            chatId: chatId,
            messageId: messageId,
            rowSize: 4
        )
        
        let availableEmojis = reactions?.topReactions.map { reaction in
            if case .reactionTypeEmoji(let emojiReaction) = reaction.type {
                return emojiReaction.emoji
            }
            return "?"
        }
        
        await MainActor.run {
            self.emojis = availableEmojis ?? []
        }
    }
    
    fileprivate func getSelectedEmoji() async {
        
        let chatId = model.chatId
        let messageId = model.messageId
        
        do {
            
            guard let message = try await TDLibManager.shared.client?.getMessage(
                chatId: chatId,
                messageId: messageId
            ) else { return }
            
            let reactions = message.interactionInfo?.reactions?.reactions
            let chosenReaction =  reactions?.first(where: { $0.isChosen })
            
            if case .reactionTypeEmoji(let type) = chosenReaction?.type {
                await MainActor.run {
                    self.selectedEmoji = type.emoji
                }
            }
            
        } catch {
            self.logger.log(error, level: .error)
        }
    }
    
    func sendReaction(_ emoji: String) async {
        
        let chatId = model.chatId
        let messageId = model.messageId
        
        WKInterfaceDevice.current().play(.click)
        await MainActor.run {
            self.selectedEmoji = emoji
        }
        
        model.sendService.sendReaction(
            emoji,
            chatId: chatId,
            messageId: messageId
        )
        
    }
    
    func reportMessage(_ reason: ReportReason) {
        let chatId = model.chatId
        let messageId = model.messageId
        
        Task {
            do {
                try await TDLibManager.shared.client?.reportChat(chatId: chatId, messageIds: [messageId], reason: reason, text: nil)
            } catch {
                logger.log(error)
            }
            
            await MainActor.run {
                self.showReportMessageOptions = false
            }
        }
    }
}

class MessageOptionsViewModelMock: MessageOptionsViewModel {
    init() {
        super.init(
            model: MessageOptionsModel(
                chatId: 0,
                messageId: 0,
                sendService: SendMessageServiceMock { _ in }
            )
        )
        
    }
    
    override var shouldDisplayReportButton: Bool {
        return true
    }
    
    override func getReactions() async {
        self.emojis = ["🤣", "❤️", "🤝", "🔥",
                       "👌", "😱", "👀", "‍‍❤️‍🔥",
                       "🤯", "😢", "😭", "🗿"]
    }
    
    override func getSelectedEmoji() async {}
    override func reportMessage(_ reason: ReportReason) {
        self.showReportMessageOptions = false
    }
}
