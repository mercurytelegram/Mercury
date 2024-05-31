//
//  TDLibViewModel.swift
//  Mercury Watch App
//
//  Created by Marco Tammaro on 29/04/24.
//

import SwiftUI
import TDLibKit
import Combine

class TDLibViewModel: ObservableObject, TDLibManagerProtocol {
    
    init() {
        print("[CLIENT] [\(type(of: self))] initialized")
        TDLibManager.shared.subscribe(self)
    }
    
    deinit {
        print("[CLIENT] [\(type(of: self))] deinitialized")
        TDLibManager.shared.unsubscribe(self)
    }
    
    // TDLibManagerProtocol
    func updateHandler(update: TDLibKit.Update) {}
    func connectionStateUpdate(state: TDLibKit.ConnectionState) {}
}
