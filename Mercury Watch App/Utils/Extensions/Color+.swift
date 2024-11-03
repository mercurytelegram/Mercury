//
//  Color+.swift
//  Mercury Watch App
//
//  Created by Alessandro Alberti on 17/05/24.
//

import SwiftUI

public extension Color {
    init(fromUserId userId: Int64) {
        let colors: [Color] = [
            .tdRed,
            .tdGreen,
            .yellow,
            .tdBlue,
            .tdPurple,
            .tdPink,
            .tdTeal,
            .tdOrange,
        ]
        guard let id = Int(String(userId).replacingOccurrences(of: "-100", with: "-")) else {
            self.init(.blue)
            return
        }
        self.init(uiColor: UIColor(colors[[0, 7, 4, 1, 6, 3, 5][abs(id % 7)]]))
    }
}
