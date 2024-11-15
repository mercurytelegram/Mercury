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
    
    var user: User?
    
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
                        self.user = user
                    }
                }
                
            } catch {
                self.logger.log(error, level: .error)
            }
        }
    }
}

// MARK: - Mock
@Observable
class SettingsViewModelMock: SettingsViewModel {
    override func logout() {}
    override func getUser() {}
}
