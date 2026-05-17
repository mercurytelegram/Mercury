//
//  LoginViewModel.swift
//  Mercury Watch App
//
//  Created by Marco Tammaro on 02/11/24.
//

import SwiftUI
import TDLibKit
import WatchKit

@Observable
class HomeViewModel: TDLibViewModel {
    
    var navigationPath = NavigationPath()
    
    var userCellModel: UserCellModel?
    var showNewChat: Bool = false
    var webLinkNotice: WebLinkNotice?
    private let linkLogger = LoggerService(HomeViewModel.self)
    
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
            let folder = ChatFolder(title: chatFolderInfo.name.text.text, chatList: chatList)
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
    
    func didPressNewChat() {
        self.showNewChat = true
    }
    
    func openChat(_ chatId: Int64) {
        self.navigationPath.append(chatId)
    }
    
    func openSavedMessages() {
        Task.detached(priority: .userInitiated) {
            do {
                guard let me = try await TDLibManager.shared.client?.getMe(),
                      let chat = try await TDLibManager.shared.client?.createPrivateChat(
                        force: false,
                        userId: me.id
                      )
                else { return }
                
                await MainActor.run {
                    self.openChat(chat.id)
                }
            } catch {
                self.logger.log(error, level: .error)
            }
        }
    }

    func openURL(_ url: URL) -> OpenURLAction.Result {
        Task {
            await self.handleURL(url)
        }
        return .handled
    }

    private func handleURL(_ url: URL) async {
        if url.isTelegramLink {
            do {
                guard let type = try await TDLibManager.shared.client?.getInternalLinkType(link: url.absoluteString) else {
                    return
                }
                try await openTelegramLink(type)
            } catch {
                linkLogger.log(error, level: .error)
            }
            return
        }

        if url.isWebLink {
            await MainActor.run {
                self.webLinkNotice = WebLinkNotice(url: url)
            }
            return
        }

        await MainActor.run {
            WKExtension.shared().openSystemURL(url)
        }
    }

    private func openTelegramLink(_ type: InternalLinkType) async throws {
        switch type {
        case .internalLinkTypePublicChat(let data):
            let chat = try await TDLibManager.shared.client?.searchPublicChat(username: data.chatUsername)
            if let chatId = chat?.id {
                await openChat(chatId: chatId)
            }

        case .internalLinkTypeBotStart(let data):
            let chat = try await TDLibManager.shared.client?.searchPublicChat(username: data.botUsername)
            if let chatId = chat?.id {
                await openChat(chatId: chatId)
            }

        case .internalLinkTypeMessage(let data):
            let info = try await TDLibManager.shared.client?.getMessageLinkInfo(url: data.url)
            if let info, info.chatId != 0 {
                await openChat(
                    chatId: info.chatId,
                    messageThreadId: info.topicId?.forumTopicId
                )
            }

        case .internalLinkTypeChatInvite(let data):
            let info = try await TDLibManager.shared.client?.checkChatInviteLink(inviteLink: data.inviteLink)
            if let chatId = info?.chatId, chatId != 0 {
                await openChat(chatId: chatId)
            }

        default:
            break
        }
    }

    @MainActor
    private func openChat(chatId: Int64, messageThreadId: Int64? = nil) {
        self.navigationPath.append(ChatNavigationTarget(
            chatId: chatId,
            messageThreadId: messageThreadId
        ))
    }
    
}

struct WebLinkNotice: Identifiable {
    let id = UUID()
    let url: URL

    var host: String {
        url.host ?? url.absoluteString
    }
}

private extension URL {
    var isTelegramLink: Bool {
        guard let scheme else { return false }
        if scheme == "tg" {
            return true
        }

        guard scheme == "http" || scheme == "https",
              let host = host?.lowercased() else {
            return false
        }

        return host == "t.me"
            || host == "telegram.me"
            || host == "telegram.dog"
            || host.hasSuffix(".t.me")
    }

    var isWebLink: Bool {
        scheme == "http" || scheme == "https"
    }
}

private extension MessageTopic {
    var forumTopicId: Int64? {
        if case .messageTopicForum(let data) = self {
            return Int64(data.forumTopicId)
        }
        return nil
    }
}

// MARK: - Mock
@Observable
class HomeViewModelMock: HomeViewModel {
    override func getUserCellModel() {
        self.userCellModel = UserCellModel(avatar: .alessandro, fullname: "John Appleseed")
    }
}
