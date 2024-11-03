//
//  AppState.swift
//  Mercury Watch App
//
//  Created by Alessandro Alberti on 2/11/24.
//

import Foundation

@Observable
class AppState {
    static var shared = AppState()
    var isMock: Bool = false
    var isAuthenticated: Bool? = UserDefaulsService.isAuthenticated
}
