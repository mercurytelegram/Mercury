//
//  TDLibManagerProtocol.swift
//  Mercury Watch App
//
//  Created by Marco Tammaro on 29/04/24.
//

import Foundation
import TDLibKit

protocol TDLibManagerProtocol: AnyObject {
    /// Called every time a new `TDLibKit.Update` is received from TDLib
    /// > Attention: `TDLibKit.ConnectionState` and `TDLibKit.AuthorizationState` will not be received from this function, they are instad managed by a specific handler: `TDLibManagerProtocol.connectionStateUpdate` and `TDLibManagerProtocol.authorizationStateUpdate`
    func updateHandler(update: Update)
    
    /// Called every time a new `TDLibKit.ConnectionState` is received from TDLib
    func connectionStateUpdate(state: ConnectionState)
    
    /// Called every time a new `TDLibKit.AuthorizationState` is received from TDLib
    func authorizationStateUpdate(state: AuthorizationState)
}
