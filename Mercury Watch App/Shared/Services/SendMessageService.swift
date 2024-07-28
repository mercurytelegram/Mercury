//
//  SendMessageViewModel.swift
//  Mercury Watch App
//
//  Created by Marco Tammaro on 28/05/24.
//

import Foundation
import TDLibKit

class SendMessageService {
    
    let chat: Chat
    let logger: LoggerService
    
    init(chat: Chat) {
        self.chat = chat
        self.logger = LoggerService(SendMessageService.self)
    }
    
    func sendTextMessage(_ text: String) {
        
        let formattedText: FormattedText = .init(entities: [], text: text)
        let message: InputMessageText = .init(clearDraft: true, linkPreviewOptions: nil, text: formattedText)
        let messageContent: InputMessageContent = .inputMessageText(message)
        
        Task {
            do {
                let result = try await TDLibManager.shared.client?.sendMessage(
                    chatId: self.chat.id,
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
    
    func sendVoiceNote(_ filePath: URL, _ duration: Int) {
        
        Task {
            do {
                let audioFile: InputFile = .inputFileLocal(.init(path: filePath.relativePath))
                let audioWaveform = try Data(contentsOf: filePath)
                
                let audio: InputMessageVoiceNote = .init(
                    caption: nil,
                    duration: duration,
                    selfDestructType: nil,
                    voiceNote: audioFile,
                    waveform: audioWaveform
                )
                
                let result = try await TDLibManager.shared.client?.sendMessage(
                    chatId: self.chat.id,
                    inputMessageContent: .inputMessageVoiceNote(audio),
                    messageThreadId: nil,
                    options: nil,
                    replyMarkup: nil,
                    replyTo: nil
                )
    
//             try FileManager.default.removeItem(at: filePath)
                self.logger.log(result)
    
            } catch {
                self.logger.log(error, level: .error)
            }
        }
        
    }
    
}
