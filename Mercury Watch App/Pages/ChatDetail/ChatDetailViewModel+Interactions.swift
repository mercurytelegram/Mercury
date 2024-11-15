//
//  ChatDetailViewModel+Interactions.swift
//  Mercury Watch App
//
//  Created by Marco Tammaro on 08/11/24.
//

import SwiftUI

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
        
        WKExtension.shared()
            .visibleInterfaceController?
            .presentTextInputController(withSuggestions: [],
                                        allowedInputMode: .plain) { result in
                
                self.chatAction = nil
                guard let result = result as? [String],
                      let text = result.first
                else { return }
                
                self.sendService?.sendTextMessage(text)
                
            }
    }
    
    func onPressVoiceRecording() {
        self.chatAction = .chatActionRecordingVoiceNote
        self.showAudioMessageView = true
    }
    
    func onPressStickersSelection() {
        self.showStickersView = true
    }
    
    func onDublePressOf(_ message: MessageModel) {
        selectedMessage = message
        showOptionsView = true
    }
    
    func onMessageListAppear(_ proxy: ScrollViewProxy) {
        
        guard let lastReadInboxMessageId else { return }
        
        // Scroll to the first unread message
        for message in messages {
            
            if case .pill(_,_) = message.content { continue }
            
            if message.id >= lastReadInboxMessageId {
                proxy.scrollTo(message.id)
                break
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
        
        // Pill messages doesn't need to be marked as seen
        if case .pill(_,_) = message.content { return }
        
        Task.detached(priority: .background) {
            do {
                try await TDLibManager.shared.client?.viewMessages(
                    chatId: self.chatId,
                    forceRead: true,
                    messageIds: [message.id],
                    source: nil
                )
            } catch {
                self.logger.log(error, level: .error)
            }
        }
    }
    
}
