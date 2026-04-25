//
//  LoginViewModel.swift
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
        
        var chatsData = [Chat]()
        
        do {
            
            chatsData = try await withThrowingTaskGroup(of: Chat?.self) { group in
                for id in ids {
                    group.addTask {
                        try await TDLibManager.shared.client?.getChat(chatId: id)
                    }
                }
                
                var chats: [Chat] = []
                for try await chat in group {
                    if let chat { chats.append(chat) }
                }
                
                return chats
            }
            
        } catch {
            self.logger.log(error, level: .error)
        }
        
        return chatsData
        
    }
    
    func chatCellModelFrom(_ chat: Chat) -> ChatCellModel {
        
        let date = Date(fromUnixTimestamp: chat.lastMessage?.date ?? 0)
        
        var userId: Int64? = nil
        if case .chatTypePrivate(let data) = chat.type {
            userId = data.userId
        }
        
        var avatar = chat.toAvatarModel()
        avatar.userId = userId
        
        let position = chat.positions.first(where: { $0.list == folder.chatList })
        let positionOrder = position?.order.rawValue
        let isPinned = position?.isPinned ?? false
        let isMuted = chat.notificationSettings.muteFor != 0
        
        var messageStyle: ChatCellModel.MessageStyle? = nil
        if let message = chat.lastMessage?.description {
            messageStyle = .message(message)
        }
        
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
            title: chat.title,
            time: date.stringDescription,
            avatar: avatar,
            isMuted: isMuted,
            isPinned: isPinned,
            messageStyle: messageStyle,
            unreadBadgeStyle: unreadBadgeStyle
        )
    }
 
    func chatSortingLogic(elem1: ChatCellModel, elem2: ChatCellModel) -> Bool {
        guard let p1 = elem1.position, let p2 = elem2.position
        else { return true }
        
        // Sorting also by id does not update correctly the group chat's position
        return p1 > p2 // && elem1.id > elem2.id
    }
    
}
