//
//  MockSettingsViewModel.swift
//  Mercury Watch App
//
//  Created by Alessandro Alberti on 15/07/24.
//

import TDLibKit
import UIKit

class MockSettingsViewModel: SettingsViewModel {
    
    override init() {
        super.init()
        self.user = User.preview()
    }
    
    override func getUser() {}
    
    override func profileThumbnail() -> UIImage {
        return UIImage(named: "craig") ?? UIImage()
    }
    
}
