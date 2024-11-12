//
//  LoginViewModel.swift
//  Mercury Watch App
//
//  Created by Marco Tammaro on 02/11/24.
//

import SwiftUI
import TDLibKit

@Observable
class HomeViewModel: TDLibViewModel {
    
    var folders: [ChatFolder] = [.main, .archive]
    var navigationPath = NavigationPath()
    
    override init() {
        super.init()
        self.navigationPath.append(ChatFolder.main)
    }
    
    override func updateHandler(update: Update) {
        DispatchQueue.main.async {
            switch update {
            case .updateChatFolders(let update):
                self.updateChatFolders(update)
            default:
                break
            }
        }
    }
    
    @MainActor
    func updateChatFolders(_ update: UpdateChatFolders) {
        self.folders = [.main, .archive]
        for chatFolderInfo in update.chatFolders {
            let chatList = ChatList.chatListFolder(ChatListFolder(chatFolderId: chatFolderInfo.id))
            let folder = ChatFolder(title: chatFolderInfo.title, chatList: chatList)
            
            withAnimation {
                // To leave Archive in the last position
                self.folders.insert(folder, at: self.folders.count - 1)
            }
        }
    }
    
}

// MARK: - Mock
@Observable
class HomeViewModelMock: HomeViewModel {
    
}
