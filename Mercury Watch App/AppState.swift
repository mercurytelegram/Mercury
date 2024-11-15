//
//  AppState.swift
//  Mercury Watch App
//
//  Created by Alessandro Alberti on 2/11/24.
//

import Foundation
import SwiftUI

@Observable
class AppState {
    
    static var shared = AppState()
    
    var isMock: Bool = false
    var isAuthenticated: Bool? = UserDefaulsService.isAuthenticated
    private(set) var folders: [ChatFolder] = [.main, .archive]
    
    func insertFolder(_ folder: ChatFolder) {
        
        let isNotMain = folder != .main
        let isNotArchive = folder != .archive
        let isNotAdded = !folders.contains(folder)
        
        guard isNotMain, isNotArchive, isNotAdded
        else { return }
        
        withAnimation {
            // To leave Archive in the last position
            self.folders.insert(folder, at: self.folders.count - 1)
        }
    }
    
    public func clear() {
        folders = [.main, .archive]
    }
}
