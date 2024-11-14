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
        for chatFolderInfo in update.chatFolders {
            let chatList = ChatList.chatListFolder(ChatListFolder(chatFolderId: chatFolderInfo.id))
            let folder = ChatFolder(title: chatFolderInfo.title, chatList: chatList)
            AppState.shared.insertFolder(folder)
        }
    }
    
}

// MARK: - Mock
@Observable
class HomeViewModelMock: HomeViewModel {
    
}
