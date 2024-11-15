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
    
    var userCellModel: UserCellModel?
    
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
    
    override func connectionStateUpdate(state: ConnectionState) {
        DispatchQueue.main.async {
            if case .connectionStateReady = state {
                self.getUserCellModel()
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
    
    func getUserCellModel() {
        
        Task.detached(priority: .userInitiated) {
            
            do {
                guard let user = try await TDLibManager.shared.client?.getMe()
                else { return }
                
                let fullname = user.firstName + " " + user.lastName
                let model = UserCellModel(
                    avatar: user.toAvatarModel(),
                    fullname: fullname
                )
                
                await MainActor.run {
                    withAnimation {
                        self.userCellModel = model
                    }
                }
                
            } catch {
                self.logger.log(error, level: .error)
            }
        }
    }
    
}

// MARK: - Mock
@Observable
class HomeViewModelMock: HomeViewModel {
    override func getUserCellModel() {
        self.userCellModel = UserCellModel(avatar: .astro, fullname: "John Appleseed")
    }
}
