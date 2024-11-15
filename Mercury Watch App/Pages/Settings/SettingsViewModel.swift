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
class SettingsViewModel: TDLibViewModel {
    
    var user: UserModel?
    
    override init() {
        super.init()
        getUser()
    }
    
    func logout() {
        LoginViewModel.logout()
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

// MARK: - Mock
@Observable
class SettingsViewModelMock: SettingsViewModel {
    override func getUser() {
        self.user = .init(
            thumbnail: UIImage(named: "astro"),
            avatar: .astro,
            fullName: "John Appleseed",
            mainUserName: "@johnappleseed",
            phoneNumber: "+39 0000000000"
        )
    }
}
