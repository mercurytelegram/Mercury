//
//  SettingsViewModel.swift
//  Mercury
//
//  Created by Marco Tammaro on 08/02/26.
//

import SwiftUI
import TDLibKit

@Observable
class ProfileDetailViewModel: TDLibViewModel {
    
    var title: String?
    var subtitle: String?
    var avatarModel: AvatarModel?
    var isBlockEnabled: Bool { return idToBlock != nil }
    private var idToBlock: Int64? = nil
    
    init(type: ProfileDetailPageType) {
        super.init()
        Task.detached { [weak self] in
            try await self?.fetchData(type)
        }
    }
    
    fileprivate func fetchData(_ type: ProfileDetailPageType) async throws {
        
        switch type {
        case .user(let id):
            let user = try await TDLibManager.shared.client?.getUser(userId: id)
            self.title = user?.firstName
            self.subtitle = user?.statusDescription
            self.avatarModel = user?.toAvatarModel(isFullScreen: true)
            self.idToBlock = id
            
        case .basicGroup(let groupId, let chatId):
            let group = try await TDLibManager.shared.client?.getBasicGroup(basicGroupId: groupId)
            let chat = try await TDLibManager.shared.client?.getChat(chatId: chatId)
            self.title = chat?.title
            self.subtitle = "\(group?.memberCount ?? 0) members"
            self.avatarModel = chat?.toAvatarModel(isFullScreen: true)
            
        case .superGroup(groupId: let groupId, chatId: let chatId):
            let group = try await TDLibManager.shared.client?.getSupergroup(supergroupId: groupId)
            let chat = try await TDLibManager.shared.client?.getChat(chatId: chatId)
            self.title = chat?.title
            self.subtitle = "\(group?.memberCount ?? 0) members"
            self.avatarModel = chat?.toAvatarModel(isFullScreen: true)
        }
    }
    
    public func onBlockUserTap() {
        guard let id = idToBlock else { return }
        Task.detached {
            try await TDLibManager.shared.client?.setMessageSenderBlockList(
                blockList: .blockListMain,
                senderId: .messageSenderUser(.init(userId: id))
            )
        }
    }
    
}

class ProfileDetailViewModelMock: ProfileDetailViewModel {
    init() {
        super.init(type: .user(userId: 0))
        self.title = "Huston"
        self.subtitle = "42 members"
        self.avatarModel = .huston(isFullScreen: true)
    }
    
    override var isBlockEnabled: Bool { return true }
    
    override func fetchData(_ type: ProfileDetailPageType) async throws { }
}
