//
//  Folder.swift
//  Mercury Watch App
//
//  Created by Alessandro Alberti on 06/07/24.
//

import TDLibKit
import SwiftUI

struct ChatFolder: Hashable {
    var title: String
    var chatList: ChatList
    
    var iconName: String {
        if case ChatList.chatListArchive = chatList {
            return "archivebox"
        }
        return "folder"
    }
    
    var color: Color {
        if case ChatList.chatListArchive = chatList {
            return .orange
        }
        return .blue
    }
    
    static var main: ChatFolder {
        ChatFolder(title: "All Chats", chatList: .chatListMain)
    }
    static var archive: ChatFolder {
        ChatFolder(title: "Archive", chatList: .chatListArchive)
    }
}
