//
//  ChatListMock.swift
//  Mercury Watch App
//
//  Created by Alessandro Alberti on 25/05/24.
//

import SwiftUI
import TDLibKit

class MockChatListViewModel: ChatListViewModel {
    override init() {
        super.init()
        
        self.isMock = true
        self.isLoading = false
        self.chats = previewChats
        self.folders.insert(ChatFolder(title: "Space 🔭🛰️", chatList: .chatListFolder(.init(chatFolderId: 0))), at: 1)
    }
    
    let previewChats: [ChatCellModel] = [
        .preview(
            title: "Alessandro",
            message: "How's the view from space? 🚀✨",
            unreadCount: 3,
            imageName: "alessandro"
        ),
        .preview(
            title: "Marco",
            message: "Have you landed on Mercury yet?",
            unreadCount: 1,
            showUnreadReaction: true,
            imageName: "marco"
        ),
        .preview(
            title: "Mission Control",
            sender: "Houston",
            message: "We have a problem!",
            color: .blue,
            imageName: "MissionControl"
        ),
    ]
    
    let previewArchivedChats: [ChatCellModel] = [
        .preview(
            title: "iOS Devs",
            sender: "Alessandro",
            message: "Who's excited for WWDC? 😁",
            color: .orange
        ),
        .preview(
            title: "Craig",
            message: "Let's rock! 🎸",
            unreadCount: 3,
            color: .blue
        ),
        .preview(
            title: "Lisa",
            message: "I'm on the roof! ☀️",
            color: .green
        )
    ]
    
    override func selectChatFolder(_ chat: ChatFolder) {
        self.chats = []
        
        switch chat {
        case .main:
            self.chats = previewChats
        case .archive:
            self.chats = previewArchivedChats
        default:
            break
        }
    }
    
    override func updateHandler(update: Update) {}
    override func connectionStateUpdate(state: ConnectionState) {}
}
