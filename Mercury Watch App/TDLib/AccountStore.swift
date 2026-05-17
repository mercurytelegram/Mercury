//
//  AccountStore.swift
//  Mercury Watch App
//
//  Created by Codex on 29/04/26.
//

import Foundation
import TDLibKit

struct TelegramAccount: Codable, Identifiable, Hashable {
    let id: String
    var telegramUserId: Int64?
    var fullName: String?
    var username: String?
    var phoneNumber: String?
    
    var title: String {
        if let fullName, !fullName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return fullName
        }
        if let username, !username.isEmpty {
            return username
        }
        return "Telegram Account"
    }
    
    var subtitle: String {
        if let username, !username.isEmpty {
            return username
        }
        if let phoneNumber, !phoneNumber.isEmpty {
            return phoneNumber
        }
        return id == Self.primaryId ? "Primary account" : "Not signed in"
    }
    
    static let primaryId = "primary"
    
    static var primary: TelegramAccount {
        TelegramAccount(id: primaryId)
    }
}

enum TelegramAccountStore {
    private static let accountsKey = "telegramAccounts"
    private static let activeAccountIdKey = "activeTelegramAccountId"
    
    static var accounts: [TelegramAccount] {
        let decodedAccounts: [TelegramAccount]
        if let data = UserDefaults.standard.data(forKey: accountsKey),
           let accounts = try? JSONDecoder().decode([TelegramAccount].self, from: data),
           !accounts.isEmpty {
            decodedAccounts = accounts
        } else {
            decodedAccounts = [.primary]
        }
        
        var accounts = decodedAccounts
        var didChange = false
        if !accounts.contains(where: { $0.id == TelegramAccount.primaryId }) {
            accounts.insert(.primary, at: 0)
            didChange = true
        }
        
        if !accounts.contains(where: { $0.id == activeAccountId }) {
            activeAccountId = accounts.first?.id ?? TelegramAccount.primaryId
            didChange = true
        }
        
        if didChange {
            save(accounts)
        }
        return accounts
    }
    
    static var activeAccountId: String {
        get {
            UserDefaults.standard.string(forKey: activeAccountIdKey) ?? TelegramAccount.primaryId
        }
        set {
            UserDefaults.standard.set(newValue, forKey: activeAccountIdKey)
        }
    }
    
    static var activeAccount: TelegramAccount {
        accounts.first { $0.id == activeAccountId } ?? .primary
    }
    
    static func createAccount() -> TelegramAccount {
        var accounts = accounts
        let account = TelegramAccount(id: UUID().uuidString)
        accounts.append(account)
        save(accounts)
        return account
    }
    
    static func setActiveAccount(id: String) {
        guard accounts.contains(where: { $0.id == id }) else { return }
        activeAccountId = id
    }
    
    static func updateActiveAccount(with user: User) {
        updateAccount(id: activeAccountId, with: user)
    }
    
    static func updateAccount(id: String, with user: User) {
        var accounts = accounts
        if let index = accounts.firstIndex(where: { $0.id == id }) {
            accounts[index].telegramUserId = user.id
            accounts[index].fullName = user.fullName.trimmingCharacters(in: .whitespacesAndNewlines)
            accounts[index].username = user.mainUserName
            accounts[index].phoneNumber = user.formattedPhoneNumber
        } else {
            accounts.append(
                TelegramAccount(
                    id: id,
                    telegramUserId: user.id,
                    fullName: user.fullName.trimmingCharacters(in: .whitespacesAndNewlines),
                    username: user.mainUserName,
                    phoneNumber: user.formattedPhoneNumber
                )
            )
        }
        save(accounts)
    }
    
    static func removeAccount(id: String) -> TelegramAccount? {
        var accounts = accounts
        guard let index = accounts.firstIndex(where: { $0.id == id }) else {
            return accounts.first
        }
        
        accounts.remove(at: index)
        if accounts.isEmpty {
            accounts = [.primary]
        }
        
        let nextAccount = accounts.first
        save(accounts)
        activeAccountId = nextAccount?.id ?? TelegramAccount.primaryId
        return nextAccount
    }
    
    static func directoryPath(for accountId: String) -> String? {
        guard let cachesDirectory = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first
        else { return nil }
        
        if accountId == TelegramAccount.primaryId {
            return cachesDirectory.appendingPathComponent("tdlib", isDirectory: true).path
        }
        
        return cachesDirectory
            .appendingPathComponent("tdlib-accounts", isDirectory: true)
            .appendingPathComponent(accountId, isDirectory: true)
            .path
    }
    
    private static func save(_ accounts: [TelegramAccount]) {
        guard let data = try? JSONEncoder().encode(accounts) else { return }
        UserDefaults.standard.set(data, forKey: accountsKey)
    }
}
