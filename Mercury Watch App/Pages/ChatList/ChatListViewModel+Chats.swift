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
    
    func loadChats(limit: Int = 10) async -> [Chat] {
        
        var chatsData = [Chat]()
        let chatList = folder.chatList
        
        do {
            
            let result = try await TDLibManager.shared.client?.getChats(
                chatList: chatList,
                limit: limit
            )
            
            guard let result else { return [] }
            
            for id in result.chatIds {
                guard let chat = try await TDLibManager.shared.client?.getChat(chatId: id)
                else { continue }
                
                chatsData.append(chat)
            }
            
            self.logger.log(result)
            
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
        
        let letters: String = "\(chat.title.prefix(1))"
        
        var avatar = chat.toAvatarModel()
        avatar.userId = userId
        
        let position = chat.positions.first(where: { $0.list == folder.chatList })?.order.rawValue
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
            position: position,
            title: chat.title,
            time: date.stringDescription,
            avatar: avatar,
            isMuted: isMuted,
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
