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
                    offsetForumTopicId: 0,
                    offsetMessageId: 0,
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
                    let forumTopicId = Int64(topic.info.forumTopicId)
                    
                    var messageStyle: ChatCellModel.MessageStyle? = nil
                    if let lastMessage = topic.lastMessage {
                        messageStyle = .message(lastMessage.description)
                    }
                    
                    var unreadBadgeStyle: ChatCellModel.UnreadStyle? = nil
                    if topic.unreadCount > 0 {
                        unreadBadgeStyle = .message(count: topic.unreadCount)
                    }
                    
                    let model = ChatCellModel(
                        id: self.chatId,
                        messageThreadId: forumTopicId,
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
                
                let topics = newTopics
                await MainActor.run {
                    self.topics = topics
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

// MARK: - Mock

@Observable
class ForumTopicsViewModelMock: ForumTopicsViewModel {
    init() {
        super.init(chatId: 0)
        self.isLoading = false
        self.error = nil
        self.topics = [
            .init(
                id: 0,
                messageThreadId: 101,
                position: 0,
                title: "Announcements",
                time: "10:42",
                avatar: AvatarModel(
                    avatarImage: nil,
                    letters: "A",
                    isFullScreen: false
                ),
                isMuted: false,
                isPinned: true,
                messageStyle: .message("Marco: Release notes are ready."),
                unreadBadgeStyle: .message(count: 2),
                chatType: .group,
                isForum: false
            ),
            .init(
                id: 0,
                messageThreadId: 102,
                position: 1,
                title: "Design Reviews",
                time: "09:18",
                avatar: AvatarModel(
                    avatarImage: nil,
                    letters: "D",
                    isFullScreen: false
                ),
                isMuted: false,
                isPinned: false,
                messageStyle: .message("Alessandro: I added fresh mockups."),
                unreadBadgeStyle: .mention,
                chatType: .group,
                isForum: false
            ),
            .init(
                id: 0,
                messageThreadId: 103,
                position: 2,
                title: "Support",
                time: "Mon",
                avatar: AvatarModel(
                    avatarImage: nil,
                    letters: "S",
                    isFullScreen: false
                ),
                isMuted: true,
                isPinned: false,
                messageStyle: .action("is typing"),
                chatType: .group,
                isForum: false
            )
        ]
    }
    
    override func loadTopics() {}
}
