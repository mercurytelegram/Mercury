//
//  MercuryApp.swift
//  Mercury Watch App
//
//  Created by Marco Tammaro on 18/04/24.
//

import SwiftUI

@main
struct Mercury_Watch_AppApp: App {
    
    @StateObject var vm = LoginViewModel()
    @WKApplicationDelegateAdaptor var appDelegate: MyWatchAppDelegate
    
    var body: some Scene {
        WindowGroup {
            
            if let auth = vm.authenticated {
                if auth || vm.useMock{
                    ChatListView(useMock: vm.useMock)
                        .environmentObject(vm)
                } else {
                    LoginView()
                        .environmentObject(vm)
                }
            } else {
                ProgressView()
            }
            
        }
    }
}
