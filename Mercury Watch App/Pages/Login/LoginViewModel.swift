//
//  LoginViewModel.swift
//  Mercury Watch App
//
//  Created by Marco Tammaro on 02/11/24.
//

import Foundation
import SwiftUI
import TDLibKit

@Observable
class LoginViewModel: TDLibViewModel {
    var showTutorialView: Bool = false
    var showPasswordView: Bool = false
    var showFullscreenQR: Bool = false
    var isValidatingPassword: Bool = false
    
    var passwordModel: PasswordModel = .plain
    var password: String = ""
    var qrCodeLink: String? = nil
    var statusMessage: String = "Connecting..."
    
    let tutorialSteps = [
        "Open Telegram on your phone",
        "Go to Settings → Devices → Link Desktop Device",
        "Point your phone at the QR code to confirm login"
    ]
    
    func didPressDemoButton() {
        AppState.shared.isMock = true
    }
    
    func didPressInfoButton() {
        showTutorialView = true
    }
    
    func didPressQR() {
        withAnimation(.bouncy) {
            showFullscreenQR.toggle()
        }
    }
    
    func didChangeShowPasswordValue(oldValue: Bool, newValue: Bool) {
        if newValue == false {
            LoginViewModel.logout()
        }
    }
    
    // MARK: - TDLib
    override func updateHandler(update: Update) {
        super.updateHandler(update: update)
        switch update {
        case .updateAuthorizationState(let state):
            self.manageUpdateAuthorizationState(state: state.authorizationState)
        case .updateChatFolders(let update):
            DispatchQueue.main.async {
                self.updateChatFolders(update)
            }
        default:
            break
        }
    }
    
    override func connectionStateUpdate(state: ConnectionState) {
        guard state == .connectionStateReady else { return }
        DispatchQueue.main.async {
            self.statusMessage = "Login with QR code"
        }
    }
    
    func manageUpdateAuthorizationState(state: AuthorizationState) {
        
        switch state {
        case .authorizationStateWaitPhoneNumber:
            self.getQrcodeLink()
            break
        case .authorizationStateWaitOtherDeviceConfirmation(let info):
            DispatchQueue.main.async {
                self.qrCodeLink = info.link
            }
            break
        case .authorizationStateWaitPassword(_):
            DispatchQueue.main.async {
                self.qrCodeLink = nil
                self.showPasswordView = true
            }
            break
        default:
            self.logger.log("Unmanaged state \(state)")
            break
        }
    }
    
    func getQrcodeLink() {
        Task {
            do {
                let result = try await TDLibManager.shared.client?.requestQrCodeAuthentication(otherUserIds: [])
                self.logger.log(result)
                
            } catch {
                self.logger.log(error, level: .error)
            }
        }
    }
    
    func validatePassword() {
        
        isValidatingPassword = true
        passwordModel = .plain
        
        Task {
            do {
                let result = try await TDLibManager.shared.client?.checkAuthenticationPassword(password: password)
                self.logger.log(result)
                
                await MainActor.run {
                    passwordModel = .plain
                }
                
            } catch {
                self.logger.log(error, level: .error)
                guard let error = error as? TDLibKit.Error else { return }
                
                if error.message == "PASSWORD_HASH_INVALID" {
                    await MainActor.run {
                        self.password = ""
                        passwordModel = .error
                    }
                }
            }
            
            await MainActor.run {
                self.isValidatingPassword = false
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
    
    static func logout() {
        
        let logger = LoggerService(LoginViewModel.self)
        
        if AppState.shared.isMock {
            AppState.shared.isMock = false
            return
        }
        
        AppState.shared.clear()
        
        Task.detached {
            do {
                let result = try await TDLibManager.shared.client?.logOut()
                logger.log(result)
            } catch {
                logger.log(error, level: .error)
            }
            
            TDLibManager.shared.close()
        }
    }
    
    static func setOnlineStatus(online: Bool = true) {
        Task {
            let logger = LoggerService(LoginViewModel.self)
            do {
                let result = try await TDLibManager.shared.client?.setOption(
                    name: "online",
                    value: .optionValueBoolean(.init(value: online))
                )
                logger.log(result)
            } catch {
                logger.log(error, level: .error)
            }
        }
    }
    
    static func setOfflineStatus() {
        setOnlineStatus(online: false)
    }
    
}

// MARK: - Mock
@Observable
class LoginViewModelMock: LoginViewModel {
    override init() {
        super.init()
        qrCodeLink = "Hello World"
    }
    
}
