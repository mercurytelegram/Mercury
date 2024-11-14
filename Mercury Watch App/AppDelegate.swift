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
        cleanDirectoryFolder()
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
    
    #warning("Remove it in a future release")
    /// This function will remove all the files in Documents Directory since the recoder was using it as tmp storage
    /// Once all the users will have documents dir cleard, this function can be removed in order to reuse the documents directory
    private func cleanDirectoryFolder() {
        let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        guard let path = url.first else { return }
        try? FileManager.default.removeItem(at: path)
    }
}
