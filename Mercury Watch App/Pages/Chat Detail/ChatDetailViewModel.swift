//
//  ChatViewModel.swift
//  Mercury Watch App
//
//  Created by Marco Tammaro on 14/05/24.
//

import Foundation
import TDLibKit

class ChatDetailViewModel: TDLibViewModel {
    
    @Published var messages: [Message] = []
    @Published var isLoadingInitialMessages = true
    
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
        default:
            break
        }
    }
    
    func updateLastMessage(chatId: Int64, message: Message?) {
        guard chatId == self.chat.td.id else { return }
        
        // If sendingState is nil, the message has been sent correctly
        guard message?.sendingState == nil else { return }
        
        DispatchQueue.main.async {
            if let message {
                self.messages.removeAll { m in m.id == message.id }
                self.messages.append(message)
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
                        self.messages = resultMessages.reversed()
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
                print("[CLIENT] [\(type(of: self))] [\(#function)] error: \(error)")
            }
        }
        
    }
    
    func requestMoreMessages(limit: Int = 30) async {
        print("[CLIENT] [\(type(of: self))] [\(#function)]")
        
        let result2 = try? await TDLibManager.shared.client?.getChatHistory(
            chatId: chat.td.id,
            fromMessageId: self.messages.first?.id,
            limit: limit,
            offset: 0,
            onlyLocal: false
        )
        
        DispatchQueue.main.async {
            for elem in result2?.messages ?? [] {
                self.messages.insert(elem, at: 0)
            }
        }
    }
    
}
