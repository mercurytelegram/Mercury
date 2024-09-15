//
//  SceneDelegate.swift
//  Mercury Watch App
//
//  Created by Marco Tammaro on 18/05/24.
//

import Foundation
import WatchKit
import AVFAudio

class AppDelegate: NSObject, WKApplicationDelegate {
    
    let logger = LoggerService(AppDelegate.self)
    
    func applicationDidBecomeActive() {
        LoginViewModel.setOnlineStatus()
    }
    
    func applicationDidEnterBackground() {
        LoginViewModel.setOfflineStatus()
    }
}
