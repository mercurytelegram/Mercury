//
//  SettingsViewModel.swift
//  Mercury Watch App
//
//  Created by Alessandro Alberti on 09/07/24.
//

import SwiftUI
import TDLibKit

class SettingsViewModel: TDLibViewModel {
    @Published var navStack: [ChatFolder] = [.main]
    @Published var user: User?
    @Published var showConnectingToast: Bool = false
    
    override init() {
        super.init()
        getUser()
    }
    
    override func connectionStateUpdate(state: ConnectionState) {
        if state == .connectionStateConnecting {
            checkConnection()
        }
        
        if state == .connectionStateReady {
            self.setConnectingToast(show: false)
        }
    }
    
    /// If after 1 second the connection is still in `.connectionStateConnecting` will show the connecting toast
    func checkConnection() {
        
        Task.detached {
            try await Task.sleep(for: .seconds(1))
            if TDLibManager.shared.connectionState == .connectionStateConnecting {
                self.setConnectingToast(show: true)
            }
        }
        
    }
    
    func getUser() {
        Task {
            let user = try? await TDLibManager.shared.client?.getMe()
            
            await MainActor.run {
                withAnimation {
                    self.user = user
                }
            }
        }
    }
    
    func profileThimbnail() -> UIImage {
        guard let data = user?.profilePhoto?.minithumbnail?.data else { return UIImage() }
        return UIImage(data: data) ?? UIImage()
    }
    
    func setConnectingToast(show: Bool) {
        DispatchQueue.main.async {
            withAnimation {
                self.showConnectingToast = show
            }
        }
    }
}
