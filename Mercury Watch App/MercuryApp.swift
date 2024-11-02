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
            
            // TODO: Change logic when isAuthenticated is nil
            if let auth = AppState.shared.isAuthenticated {
                if auth || AppState.shared.isMock {
                    Text("Autenticated")
                } else {
                    LoginPage()
                }
            } else {
                ProgressView()
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
