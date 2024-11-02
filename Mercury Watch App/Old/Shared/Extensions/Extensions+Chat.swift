//
//  Extensions+ChatType.swift
//  Mercury Watch App
//
//  Created by Marco Tammaro on 29/05/24.
//

import Foundation
import TDLibKit

extension Chat {
    
    var isGroup: Bool {
        switch self.type {
        case .chatTypeBasicGroup(_), .chatTypeSupergroup(_):
            return true
        
        default:
            return false
        }
    }
    
    var isArchived: Bool {
        return self.chatLists.contains(.chatListArchive)
    }
    
}
