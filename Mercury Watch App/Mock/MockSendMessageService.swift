//
//  MockSendMessageViewModel.swift
//  Mercury Watch App
//
//  Created by Alessandro Alberti on 31/05/24.
//

import Foundation
import TDLibKit

class MockSendMessageService: SendMessageService {
    override func sendTextMessage(_ text: String) {}
    override func sendVoiceNote(_ filePath: URL, _ duration: Int) {}
}
