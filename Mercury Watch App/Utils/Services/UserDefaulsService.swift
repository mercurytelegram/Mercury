//
//  UserDefaulService.swift
//  Mercury
//
//  Created by Marco Tammaro on 03/11/24.
//

import Foundation

class UserDefaulsService {
    
    private enum Keys {
        static let isAuthenticated = "isAuthenticated"
    }
    
    static var isAuthenticated: Bool {
        get {
            return UserDefaults.standard.bool(forKey: Keys.isAuthenticated)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: Keys.isAuthenticated)
        }
    }
    
}
