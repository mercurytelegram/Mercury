//
//  SettingsViewModel.swift
//  Mercury Watch App
//
//  Created by Alessandro Alberti on 09/07/24.
//

import SwiftUI
import TDLibKit

class SettingsViewModel: ObservableObject {
    @Published var navStack: [ChatFolder] = [.main]
    @Published var user: User?
    
    init() {
        Task {
            let user = try? await TDLibManager.shared.client?.getMe()
            
            await MainActor.run {
                withAnimation {
                    self.user = user
                }
            }
        }
    }
}
