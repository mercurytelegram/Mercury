//
//  MercuryApp.swift
//  Mercury Watch App
//
//  Created by Marco Tammaro on 18/04/24.
//

import SwiftUI

@main
struct MercuryApp: App {
    @Environment(\.isLuminanceReduced) var isLuminanceReduced
    @WKApplicationDelegateAdaptor var appDelegate: AppDelegate
    
    var body: some Scene {
        WindowGroup {
            
            let isMock = AppState.shared.isMock
            let isAuthenticated = AppState.shared.isAuthenticated ?? false
            
            if isMock || isAuthenticated {
                HomePage()
            } else {
                LoginPage()
            }
            
        }
        .onChange(of: isLuminanceReduced) {
            if isLuminanceReduced {
                LoginViewModel.setOfflineStatus()
            } else {
                LoginViewModel.setOnlineStatus()
            }
        }
        
    }
}
