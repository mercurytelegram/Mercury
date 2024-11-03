//
//  MessageSender+.swift
//  Mercury Watch App
//
//  Created by Marco Tammaro on 29/05/24.
//

import Foundation
import TDLibKit

extension MessageSender {
    func username() async -> String? {
        if case .messageSenderUser(let senderUser) = self {
            
            guard let user = try? await TDLibManager.shared.client?.getUser(userId: senderUser.userId)
            else { return nil }
            
            var name = user.firstName
            if !user.lastName.isEmpty {
                name += " " + user.lastName
            }
            
            return name
            
        }
        
        return nil
    }
}
