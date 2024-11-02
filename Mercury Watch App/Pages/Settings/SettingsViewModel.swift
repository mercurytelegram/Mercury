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
        getUser()
    }
    
    func getUser() {
        Task {
            let user = try? await TDLibManager.shared.client?.getMe()
            
            await MainActor.run {
                withAnimation {
                    self.user = user
                }
            }
        }
    }
    
    func profileTDImage() -> TDImage? {
        return self.user?.profilePhoto
    }
    
    func profileThimbnail() -> UIImage {
        guard let data = user?.profilePhoto?.minithumbnail?.data else { return UIImage() }
        return UIImage(data: data) ?? UIImage()
    }
    
    var userCellViewModel: UserCellViewModel {
        .init(user: self.user)
    }
}
