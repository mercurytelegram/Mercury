//
//  LoginViewModel.swift
//  Mercury Watch App
//
//  Created by Marco Tammaro on 02/11/24.
//

import Foundation
import SwiftUI
import TDLibKit
import WatchKit

@Observable
class SettingsViewModel: TDLibViewModel {
    
    var user: UserModel?
    var telegramSessionStatus: String = "Unknown"
    var quickReplyTemplates: [String] = QuickReplyTemplatesStore.templates
    
    var appVersion: String {
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "Unknown"
        let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String
        
        if let build, build != version {
            return "\(version) (\(build))"
        }
        return version
    }
    
    override init() {
        super.init()
        updateSessionStatus(TDLibManager.shared.connectionState)
        getUser()
    }
    
    override func connectionStateUpdate(state: ConnectionState) {
        DispatchQueue.main.async {
            self.updateSessionStatus(state)
        }
    }
    
    func logout() {
        LoginViewModel.logout()
    }
    
    func editQuickReply(at index: Int) {
        guard quickReplyTemplates.indices.contains(index) else { return }
        let currentValue = quickReplyTemplates[index]
        
        WKExtension.shared()
            .visibleInterfaceController?
            .presentTextInputController(
                withSuggestions: [currentValue],
                allowedInputMode: .plain
            ) { result in
                guard let result = result as? [String],
                      let text = result.first
                else { return }
                
                DispatchQueue.main.async {
                    QuickReplyTemplatesStore.updateTemplate(at: index, value: text)
                    self.quickReplyTemplates = QuickReplyTemplatesStore.templates
                }
            }
    }
    
    func resetQuickReplies() {
        QuickReplyTemplatesStore.reset()
        quickReplyTemplates = QuickReplyTemplatesStore.templates
    }
    
    private func updateSessionStatus(_ state: ConnectionState?) {
        telegramSessionStatus = switch state {
        case .connectionStateReady:
            "Connected"
        case .connectionStateUpdating:
            "Updating"
        case .connectionStateConnecting:
            "Connecting"
        case .connectionStateConnectingToProxy:
            "Connecting to proxy"
        case .connectionStateWaitingForNetwork:
            "Waiting for network"
        case nil:
            "Unknown"
        }
    }
    
    fileprivate func getUser() {
        
        Task.detached(priority: .userInitiated) {
            
            do {
                guard let user = try await TDLibManager.shared.client?.getMe()
                else { return }
                
                await MainActor.run {
                    withAnimation {
                        self.user = user.toUserModel()
                    }
                }
                
            } catch {
                self.logger.log(error, level: .error)
            }
        }
    }
}

struct UserModel {
    let thumbnail: UIImage?
    let avatar: AvatarModel
    let fullName: String
    let mainUserName: String
    let phoneNumber: String
}

enum QuickReplyTemplatesStore {
    static let defaultTemplates = ["OK", "Now", "I'll reply later", "Thanks"]
    
    private static let key = "quickReplyTemplates"
    
    static var templates: [String] {
        let storedTemplates = UserDefaults.standard.stringArray(forKey: key) ?? []
        let normalizedTemplates = storedTemplates
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
        
        if normalizedTemplates.isEmpty {
            return defaultTemplates
        }
        
        return Array((normalizedTemplates + defaultTemplates).prefix(defaultTemplates.count))
    }
    
    static func updateTemplate(at index: Int, value: String) {
        guard defaultTemplates.indices.contains(index) else { return }
        
        let trimmedValue = value.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedValue.isEmpty else { return }
        
        var newTemplates = templates
        newTemplates[index] = trimmedValue
        UserDefaults.standard.set(newTemplates, forKey: key)
    }
    
    static func reset() {
        UserDefaults.standard.removeObject(forKey: key)
    }
}

struct StorageChatUsageModel: Identifiable, Hashable {
    let id: Int64
    let title: String
    let size: Int64
    let fileCount: Int
    let fileTypes: [StorageFileTypeUsageModel]
    
    var formattedSize: String {
        ByteCountFormatter.string(fromByteCount: size, countStyle: .file)
    }
}

struct StorageFileTypeUsageModel: Identifiable, Hashable {
    let id: String
    let title: String
    let size: Int64
    let fileCount: Int
    
    var formattedSize: String {
        ByteCountFormatter.string(fromByteCount: size, countStyle: .file)
    }
}

@Observable
class StorageUsageViewModel: TDLibViewModel {
    var chats: [StorageChatUsageModel] = []
    var totalBytes: Int64 = 0
    var fileCount: Int = 0
    var isLoading = false
    var isClearingAll = false
    var clearingChatId: Int64?
    var statusMessage: String?
    var cleaningTitle: String?
    
    var totalSize: String {
        ByteCountFormatter.string(fromByteCount: totalBytes, countStyle: .file)
    }
    
    var isClearing: Bool {
        isClearingAll || clearingChatId != nil
    }
    
    func load(clearStatus: Bool = true) async {
        guard !isLoading else { return }
        
        await MainActor.run {
            self.isLoading = true
            if clearStatus {
                self.statusMessage = nil
            }
        }
        
        do {
            guard let statistics = try await TDLibManager.shared.client?.getStorageStatistics(chatLimit: 30)
            else {
                await MainActor.run {
                    self.isLoading = false
                    self.statusMessage = "Storage is unavailable"
                }
                return
            }
            
            let chatModels = await self.makeChatUsageModels(from: statistics.byChat)
            
            await MainActor.run {
                self.totalBytes = chatModels.reduce(0) { $0 + $1.size }
                self.fileCount = chatModels.reduce(0) { $0 + $1.fileCount }
                self.chats = chatModels
                self.isLoading = false
            }
        } catch {
            await MainActor.run {
                self.isLoading = false
                self.statusMessage = "Couldn't load storage usage"
            }
            self.logger.log(error, level: .error)
        }
    }
    
