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
    @Published var showConnectingBorder: Bool = false
    @Published var connectingBorderColor: Color = .red
    
    override init() {
        super.init()
        getUser()
    }
    
    override func connectionStateUpdate(state: ConnectionState) {
        checkConnection(state)
    }
    
    /// This function is responsible of showing a "connecting" toast bar or a "connecting" border
    /// After 1 second that the connection is in `.connectionStateConnecting` the toast will be shown
    /// After 5 more seconds that the connection is still in `.connectionStateConnecting` the toast will be dismissed and the red border will appear
    /// When the connection became `.connectionStateReady` the toast will be dismissed and the borer will firstly became green and then dismissed
    func checkConnection(_ state: ConnectionState) {
        
        if state == .connectionStateConnecting {
            Task.detached {
                try await Task.sleep(for: .seconds(1))
                if TDLibManager.shared.connectionState == .connectionStateConnecting {
                    self.setConnectingToast(show: true)
                    try await Task.sleep(for: .seconds(5))
                    if TDLibManager.shared.connectionState == .connectionStateConnecting {
                        self.setConnectingToast(show: false)
                        self.setConnectingBorder(show: true, color: .red)
                    }
                }
            }
        }
        
        if state == .connectionStateReady {
            self.setConnectingToast(show: false)
            
            if showConnectingBorder {
                Task.detached {
                    self.setConnectingBorder(show: true, color: .green)
                    try await Task.sleep(for: .seconds(1))
                    self.setConnectingBorder(show: false, color: .green)
                }
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
    
    func profileThumbnail() -> UIImage {
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
    
    func setConnectingBorder(show: Bool, color: Color) {
        DispatchQueue.main.async {
            withAnimation {
                self.connectingBorderColor = color
                self.showConnectingBorder = show
            }
        }
    }
}
