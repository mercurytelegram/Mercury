//
//  Extensions+View.swift
//  Mercury Watch App
//
//  Created by Alessandro Alberti on 21/08/24.
//

import SwiftUI

extension View {
    var isPreview: Bool {
        ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1"
    }
}
