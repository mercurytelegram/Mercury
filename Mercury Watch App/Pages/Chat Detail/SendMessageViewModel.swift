//
//  SendMessageViewModel.swift
//  Mercury Watch App
//
//  Created by Marco Tammaro on 28/05/24.
//

import Foundation
import TDLibKit

class SendMessageViewModel: TDLibViewModel {
   
    let chat: ChatCellModel
    init(chat: ChatCellModel) {
        self.chat = chat
        super.init()
    }
    
    func sendTextMessage(_ text: String) {
        
        let formattedText: FormattedText = .init(entities: [], text: text)
        let message: InputMessageText = .init(clearDraft: true, linkPreviewOptions: nil, text: formattedText)
        let messageContent: InputMessageContent = .inputMessageText(message)
        
        Task {
            do {
                let result = try await TDLibManager.shared.client?.sendMessage(
                    chatId: self.chat.td.id,
                    inputMessageContent: messageContent,
                    messageThreadId: nil,
                    options: nil,
                    replyMarkup: nil,
                    replyTo: nil
                )
                self.logger.log(result)
            } catch {
                self.logger.log(error, level: .error)
            }
        }
    }
    
}
