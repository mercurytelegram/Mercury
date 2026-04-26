//
//  ForumTopicsViewModel.swift
//  Mercury Watch App
//
//  Created by Dmytro Manko on 26/04/26.
//

import Foundation
import SwiftUI
import TDLibKit

@Observable
class ForumTopicsViewModel {
    
    var chatId: Int64
    var topics: [ChatCellModel] = []
    var isLoading: Bool = false
    var error: String?
    
    init(chatId: Int64) {
        self.chatId = chatId
        self.loadTopics()
    }
    
    func loadTopics() {
        self.isLoading = true
        Task.detached {
            do {
                let result = try await TDLibManager.shared.client?.getForumTopics(
                    chatId: self.chatId,
                    limit: 100,
                    offsetDate: 0,
                    offsetMessageId: 0,
                    offsetMessageThreadId: 0,
                    query: ""
                )
                
                guard let forumTopics = result?.topics else {
                    await MainActor.run { self.isLoading = false }
                    return
                }
                
                var newTopics: [ChatCellModel] = []
                for topic in forumTopics {
                    let title = topic.info.name
                    let time = Date(fromUnixTimestamp: topic.lastMessage?.date ?? 0).stringDescription
                    
                    // ✅ Используем уже существующий Message.description -> AttributedString
                    var messageStyle: ChatCellModel.MessageStyle? = nil
                    if let lastMessage = topic.lastMessage {
                        messageStyle = .message(lastMessage.description)
                    }
                    
                    // ✅ Корректный счётчик непрочитанных
                    var unreadBadgeStyle: ChatCellModel.UnreadStyle? = nil
                    if topic.unreadCount > 0 {
                        unreadBadgeStyle = .message(count: topic.unreadCount)
                    }
                    
                    let model = ChatCellModel(
                        id: self.chatId, // ✅ chatId супергруппы для открытия чата
                        messageThreadId: topic.info.messageThreadId,
                        position: Int64(newTopics.count),
                        title: title,
                        time: time,
                        avatar: AvatarModel(
                            avatarImage: nil,
                            letters: String(title.prefix(1)),
                            isFullScreen: false
                        ),
                        isMuted: false,
                        isPinned: false,
                        messageStyle: messageStyle,
                        unreadBadgeStyle: unreadBadgeStyle,
                        chatType: .group,
                        isForum: false
                    )
                    newTopics.append(model)
                }
                
                await MainActor.run {
                    self.topics = newTopics
                    self.isLoading = false
                }
                
            } catch {
                await MainActor.run {
                    self.error = error.localizedDescription
                    self.isLoading = false
                }
            }
        }
    }
}
