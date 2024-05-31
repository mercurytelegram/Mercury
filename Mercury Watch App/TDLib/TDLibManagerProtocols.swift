//
//  TDLibManagerProtocol.swift
//  Mercury Watch App
//
//  Created by Marco Tammaro on 29/04/24.
//

import Foundation
import TDLibKit

protocol TDLibManagerProtocol {
    func updateHandler(update: Update)
    func connectionStateUpdate(state: ConnectionState)
    func subscribeID() -> String
}
extension TDLibManagerProtocol {
    func subscribeID() -> String {
        return "\(type(of: self))"
    }
}
