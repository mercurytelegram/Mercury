//
//  ChatDetailViewModel+Interactions.swift
//  Mercury Watch App
//
//  Created by Marco Tammaro on 08/11/24.
//

import SwiftUI
import TDLibKit

extension ChatDetailViewModel {
    func onPressLoadMore(_ proxy: ScrollViewProxy) {
        
        withAnimation {
            self.isLoadingMoreMessages = true
        }
        
        Task.detached {
            let lastMessage = self.messages.first
            let newMessages = await self.requestMessages(fromId: lastMessage?.id)
            
            await MainActor.run {
                
                for msg in newMessages {
                    self.insertMessage(at: .first, message: msg)
                }
                
                withAnimation {
                    proxy.scrollTo(lastMessage?.id, anchor: .bottom)
                    self.isLoadingMoreMessages = false
                }
            }
        }
    }
    
    func onPressAvatar() {
        self.showChatInfoView = true
    }
    
    func onPressTextInsert() {
        
        self.chatAction = .chatActionTyping
        let replyTo = self.inputReplyToMessage()
        
        WKExtension.shared()
            .visibleInterfaceController?
            .presentTextInputController(withSuggestions: [],
                                        allowedInputMode: .allowEmoji) { result in
                
                self.chatAction = nil
                guard let result = result as? [String],
                      let text = result.first
                else { return }
                
                self.sendService?.sendTextMessage(text, replyTo: replyTo)
                self.replyToMessage = nil
                
            }
    }
    
    func onPressQuickReplies() {
        self.showQuickRepliesView = true
    }
    
    func sendQuickReply(_ text: String) {
        self.showQuickRepliesView = false
        self.sendService?.sendTextMessage(text, replyTo: inputReplyToMessage())
        self.replyToMessage = nil
    }
    
    func onPressVoiceRecording() {
        self.chatAction = .chatActionRecordingVoiceNote
        self.showAudioMessageView = true
    }
    
    func onPressStickersSelection() {
        self.chatAction = .chatActionChoosingSticker
        self.showStickersView = true
    }
    
    func onDublePressOf(_ message: MessageModel) {
        sendFavoriteReaction(to: message)
    }
    
    func openMessageOptions(for message: MessageModel) {
        selectedMessage = message
        showOptionsView = true
    }
    
    func sendFavoriteReaction(to message: MessageModel) {
        if let selectedReaction = message.reactions.first(where: { $0.isSelected }) {
            sendService?.removeReaction(
                selectedReaction.emoji,
                chatId: chatId,
                messageId: message.id
            )
            return
        }
        
        Task.detached(priority: .userInitiated) {
            let fallbackEmoji = "❤️"
            let reactions = try? await TDLibManager.shared.client?.getMessageAvailableReactions(
                chatId: self.chatId,
                messageId: message.id,
                rowSize: 8
            )
            
            let availableEmojis = reactions?.topReactions.compactMap { reaction -> String? in
                if case .reactionTypeEmoji(let emojiReaction) = reaction.type {
                    return emojiReaction.emoji
                }
                return nil
            } ?? []
            
            guard let emoji = availableEmojis.first(where: { $0 == fallbackEmoji }) ?? availableEmojis.first
            else { return }
            
            self.sendService?.sendReaction(
                emoji,
                chatId: self.chatId,
                messageId: message.id
            )
        }
    }
    
    func toggleReaction(_ reaction: ReactionModel, on message: MessageModel) {
        if reaction.isSelected {
            sendService?.removeReaction(
                reaction.emoji,
                chatId: chatId,
                messageId: message.id
            )
        } else {
            sendService?.sendReaction(
                reaction.emoji,
                chatId: chatId,
                messageId: message.id
            )
        }
    }
    
    func didSelectReply(to message: MessageModel) {
        replyToMessage = message
        showOptionsView = false
    }
    
    func clearReply() {
        replyToMessage = nil
    }
    
    func inputReplyToMessage() -> InputMessageReplyTo? {
        guard let messageId = replyToMessage?.id else { return nil }
        return .inputMessageReplyToMessage(.init(
            checklistTaskId: 0,
            messageId: messageId,
            pollOptionId: "",
            quote: nil
        ))
    }
    
    func onMessageListAppear(_ proxy: ScrollViewProxy) {
        guard didScrollToInitialMessage == false else { return }
        didScrollToInitialMessage = true
        guard let lastReadInboxMessageId else { return }
        
        let messageIds = messages.compactMap { message -> Int64? in
            if case .pill(_, _) = message.content { return nil }
            return message.id
        }
        
        let targetMessageId = messageIds.first { $0 > lastReadInboxMessageId }
            ?? messageIds.first { $0 >= lastReadInboxMessageId }
        
        guard let targetMessageId else { return }
        
        DispatchQueue.main.async {
            withAnimation {
                proxy.scrollTo(targetMessageId, anchor: .top)
            }
        }
    }
    
    func onOpenChat() {
        chatAction = nil
        Task.detached(priority: .background) {
            do {
                try await TDLibManager.shared.client?.openChat(chatId: self.chatId)
            } catch {
                self.logger.log(error, level: .error)
            }
        }
    }
    
    func onCloseChat() {
        Task.detached(priority: .background) {
            do {
                try await TDLibManager.shared.client?.closeChat(chatId: self.chatId)
            } catch {
                self.logger.log(error, level: .error)
            }
        }
    }
    
    func onMessageAppear(_ message: MessageModel) {
        if case .pill(_, _) = message.content { return }
        
        Task.detached(priority: .background) {
            do {
                // Forum topics require messageSourceForumTopicHistory
                let source: MessageSource? = self.messageThreadId != nil
                    ? .messageSourceForumTopicHistory
                    : nil
                
                try await TDLibManager.shared.client?.viewMessages(
                    chatId: self.chatId,
                    forceRead: true,
                    messageIds: [message.id],
                    source: source
                )
            } catch {
                self.logger.log(error, level: .error)
            }
        }
    }
    
    func loadPinnedMessage() async {
        do {
            guard let message = try await TDLibManager.shared.client?.getChatPinnedMessage(chatId: chatId)
            else { return }
            let model = await messageModelFrom(message)
            await MainActor.run {
                self.pinnedMessage = model
            }
        } catch {
            self.logger.log(error, level: .debug)
        }
    }
    
    func scrollToPinnedMessage(_ proxy: ScrollViewProxy) {
        guard let pinnedMessage else { return }
        withAnimation {
            proxy.scrollTo(pinnedMessage.id, anchor: .top)
        }
    }
    
    func joinChat() {
        guard !isJoiningChat else { return }
        isJoiningChat = true
        Task.detached(priority: .userInitiated) {
            do {
                try await TDLibManager.shared.client?.joinChat(chatId: self.chatId)
                guard let chat = try await TDLibManager.shared.client?.getChat(chatId: self.chatId) else { return }
                await MainActor.run {
                    self.canJoinChat = false
                    self.canSendText = chat.permissions.canSendBasicMessages
                    self.canSendVoiceNotes = chat.permissions.canSendVoiceNotes
                    self.canSendStickers = chat.permissions.canSendOtherMessages
                    self.isJoiningChat = false
                }
            } catch {
                self.logger.log(error, level: .error)
                await MainActor.run {
                    self.isJoiningChat = false
                }
            }
        }
    }
    
}