    func clearAllCache() {
        guard !isClearing else { return }
        
        isClearingAll = true
        cleaningTitle = "Clearing media cache"
        statusMessage = nil
        
        Task.detached(priority: .userInitiated) {
            await self.optimizeStorageWithMinimumDuration(chatIds: nil)
            
            await MainActor.run {
                self.isClearingAll = false
                self.cleaningTitle = nil
                self.statusMessage = "Cache cleared"
            }
            
            await self.loadAfterClearing()
        }
    }
    
    func clearCache(for chat: StorageChatUsageModel) {
        guard !isClearing else { return }
        
        clearingChatId = chat.id
        cleaningTitle = "Clearing \(chat.title)"
        statusMessage = nil
        
        Task.detached(priority: .userInitiated) {
            await self.optimizeStorageWithMinimumDuration(chatIds: [chat.id])
            
            await MainActor.run {
                self.clearingChatId = nil
                self.cleaningTitle = nil
                self.statusMessage = "\(chat.title) cache cleared"
            }
            
            await self.loadAfterClearing()
        }
    }
    
    private func loadAfterClearing() async {
        await MainActor.run {
            self.isLoading = false
        }
        await load(clearStatus: false)
    }
    
    private func optimizeStorageWithMinimumDuration(chatIds: [Int64]?) async {
        let startDate = Date()
        await optimizeStorage(chatIds: chatIds)
        
        let elapsed = Date().timeIntervalSince(startDate)
        let minimumDuration: TimeInterval = 1.2
        guard elapsed < minimumDuration else { return }
        
        let remainingNanoseconds = UInt64((minimumDuration - elapsed) * 1_000_000_000)
        try? await Task.sleep(nanoseconds: remainingNanoseconds)
    }
    
    private func optimizeStorage(chatIds: [Int64]?) async {
        do {
            _ = try await TDLibManager.shared.client?.optimizeStorage(
                chatIds: chatIds,
                chatLimit: 30,
                count: 0,
                excludeChatIds: nil,
                fileTypes: Self.clearableFileTypes,
                immunityDelay: 0,
                returnDeletedFileStatistics: true,
                size: 0,
                ttl: 0
            )
        } catch {
            await MainActor.run {
                self.statusMessage = "Couldn't clear cache"
            }
            self.logger.log(error, level: .error)
        }
    }
    
    private func makeChatUsageModels(from statistics: [StorageStatisticsByChat]) async -> [StorageChatUsageModel] {
        await withTaskGroup(of: StorageChatUsageModel?.self) { group in
            for chatStatistics in statistics {
                group.addTask {
                    let title = await self.chatTitle(for: chatStatistics.chatId)
                    let fileTypes = chatStatistics.byFileType
                        .filter { $0.size > 0 && Self.isClearableFileType($0.fileType) }
                        .map {
                            StorageFileTypeUsageModel(
                                id: Self.fileTypeTitle($0.fileType),
                                title: Self.fileTypeTitle($0.fileType),
                                size: $0.size,
                                fileCount: $0.count
                            )
                        }
                        .sorted { $0.size > $1.size }
                    
                    let clearableSize = fileTypes.reduce(Int64(0)) { $0 + $1.size }
                    let clearableCount = fileTypes.reduce(0) { $0 + $1.fileCount }
                    guard clearableSize > 0 else { return nil }
                    
                    return StorageChatUsageModel(
                        id: chatStatistics.chatId,
                        title: title,
                        size: clearableSize,
                        fileCount: clearableCount,
                        fileTypes: fileTypes
                    )
                }
            }
            
            var models: [StorageChatUsageModel] = []
            for await model in group {
                if let model {
                    models.append(model)
                }
            }
            return models.sorted { $0.size > $1.size }
        }
    }
    
    private func chatTitle(for chatId: Int64) async -> String {
        guard chatId != 0 else { return "Other Files" }
        guard let chat = try? await TDLibManager.shared.client?.getChat(chatId: chatId) else {
            return "Chat \(chatId)"
        }
        return chat.title
    }
    
    private static let clearableFileTypes: [FileType] = [
        .fileTypeAnimation,
        .fileTypeAudio,
        .fileTypeDocument,
        .fileTypePhoto,
        .fileTypeVideo,
        .fileTypeVideoNote,
        .fileTypeVoiceNote
    ]
    
    private static func isClearableFileType(_ fileType: FileType) -> Bool {
        clearableFileTypes.contains(fileType)
    }
    
    private static func fileTypeTitle(_ fileType: FileType) -> String {
        switch fileType {
        case .fileTypeAnimation:
            "Animations"
        case .fileTypeAudio:
            "Audio"
        case .fileTypeDocument:
            "Documents"
        case .fileTypePhoto, .fileTypePhotoStory:
            "Photos"
        case .fileTypeSticker:
            "Stickers"
        case .fileTypeVideo, .fileTypeVideoStory:
            "Videos"
        case .fileTypeVideoNote:
            "Video Messages"
        case .fileTypeVoiceNote:
            "Voice Messages"
        case .fileTypeThumbnail:
            "Thumbnails"
        case .fileTypeProfilePhoto:
            "Profile Photos"
        case .fileTypeWallpaper:
            "Wallpapers"
        default:
            "Other"
        }
    }
}

// MARK: - Mock
@Observable
class SettingsViewModelMock: SettingsViewModel {
    override func getUser() {
        self.user = .init(
            thumbnail: UIImage(named: "alessandro"),
            avatar: .alessandro,
            fullName: "John Appleseed",
            mainUserName: "@johnappleseed",
            phoneNumber: "+39 0000000000"
        )
    }
}
