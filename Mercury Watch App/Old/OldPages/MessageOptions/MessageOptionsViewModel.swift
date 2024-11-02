//
//  MessageOptionsViewModel.swift
//  Mercury Watch App
//
//  Created by Alessandro Alberti on 11/09/24.
//

import SwiftUI
import TDLibKit

class MessageOptionsViewModel: ObservableObject {
    @Published var emojis: [String] = []
    @Published var selectedEmoji: String?
    
    var messageId: Int64
    var chatId: Int64
    
    let logger = LoggerService(MessageOptionsViewModel.self)
    let columns = [
        GridItem(.adaptive(minimum: 40))
    ]
    
    init(messageId: Int64, chatId: Int64) {
        self.messageId = messageId
        self.chatId = chatId
        
        Task {
            await self.getReactions()
            await self.getSelectedEmoji()
        }
    }
    
    func getReactions() async {
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
    
    func getSelectedEmoji() async {
        
        do {
            
            guard let message = try await TDLibManager.shared.client?.getMessage(chatId: chatId, messageId: messageId), 
                  let reactions = message.interactionInfo?.reactions?.reactions,
                  let chosenReaction =  reactions.first(where: { $0.isChosen })
            else { return }
            
            if case .reactionTypeEmoji(let type) = chosenReaction.type {
                await MainActor.run {
                    self.selectedEmoji = type.emoji
                }
            }
            
        } catch {
            self.logger.log(error, level: .error)
        }
        
        
    }
    
    func sendReaction(_ emoji: String) async {
        
        WKInterfaceDevice.current().play(.click)
        await MainActor.run {
            self.selectedEmoji = emoji
        }
        
        do {
            _ = try await TDLibManager.shared.client?.addMessageReaction(
                chatId: chatId,
                isBig: false,
                messageId: messageId,
                reactionType: .reactionTypeEmoji(ReactionTypeEmoji(emoji: emoji)),
                updateRecentReactions: false
            )
            
            WKInterfaceDevice.current().play(.success)
            
        } catch {
            WKInterfaceDevice.current().play(.failure)
            self.logger.log(error, level: .error)
        }
        
    }
}
