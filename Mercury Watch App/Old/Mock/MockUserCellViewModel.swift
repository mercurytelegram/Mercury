//
//  MockUserCellViewModel.swift
//  Mercury Watch App
//
//  Created by Alessandro Alberti on 10/25/24.
//

import Foundation
import TDLibKit

class MockUserCellViewModel: UserCellViewModel {
    private var imageName: String
    
    init(
        user: User? = .preview(firstName: "John", lastName: "Appleseed"),
        imageName: String = "astro"
    ) {
        self.imageName = imageName
        super.init(user: user)
    }
    
    override var avatarModel: AvatarModel_Old {
        return AvatarModel_Old(tdImage: TDImageMock(imageName))
    }
}
