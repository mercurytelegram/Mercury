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
    var infoRows: [ProfileInfoRow] = []
    var members: [ProfileMemberModel] = []
    var isLoadingMembers: Bool = false
    var isSavedMessages: Bool = false
    var canJoinChat: Bool = false
    var isJoiningChat: Bool = false
    var canMessageUser: Bool { return userIdToMessage != nil }
    var isBlockEnabled: Bool { return idToBlock != nil }
    
    private var userIdToMessage: Int64? = nil
    private var idToBlock: Int64? = nil
    private var chatIdToJoin: Int64? = nil
    
    init(type: ProfileDetailPageType) {
        super.init()
        Task.detached { [weak self] in
            try await self?.fetchData(type)
        }
    }
    
    fileprivate func fetchData(_ type: ProfileDetailPageType) async throws {
        
        switch type {
        case .savedMessages:
            self.title = "Saved Messages"
            self.subtitle = "Your personal cloud storage"
            self.avatarModel = .savedMessages(isFullScreen: true)
            self.infoRows = [
                ProfileInfoRow(title: "About", value: "Save messages, media, and files for quick access across devices."),
                ProfileInfoRow(title: "Access", value: "Only you can see this chat.")
            ].compactMap { $0 }
            self.isSavedMessages = true
            self.members = []
            self.userIdToMessage = nil
            self.idToBlock = nil
            self.chatIdToJoin = nil
            self.canJoinChat = false
            
        case .user(let id):
            let user = try await TDLibManager.shared.client?.getUser(userId: id)
            let fullInfo = try? await TDLibManager.shared.client?.getUserFullInfo(userId: id)
            self.title = user?.firstName
            self.subtitle = user?.statusDescription
            self.avatarModel = user?.toAvatarModel(isFullScreen: true)
            self.infoRows = [
                ProfileInfoRow(title: "Username", value: user?.mainUserName),
                ProfileInfoRow(title: "Phone", value: user?.formattedPhoneNumber),
                ProfileInfoRow(title: "Bio", value: fullInfo?.bio?.text)
            ].compactMap { $0 }
            self.isSavedMessages = false
            self.members = []
            self.userIdToMessage = id
            self.idToBlock = id
            self.chatIdToJoin = nil
            self.canJoinChat = false
            
        case .basicGroup(let groupId, let chatId):
            let group = try await TDLibManager.shared.client?.getBasicGroup(basicGroupId: groupId)
            let fullInfo = try? await TDLibManager.shared.client?.getBasicGroupFullInfo(basicGroupId: groupId)
            let chat = try await TDLibManager.shared.client?.getChat(chatId: chatId)
            self.title = chat?.title
            self.subtitle = "\(group?.memberCount ?? 0) members"
            self.avatarModel = chat?.toAvatarModel(isFullScreen: true)
            self.infoRows = [
                ProfileInfoRow(title: "Members", value: group?.memberCount.description),
                ProfileInfoRow(title: "Description", value: fullInfo?.description)
            ].compactMap { $0 }
            self.isSavedMessages = false
            self.userIdToMessage = nil
            self.idToBlock = nil
            self.chatIdToJoin = nil
            self.canJoinChat = false
            await self.loadMembers(fullInfo?.members ?? [])
            
        case .superGroup(groupId: let groupId, chatId: let chatId):
            let group = try await TDLibManager.shared.client?.getSupergroup(supergroupId: groupId)
            let fullInfo = try? await TDLibManager.shared.client?.getSupergroupFullInfo(supergroupId: groupId)
            let chat = try await TDLibManager.shared.client?.getChat(chatId: chatId)
            self.title = chat?.title
            self.subtitle = "\(group?.memberCount ?? 0) members"
            self.avatarModel = chat?.toAvatarModel(isFullScreen: true)
            self.infoRows = [
                ProfileInfoRow(title: "Username", value: group?.mainUserName),
                ProfileInfoRow(title: "Members", value: group?.memberCount.description),
                ProfileInfoRow(title: "Description", value: fullInfo?.description)
            ].compactMap { $0 }
            self.isSavedMessages = false
            self.userIdToMessage = nil
            self.idToBlock = nil
            self.chatIdToJoin = chatId
            if case .chatMemberStatusLeft = group?.status {
                self.canJoinChat = true
            } else {
                self.canJoinChat = false
            }
            if fullInfo?.canGetMembers == true {
                let members = try? await TDLibManager.shared.client?.getSupergroupMembers(
                    filter: nil,
                    limit: 50,
                    offset: 0,
                    supergroupId: groupId
                )
                await self.loadMembers(members?.members ?? [])
            } else {
                self.members = []
            }
        }
    }
    
    private func loadMembers(_ chatMembers: [ChatMember]) async {
        self.isLoadingMembers = true
        
        let models = await withTaskGroup(of: ProfileMemberModel?.self) { group in
            for member in chatMembers {
                group.addTask {
                    guard case .messageSenderUser(let sender) = member.memberId,
                          let user = try? await TDLibManager.shared.client?.getUser(userId: sender.userId)
                    else { return nil }
                    
                    return ProfileMemberModel(
                        user: user,
                        role: member.status.profileDescription
                    )
                }
            }
            
            var results: [ProfileMemberModel] = []
            for await model in group {
                if let model { results.append(model) }
            }
            return results.sorted { $0.title < $1.title }
        }
        
        self.members = models
        self.isLoadingMembers = false
    }
    
    public func openChatToUser() async -> Int64? {
        guard let userId = userIdToMessage else { return nil }
        
        do {
            let chat = try await TDLibManager.shared.client?.createPrivateChat(
                force: false,
                userId: userId
            )
            return chat?.id
        } catch {
            self.logger.log(error, level: .error)
            return nil
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
    
    public func joinChat() {
        guard let chatId = chatIdToJoin, !isJoiningChat else { return }
        isJoiningChat = true
        Task.detached {
            do {
                try await TDLibManager.shared.client?.joinChat(chatId: chatId)
                await MainActor.run {
                    self.canJoinChat = false
                    self.isJoiningChat = false
                }
            } catch {
                self.logger.log(error, level: .error)
                await MainActor.run {
                    self.isJoiningChat = false
                }
            }
        }
    }
    
}

struct ProfileInfoRow: Identifiable {
    let title: String
    let value: String
    
    var id: String {
        return title
    }
    
    init?(title: String, value: String?) {
        guard let value, !value.isEmpty else { return nil }
        self.title = title
        self.value = value
    }
}

struct ProfileMemberModel: Identifiable {
    let id: Int64
    let title: String
    let subtitle: String?
    let avatarModel: AvatarModel
    
    init(user: User, role: String?) {
        self.id = user.id
        self.title = user.fullName.trimmingCharacters(in: .whitespaces)
        self.subtitle = role ?? user.mainUserName ?? user.statusDescription
        self.avatarModel = user.toAvatarModel()
    }
    
    init(id: Int64, title: String, subtitle: String?, avatarModel: AvatarModel) {
        self.id = id
        self.title = title
        self.subtitle = subtitle
        self.avatarModel = avatarModel
    }
}

private extension ChatMemberStatus {
    var profileDescription: String? {
        switch self {
        case .chatMemberStatusCreator:
            return "Owner"
        case .chatMemberStatusAdministrator:
            return "Admin"
        case .chatMemberStatusRestricted:
            return "Restricted"
        default:
            return nil
        }
    }
}

class ProfileDetailViewModelMock: ProfileDetailViewModel {
    init() {
        super.init(type: .user(userId: 0))
        self.title = "Huston"
        self.subtitle = "42 members"
        self.avatarModel = .huston(isFullScreen: true)
        self.infoRows = [
            ProfileInfoRow(title: "Username", value: "@huston"),
            ProfileInfoRow(title: "Bio", value: "Ground control")
        ].compactMap { $0 }
        self.members = [
            ProfileMemberModel(
                id: 1,
                title: "Marco Tammaro",
                subtitle: "Admin",
                avatarModel: .marco
            )
        ]
    }
    
    override var isBlockEnabled: Bool { return true }
    
    override func fetchData(_ type: ProfileDetailPageType) async throws { }
}
