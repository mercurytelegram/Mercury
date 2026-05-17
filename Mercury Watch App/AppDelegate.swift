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
    
    func applicationDidFinishLaunching() {
        cleanTmpFolder()
    }
    
    func applicationDidBecomeActive() {
        LoginViewModel.setOnlineStatus()
    }
    
    func applicationDidEnterBackground() {
        LoginViewModel.setOfflineStatus()
    }
    
    func applicationWillResignActive() {
        LoginViewModel.setOfflineStatus()
    }
    
    private func cleanTmpFolder() {
        try? FileManager.default.removeItem(
            at: FileManager.default.temporaryDirectory
        )
    }
}
