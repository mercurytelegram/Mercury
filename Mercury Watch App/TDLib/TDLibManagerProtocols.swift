//
//  TDLibManagerProtocol.swift
//  Mercury Watch App
//
//  Created by Marco Tammaro on 29/04/24.
//

import Foundation
import TDLibKit

protocol TDLibManagerProtocol: AnyObject {
    func updateHandler(update: Update)
    func connectionStateUpdate(state: ConnectionState)
}
