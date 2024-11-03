//
//  Date+.swift
//  Mercury Watch App
//
//  Created by Alessandro Alberti on 10/05/24.
//

import Foundation

extension Date {
    var stringDescription: String {
        let formatter = DateFormatter()
        
        if Calendar.current.isDateInToday(self) {
            formatter.dateStyle = .none
            formatter.timeStyle = .short
            return formatter.string(from: self)
        } else if Calendar.current.isDateInYesterday(self) {
            return "Yesterday"
        } else {
            formatter.dateStyle = .short
            formatter.timeStyle = .none
        }
        
        return formatter.string(from: self)
    }
    
    init(fromUnixTimestamp timestamp: Int) {
        self.init(timeIntervalSince1970: TimeInterval(timestamp))
    }
}
