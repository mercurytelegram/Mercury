//
//  TDLibManager.swift
//  Mercury Watch App
//
//  Created by Marco Tammaro on 29/04/24.
//

import Foundation
import TDLibKit
import WatchKit

final class TDLibManager {
    
    // Singleton
    static let shared = TDLibManager()
    private var manager: TDLibClientManager
    
    // Properties
    public var client: TDLibClient?
    public var connectionState: ConnectionState?
    public var authorizationState: AuthorizationState?
    public var activeAccountId: String {
        TelegramAccountStore.activeAccountId
    }
    
    private var isClosing = false
    private var pendingAccountId: String?
    private var accountIdBeingLoggedOut: String?
    private var tdlibPath: String? {
        TelegramAccountStore.directoryPath(for: TelegramAccountStore.activeAccountId)
    }
    
    // Delegate
    private var delegatesObj = NSHashTable<AnyObject>.weakObjects()
    private var delegates: [TDLibManagerProtocol] {
        return delegatesObj.allObjects as? [TDLibManagerProtocol] ?? []
    }
    
    private init() {
        self.manager = TDLibClientManager()
        self.createClient()
    }
    
    public func subscribe(_ delegate: TDLibManagerProtocol) {
        self.delegatesObj.add(delegate)
        if let authorizationState {
            delegate.authorizationStateUpdate(state: authorizationState)
        }
        if let connectionState {
            delegate.connectionStateUpdate(state: connectionState)
        }
    }
    
    public func unsubscribe(_ delegate: TDLibManagerProtocol) {
        self.delegatesObj.remove(delegate)
    }
    
    public func close() {
        self.manager.closeClients()
    }
    
    public func createClient() {
        self.connectionState = nil
        self.authorizationState = nil
        self.client = self.manager.createClient(updateHandler: updateHandler)
    }
    
    public func addAccount() {
        let account = TelegramAccountStore.createAccount()
        switchAccount(to: account.id)
    }
    
    public func switchAccount(to accountId: String) {
        guard accountId != TelegramAccountStore.activeAccountId else { return }
        guard TelegramAccountStore.accounts.contains(where: { $0.id == accountId }) else { return }
        
        pendingAccountId = accountId
        AppState.shared.clear()
        DispatchQueue.main.async {
            AppState.shared.isAuthenticated = nil
        }
        close()
    }
    
    public func logOutActiveAccount() {
        accountIdBeingLoggedOut = TelegramAccountStore.activeAccountId
        
        Task.detached {
            do {
                _ = try await self.client?.logOut()
            } catch {
                LoggerService(TDLibManager.self).log(error, level: .error)
            }
            
            self.close()
        }
    }
    
    private func updateHandler(data: Data, client: TDLibClient) {
        guard let update = try? client.decoder.decode(Update.self, from: data) else { return }
        
        switch update {
        case .updateConnectionState(let state):
            self.updateConnectionState(state: state.state)
        case .updateAuthorizationState(let state):
            self.updateAuthorizationState(state: state.authorizationState)
        default:
            self.delegates.forEach { $0.updateHandler(update: update) }
        }
    }
    
    private func updateConnectionState(state: ConnectionState) {
        self.delegates.forEach { $0.connectionStateUpdate(state: state) }
        self.connectionState = state
    }
    
    private func updateAuthorizationState(state: AuthorizationState) {
        self.delegates.forEach { $0.authorizationStateUpdate(state: state) }
        self.authorizationState = state
        
        if state != .authorizationStateWaitTdlibParameters {
            DispatchQueue.main.async {
                AppState.shared.isAuthenticated = state == .authorizationStateReady
            }
        }
        
        switch state {
        case .authorizationStateWaitTdlibParameters:
            setTdlibParameters()
            break
        case .authorizationStateReady:
            refreshActiveAccount()
            break
        case .authorizationStateLoggingOut:
            if !isClosing { self.close() }
            break
        case .authorizationStateClosing:
            self.isClosing = true
            DispatchQueue.main.async {
                AppState.shared.isAuthenticated = nil
            }
            break
        case .authorizationStateClosed:
            let accountToRemove = accountIdBeingLoggedOut
            let accountToActivate = pendingAccountId
            accountIdBeingLoggedOut = nil
            pendingAccountId = nil
            
            if let accountToRemove {
                if let path = TelegramAccountStore.directoryPath(for: accountToRemove) {
                    try? FileManager.default.removeItem(atPath: path)
                }
                _ = TelegramAccountStore.removeAccount(id: accountToRemove)
            } else if let accountToActivate {
                TelegramAccountStore.setActiveAccount(id: accountToActivate)
            }
            
            TDLibManager.shared.createClient()
            DispatchQueue.main.async {
                self.isClosing = false
            }
            break
        default:
            break
        }
    }
    
    private func setTdlibParameters() {
        
        let logger = LoggerService(TDLibManager.self)
        
        Task {
            do {
                let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
                let device = WKInterfaceDevice.current()
                let deviceModel = device.name
                let systemVersion = "\(device.systemName) \(device.systemVersion)"
                
                let result = try await self.client?.setTdlibParameters(
                    apiHash: SecretService.apiHash,
                    apiId: SecretService.apiId,
                    applicationVersion: appVersion,
                    databaseDirectory: tdlibPath,
                    databaseEncryptionKey: nil,
                    deviceModel: deviceModel,
                    filesDirectory: nil,
                    systemLanguageCode: "en-US",
                    systemVersion: systemVersion,
                    useChatInfoDatabase: true,
                    useFileDatabase: true,
                    useMessageDatabase: false,
                    useSecretChats: false,
                    useTestDc: false
                )
                
                #if DEBUG
                try await self.client?.setLogVerbosityLevel(newVerbosityLevel: 1)
                #else
                try await self.client?.setLogVerbosityLevel(newVerbosityLevel: 0)
                #endif
                
                let options = [
                    "disable_network_statistics",
                    "disable_persistent_network_statistics",
                    "use_storage_optimizer"
                ]
                
                for option in options {
                    try await self.client?.setOption(
                        name: option,
                        value: .optionValueBoolean(.init(value: true))
                    )
                }
                
                logger.log(result)
        
            } catch {
                logger.log(error, level: .error)
            }
        }
    }
    
    private func refreshActiveAccount() {
        Task {
            do {
                guard let user = try await self.client?.getMe() else { return }
                TelegramAccountStore.updateActiveAccount(with: user)
            } catch {
                LoggerService(TDLibManager.self).log(error, level: .error)
            }
        }
    }
    
}
