//
//  LoginView2.swift
//  Mercury Watch App
//
//  Created by Marco Tammaro on 23/04/24.
//

import SwiftUI
import TDLibKit
import EFQRCode

class LoginViewModel: TDLibViewModel {
    
    // Published
    @Published var authenticated: Bool? = nil
    
    @Published var qrcodeImage: UIImage?
    @Published var statusMessage: String = "Connecting..."
    
    @Published var showPassword = false
    @Published var password = ""
    @Published var isValidatingPassword = false
    @Published var useMock = false
    
    private var isClosing = false
    private let tdlibPath = FileManager.default
        .urls(for: .cachesDirectory, in: .userDomainMask)
        .first?
        .appendingPathComponent("tdlib", isDirectory: true)
        .path
    
    override func updateHandler(update: Update) {
        super.updateHandler(update: update)
        switch update {
        case .updateAuthorizationState(let state):
            self.manageUpdateAuthorizationState(state: state.authorizationState)
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
        
        DispatchQueue.main.async { self.authenticated = state == .authorizationStateReady }
        
        switch state {
        case .authorizationStateWaitTdlibParameters:
            setTdlibParameters()
            break
        case .authorizationStateWaitPhoneNumber:
            self.getQrcodeLink()
            break
        case .authorizationStateWaitOtherDeviceConfirmation(let info):
            DispatchQueue.main.async {
                let link = info.link
                if let cgimage = EFQRCode.generate(for: link) {
                    self.qrcodeImage = UIImage(cgImage: cgimage)
                }
            }
            break
        case .authorizationStateWaitPassword(_):
            DispatchQueue.main.async {
                self.qrcodeImage = nil
                self.showPassword = true
            }
            break
        case .authorizationStateLoggingOut:
            if !isClosing { TDLibManager.shared.close() }
            break
        case .authorizationStateClosing:
            self.isClosing = true
            DispatchQueue.main.async {
                self.isValidatingPassword = false
                self.showPassword = false
                self.qrcodeImage = nil
                self.statusMessage = "Connecting..."
                self.password = ""
                self.authenticated = nil
            }
            break
        case .authorizationStateClosed:
            try? FileManager.default.removeItem(atPath: tdlibPath!)
            TDLibManager.shared.createClient()
            DispatchQueue.main.async {
                self.isClosing = false
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
        
        Task {
            do {
                let result = try await TDLibManager.shared.client?.checkAuthenticationPassword(password: password)
                self.logger.log(result)
            } catch {
                self.logger.log(error, level: .error)
            }
            
            await MainActor.run {
                self.isValidatingPassword = false
                self.showPassword = false
            }
        }
    }
    
    func logout() {
        
        
        if useMock {
            useMock = false
            return
        }
        
        guard let client = TDLibManager.shared.client else { return }
        
        Task {
            do {
                let result = try await client.logOut()
                self.logger.log(result)
                
                TDLibManager.shared.close()
            } catch {
                self.logger.log(error, level: .error)
            }
        }
    }
    
    func setTdlibParameters() {
        
        Task {
            do {
                
                let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
                let deviceModel = deviceModel()
                
                let result = try await TDLibManager.shared.client?.setTdlibParameters(
                    apiHash: Secrets.apiHash,
                    apiId: Secrets.apiId,
                    applicationVersion: appVersion,
                    databaseDirectory: tdlibPath,
                    databaseEncryptionKey: nil,
                    deviceModel: deviceModel,
                    filesDirectory: nil,
                    systemLanguageCode: "en-US",
                    systemVersion: nil,
                    useChatInfoDatabase: nil,
                    useFileDatabase: nil,
                    useMessageDatabase: true,
                    useSecretChats: false,
                    useTestDc: false
                )
                
                #if DEBUG
                try await TDLibManager.shared.client?.setLogVerbosityLevel(newVerbosityLevel: 1)
                #else
                try await TDLibManager.shared.client?.setLogVerbosityLevel(newVerbosityLevel: 0)
                #endif
                
                self.logger.log(result)
        
            } catch {
                self.logger.log(error, level: .error)
            }
        }
    }
    
    private func deviceModel() -> String {
        var systemInfo = utsname()
        uname(&systemInfo)
        
        let modelCode = withUnsafePointer(to: &systemInfo.machine) {
            $0.withMemoryRebound(to: CChar.self, capacity: 1) {
                ptr in String.init(validatingUTF8: ptr)
            }
        }
        
        return modelCode ?? "unknown"
        
    }

}
