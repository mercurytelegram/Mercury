//
//  Extensions+ChatType.swift
//  Mercury Watch App
//
//  Created by Marco Tammaro on 29/05/24.
//

import Foundation
import TDLibKit

extension ChatType {
    
    var isGroup: Bool {
        switch self {
        case .chatTypeBasicGroup(_), .chatTypeSupergroup(_):
            return true
        
        default:
            return false
        }
    }
    
}
