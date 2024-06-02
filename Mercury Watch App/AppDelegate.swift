//
//  SceneDelegate.swift
//  Mercury Watch App
//
//  Created by Marco Tammaro on 18/05/24.
//

import Foundation
import WatchKit

class MyWatchAppDelegate: NSObject, WKApplicationDelegate {
    
    let logger = LoggerService(MyWatchAppDelegate.self)
    
    func applicationDidBecomeActive() {
//        setOnlineStatus()
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
            
            self.logger.log(result)
        }
    }
    
    func setOfflineStatus() {
        Task {
            let result = try? await TDLibManager.shared.client?.setOption(
                name: "online",
                value: .optionValueBoolean(.init(value: false))
            )
            
            self.logger.log(result)
        }
    }

}
