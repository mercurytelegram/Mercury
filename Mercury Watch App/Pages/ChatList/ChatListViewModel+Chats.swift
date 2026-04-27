//
//  ChatListViewModel+Chats.swift
//  Mercury Watch App
//
//  Created by Marco Tammaro on 02/11/24.
//

import Foundation
import TDLibKit
import SwiftUI

extension ChatListViewModel {
    
    /// This function will download the chat data and gives back their IDs
    func loadChatIds(limit: Int = 10) async -> [Int64] {
        let chatList = folder.chatList
        do {
            let result = try await TDLibManager.shared.client?.getChats(
                chatList: chatList,
                limit: limit
            )
            self.logger.log(result)
            return result?.chatIds ?? []
        } catch {
            self.logger.log(error, level: .error)
        }
        return []
    }
    
    /// This function given a set of Ids return the ``Chat`` data downloaded with ``loadChatIds``
    func loadChats(ids: [Int64]) async -> [Chat] {
        var chats: [Chat] = []
        await withTaskGroup(of: Chat?.self) { group in
            for id in ids {
                group.addTask {
                    return try? await TDLibManager.shared.client?.getChat(chatId: id)
                }
            }
            for await chat in group {
                if let chat { chats.append(chat) }
            }
        }
        return chats
    }
    
    // MARK: - Build ChatCellModel
    
    func chatCellModelFrom(_ chat: Chat, currentUserId: Int64? = nil) -> ChatCellModel {
        
        let date = Date(fromUnixTimestamp: chat.lastMessage?.date ?? 0)
        
        // MARK: Type detection
        var userId: Int64? = nil
        var chatType: ChatCellModel.ChatType = .unknown
        
        switch chat.type {
        case .chatTypePrivate(let data):
            userId = data.userId
            if let currentUserId, data.userId == currentUserId {
                chatType = .savedMessages
            } else {
                chatType = .privateUser
            }
        case .chatTypeSecret(let data):
            userId = data.userId
            chatType = .secretChat
        case .chatTypeSupergroup(let data):
            chatType = data.isChannel ? .channel : .group
        case .chatTypeBasicGroup:
            chatType = .group
        default:
            break
        }
        
        // MARK: Avatar
        var avatar = chat.toAvatarModel()
        avatar.userId = userId
        
        // MARK: Position
        let position = chat.positions.first(where: { $0.list == folder.chatList })
        let positionOrder = position?.order.rawValue
        let isPinned = position?.isPinned ?? false
        let isMuted = chat.notificationSettings.muteFor != 0
        
        // MARK: Title
        let title = chatType == .savedMessages ? "Saved Messages" : chat.title
        
        // MARK: Message style
        var messageStyle: ChatCellModel.MessageStyle? = nil
        if let message = chat.lastMessage?.description {
            messageStyle = .message(message)
        }
        
        // MARK: Unread badge
        var unreadBadgeStyle: ChatCellModel.UnreadStyle? = nil
        if chat.unreadMentionCount != 0 {
            unreadBadgeStyle = .mention
        } else if chat.unreadReactionCount != 0 {
            unreadBadgeStyle = .reaction
        } else if chat.unreadCount != 0 {
            unreadBadgeStyle = .message(count: chat.unreadCount)
        }
        
        return ChatCellModel(
            id: chat.id,
            position: positionOrder,
            title: title,
            time: date.stringDescription,
            avatar: avatar,
            isMuted: isMuted,
            isPinned: isPinned,
            messageStyle: messageStyle,
            unreadBadgeStyle: unreadBadgeStyle,
            chatType: chatType,
        )
    }
    
    // MARK: - Sorting
    
    func chatSortingLogic(elem1: ChatCellModel, elem2: ChatCellModel) -> Bool {
        guard let p1 = elem1.position, let p2 = elem2.position
        else { return true }
        return p1 > p2
    }
}
