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
    var messageId: Int64
    var chatId: Int64
    
    let columns = [
        GridItem(.adaptive(minimum: 40))
    ]
    
    init(messageId: Int64, chatId: Int64) {
        self.messageId = messageId
        self.chatId = chatId
        
        Task {
            await self.getReactions()
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
    
    func sendReaction(_ emoji: String) async {
        let _ = try? await TDLibManager.shared.client?.addMessageReaction(
            chatId: chatId,
            isBig: false,
            messageId: messageId,
            reactionType: .reactionTypeEmoji(ReactionTypeEmoji(emoji: emoji)),
            updateRecentReactions: false)
        WKInterfaceDevice.current().play(.click)
    }
}
