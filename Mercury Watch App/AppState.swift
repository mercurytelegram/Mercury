//
//  AppState.swift
//  Mercury Watch App
//
//  Created by Alessandro Alberti on 2/11/24.
//

import Foundation

@Observable
@MainActor
class AppState {
    static var shared = AppState()
    var isMock = false
}
