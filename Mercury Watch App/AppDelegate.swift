//
//  SceneDelegate.swift
//  Mercury Watch App
//
//  Created by Marco Tammaro on 18/05/24.
//

import Foundation
import WatchKit
import AVFAudio

class MyWatchAppDelegate: NSObject, WKApplicationDelegate {
    
    func applicationDidBecomeActive() {
        setOnlineStatus()
        initAudioSession()
    }
    
    func applicationDidEnterBackground() {
        setOfflineStatus()
    }
    
    func setOnlineStatus() {
        Task {
            let result = try? await TDLibManager.shared.client?.setOption(
                name: "online",
                value: .optionValueBoolean(.init(value: true))
            )
            
            print("[CLIENT] [\(type(of: self))] [\(#function)] \(String(describing: result))")
        }
    }
    
    func setOfflineStatus() {
        Task {
            let result = try? await TDLibManager.shared.client?.setOption(
                name: "online",
                value: .optionValueBoolean(.init(value: false))
            )
            
            print("[CLIENT] [\(type(of: self))] [\(#function)] \(String(describing: result))")
        }
    }
    
    func initAudioSession() {
        do {
            let audioSession = AVAudioSession.sharedInstance()
            try audioSession.setCategory(.playAndRecord, mode: .default)
            try audioSession.setActive(true)
        } catch {
            print("[CLIENT] [\(type(of: self))] [\(#function)] error: \(error)")
        }
    }

}
