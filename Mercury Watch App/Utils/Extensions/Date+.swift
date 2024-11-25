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
    
    var dayDescription: String {
        let formatter = DateFormatter()
        
        if Calendar.current.isDateInToday(self) {
            return "Today"
        } else if Calendar.current.isDateInYesterday(self) {
            return "Yesterday"
        } else {
            formatter.dateStyle = .medium
            formatter.timeStyle = .none
        }
        
        return formatter.string(from: self)
    }
    
    static var appleWatchPresentationDate: Date {
        let calendar = Calendar(identifier: .gregorian)
        let components = DateComponents(
            year: 2014,
            month: 9,
            day: 9,
            hour: 10,
            minute: 9
        )
        return calendar.date(from: components) ?? Date()
    }
    
    static var iPhonePresentationDate: Date {
        let calendar = Calendar(identifier: .gregorian)
        let components = DateComponents(
            year: 2007,
            month: 1,
            day: 9,
            hour: 9,
            minute: 41
        )
        return calendar.date(from: components) ?? Date()
    }
    
    init(fromUnixTimestamp timestamp: Int) {
        self.init(timeIntervalSince1970: TimeInterval(timestamp))
    }
}
