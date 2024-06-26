//
//  MockMessageViewModel.swift
//  Mercury Watch App
//
//  Created by Alessandro Alberti on 31/05/24.
//

import TDLibKit
import SwiftUI

class MessageViewModelMock: MessageViewModel {
    private var _userFullName: String
    private var _titleColor: Color
    private var _showSender: Bool
    
    init(message: Message = .preview(), name: String = "placeholder", titleColor: Color = .blue, showSender: Bool = false) {
        _userFullName = name
        _titleColor = titleColor
        _showSender = showSender
        super.init(message: message, chat: .preview())
    }
    
    override var date: String {
        "10:09"
    }
    
    override var userFullName: String {
        _userFullName
    }
    
    override var titleColor: Color {
        _titleColor
    }
    
    override var showSender: Bool {
        _showSender
    }
}
