//
//  TDLibViewModel.swift
//  Mercury Watch App
//
//  Created by Marco Tammaro on 29/04/24.
//

import SwiftUI
import TDLibKit
import Combine
import os

class TDLibViewModel: ObservableObject, TDLibManagerProtocol {
    
    let logger: LoggerService
    
    init() {
        self.logger = LoggerService("\(type(of: self))")
        TDLibManager.shared.subscribe(self)
        self.logger.log("initialised")
    }
    
    deinit {
        TDLibManager.shared.unsubscribe(self)
        self.logger.log("deinitialised")
    }
    
    // TDLibManagerProtocol
    func updateHandler(update: TDLibKit.Update) {}
    func connectionStateUpdate(state: TDLibKit.ConnectionState) {}
}
