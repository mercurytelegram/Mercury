//
//  LoginViewModel.swift
//  Mercury Watch App
//
//  Created by Marco Tammaro on 02/11/24.
//

import Foundation
import SwiftUI
import TDLibKit

enum LoginViewModelState {
    case qrCodeLogin
    case tutorial
    
    case phoneNumberLogin
    case phoneNumberLoginFailure
    
    case authCode
    case authCodeFailure
    
    case twoFactorPassword
    case twoFactorPasswordFailure
}

@Observable
class LoginViewModel: TDLibViewModel {
    
    var state: LoginViewModelState? = nil {
        didSet {
            self.onStateChange(oldValue: oldValue, newValue: state)
        }
    }
    
    var isLoading: Bool = true
    var showFullscreenQR: Bool = false
    var qrCodeLink: String? = nil
    var lastInputCta: String? = nil
    
    let tutorialSteps = [
        "Open Telegram on your phone",
        "Go to Settings → Devices → Link Desktop Device",
        "Point your phone at the QR code to confirm login"
    ]
    
    func onStateChange(oldValue: LoginViewModelState?, newValue: LoginViewModelState?) {
        
        self.isLoading = false
        
        switch (oldValue, newValue) {
            
        case (.tutorial, .qrCodeLogin), // Tutorial dismissed, request new qrcode
             (.twoFactorPassword, .qrCodeLogin), // Password dismissed, request new qrcode
             (.twoFactorPasswordFailure, .qrCodeLogin): // Password failure dismissed, request new qrcode
            // After logout authorizationStateWaitPhoneNumber update will be
            // triggered and new qrcode will be requested
            self.logout()
            self.lastInputCta = nil
            break
        
        case (.qrCodeLogin, .twoFactorPassword): // Qrcode used, not valid anymore
            self.qrCodeLink = nil
            break
            
        case (.tutorial, .phoneNumberLogin): // Request authorization via phone number
            // Doing logout to invalide current authentication flow and start a new one
            // After logout authorizationStateWaitPhoneNumber update will be triggered
            self.logout()
            break
        
        default:
            break
        }
        
    }
    
    func didPressQR() {
        withAnimation(.bouncy) {
            showFullscreenQR.toggle()
        }
    }
    
    func didPressInfoButton() {
        self.state = .tutorial
    }
    
    func didPressLoginButton() {
        self.state = .phoneNumberLogin
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
    
    func manageUpdateAuthorizationState(state: AuthorizationState) {
        
        self.logger.log(state, level: .debug)
        
        switch state {
            
        case .authorizationStateWaitPhoneNumber: // Triggered at app start and after each logout
            if self.state != .phoneNumberLogin {
                withAnimation {
                    self.isLoading = true
                }
                self.getQrcodeLink()
            }
            
        case .authorizationStateWaitOtherDeviceConfirmation(let info): // Requested qrcode login, link available
            Task { @MainActor in
                withAnimation {
                    self.state = .qrCodeLogin
                }
                self.qrCodeLink = info.link
            }
         
        case .authorizationStateWaitPassword(_):
            Task { @MainActor in
                withAnimation {
                    self.state = .twoFactorPassword
                }
            }
        
        case .authorizationStateWaitCode(_):
            Task { @MainActor in
                withAnimation {
                    self.state = .authCode
                }
            }
            
        default:
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
    
    func setPhoneNumber(_ phoneNumber: String) {
        
        // Demo
        if phoneNumber == "999" {
            LoginViewModel.logout()
            AppState.shared.isMock = true
            return
        }
        
        self.isLoading = true
        self.lastInputCta = phoneNumber
        
        Task {
            do {
                let result = try await TDLibManager.shared.client?.setAuthenticationPhoneNumber(
                    phoneNumber: phoneNumber,
                    settings: nil
                )
                
                self.logger.log(result)
                
            } catch {
                self.logger.log(error, level: .error)
                guard let error = error as? TDLibKit.Error else { return }
                if error.message == "PHONE_NUMBER_INVALID" {
                    await MainActor.run {
                        self.state = .phoneNumberLoginFailure
                    }
                }
            }
        }
    }
    
    func validatePassword(_ password: String) {
        
        self.isLoading = true
        
        Task {
            do {
                let result = try await TDLibManager.shared.client?.checkAuthenticationPassword(password: password)
                self.logger.log(result)
                
                // Authenticated.. login will be dismissed by app
                
            } catch {
                self.logger.log(error, level: .error)
                guard let error = error as? TDLibKit.Error else { return }
                if error.message == "PASSWORD_HASH_INVALID" {
                    await MainActor.run {
                        self.state = .twoFactorPasswordFailure
                    }
                }
            }
        }
    }
    
    func validateAuthCode(_ code: String) {
        
        self.isLoading = true
        self.lastInputCta = code
        
        Task {
            do {
                let result = try await TDLibManager.shared.client?.checkAuthenticationCode(code: code)
                self.logger.log(result)
                
                // Authenticated (login will be dismissed by app) or password required
                
            } catch {
                self.logger.log(error, level: .error)
                guard let error = error as? TDLibKit.Error else { return }
                if error.message == "PHONE_CODE_INVALID" {
                    await MainActor.run {
                        self.state = .authCodeFailure
                    }
                }
                
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
    
    func logout() {
        Task.detached {
            do {
                let result = try await TDLibManager.shared.client?.logOut()
                self.logger.log(result)
            } catch {
                self.logger.log(error, level: .error)
            }
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
    
    // MARK: Sheets Binding
    
    var showTutorial: Binding<Bool> {
        .init(
            get: { [weak self] in
                guard let self else { return false }
                return self.state == .tutorial
            },
            set: { [weak self] in
                guard let self else { return }
                self.state = $0 ? .tutorial : .qrCodeLogin
            }
        )
    }
    
    var showPassword: Binding<Bool> {
        .init(
            get: { [weak self] in
                guard let self else { return false }
                return self.state == .twoFactorPassword || self.state == .twoFactorPasswordFailure
            },
            set: { [weak self] in
                guard let self else { return }
                if !$0 { self.state = .qrCodeLogin }
            }
        )
    }
    
    var showPhoneNumber: Binding<Bool> {
        .init(
            get: { [weak self] in
                guard let self else { return false }
                return self.state == .phoneNumberLogin || self.state == .phoneNumberLoginFailure
            },
            set: { [weak self] in
                guard let self else { return }
                if !$0 { self.state = .tutorial }
            }
       )
    }
    
    var showCode: Binding<Bool> {
        .init(
            get: { [weak self] in
                guard let self else { return false }
                return self.state == .authCode || self.state == .authCodeFailure
            },
            set: { [weak self] in
                guard let self else { return }
                if !$0 { self.state = .phoneNumberLogin }
            }
        )
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
