//
//  ChatCellModel.swift
//  Mercury Watch App
//
//  Created by Alessandro Alberti on 14/05/24.
//

import SwiftUI
import TDLibKit

extension [ChatCellModel_Old] {
    func sorted() -> [ChatCellModel_Old] {
        return self.sorted(by: chatSorting)
    }
    
    private func chatSorting(elem1: ChatCellModel_Old, elem2: ChatCellModel_Old) -> Bool {
        // Soting also by id does not update correctly the group chat's position
        return elem1.position > elem2.position // && elem1.td.id > elem2.td.id
    }
}

struct ChatCellModel_Old {
    
    /// TDLibKit ``TDLibKit/Chat`` object
    var td: Chat
    var showUnreadMention: Bool
    var showUnreadReaction: Bool
    var time: String
    var message: AttributedString?
    var avatar: AvatarModel_Old
    var userId: Int64? // nil if is chat group
    var unreadCount: Int
    var position: Int64
    var action: AttributedString?
    var lastReadOutboxMessageId: Int64
    var lastReadInboxMessageId: Int64
    
    var unreadSymbol: String {
        showUnreadMention ? "at.circle.fill" :
        showUnreadReaction ? "heart.circle.fill" :
        "questionmark.circle.fill"
    }
    
    var hasUnreadMsg: Bool {
        unreadCount != 0
    }
    
    var showUnreadSymbol: Bool {
        showUnreadMention || showUnreadReaction
    }
    
    var unreadSymbolColor: Color {
        showUnreadReaction ? .red : .blue
    }
    
    static func from(_ chat: Chat) -> ChatCellModel_Old {
        
        let date = Date(fromUnixTimestamp: chat.lastMessage?.date ?? 0)
        
        var userID: Int64? = nil
        var letters: String = ""
        switch chat.type {
        case .chatTypePrivate(let data):
            userID = data.userId
            //TODO: double prefix for letters
            letters = "\(chat.title.prefix(1))"
        default:
            letters = "\(chat.title.prefix(1))"
        }
        
        return ChatCellModel_Old(
            td: chat,
            showUnreadMention: chat.unreadMentionCount != 0,
            showUnreadReaction: chat.unreadReactionCount != 0,
            time: date.stringDescription,
            message: chat.lastMessage?.description,
            avatar: AvatarModel_Old(tdImage: chat.photo, letters: letters),
            userId: userID,
            unreadCount: 0,
            position: 0,
            action: nil,
            lastReadOutboxMessageId: chat.lastReadOutboxMessageId,
            lastReadInboxMessageId: chat.lastReadInboxMessageId
        )
    }
}
