//
//  PreviewTrait+Mock.swift
//  Mercury Watch App
//
//  Created by Alessandro Alberti on 2/11/24.
//

import Foundation
import SwiftUI

extension PreviewTrait where T == Preview.ViewTraits {
    static func mock() -> Self {
        AppState.shared.isMock = true
        return .defaultLayout
    }
}
