//
//  TDLibManager.swift
//  Mercury Watch App
//
//  Created by Marco Tammaro on 29/04/24.
//

import Foundation
import TDLibKit

final class TDLibManager {
    
    // Singleton
    static let shared = TDLibManager()
    private var manager: TDLibClientManager
    
    // Properties
    public var client: TDLibClient?
    public var delegates: [(id: String, delegate: TDLibManagerProtocol)] = []
    public var connectionState: ConnectionState?
    
    private init() {
        self.manager = TDLibClientManager()
        self.createClient()
    }
    
    public func subscribe(_ delegate: TDLibManagerProtocol) {
        let id = delegate.subscribeID()
        self.delegates.append((id, delegate))
        
        if let connectionState {
            updateConnectionState(state: connectionState)
        }
    }
    
    public func unsubscribe(_ delegate: TDLibManagerProtocol) {
        let id = delegate.subscribeID()
        self.delegates.removeAll { elem in
            elem.id == id
        }
    }
    
    public func close() {
        self.manager.closeClients()
    }
    
    public func createClient() {
        self.client = self.manager.createClient(updateHandler: updateHandler)
    }
    
    private func updateHandler(data: Data, client: TDLibClient) {
        guard let update = try? client.decoder.decode(Update.self, from: data) else { return }
        
        switch update {
        case .updateConnectionState(let state):
            self.updateConnectionState(state: state.state)
        default:
            break
        }
        
        for elem in delegates {
            elem.delegate.updateHandler(update: update)
        }
    }
    
    private func updateConnectionState(state: ConnectionState) {
        for elem in delegates {
            elem.delegate.connectionStateUpdate(state: state)
        }
        self.connectionState = state
    }
    
}
