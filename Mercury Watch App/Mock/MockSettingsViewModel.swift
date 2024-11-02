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
    
    override func profileTDImage() -> TDImage {
        TDImageMock("astro")
    }
    
    override func profileThimbnail() -> UIImage {
        return UIImage(named: "astro") ?? UIImage()
    }
    
    override var userCellViewModel: UserCellViewModel {
        MockUserCellViewModel(user: self.user)
    }
    
}
