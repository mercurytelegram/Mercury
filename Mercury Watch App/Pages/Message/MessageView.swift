//
//  MessageView.swift
//  Mercury Watch App
//
//  Created by Alessandro Alberti on 16/05/24.
//

import SwiftUI
import TDLibKit

struct MessageView: View {
    @StateObject var vm: MessageViewModel
    
    var body: some View {
        switch vm.message.content {
        case .messageText(let message):
            Text(message.text.attributedString)
                .bubbleStyle(vm: vm)
            
        case .messagePhoto(let message):
            TdImageView(tdImage: message.photo)
                .clipShape(BubbleShape(myMessage: vm.message.isOutgoing))
                .padding(vm.message.isOutgoing ? .trailing : .leading, -10)

        case .messageVoiceNote(let message):
            VoiceNoteContentView(message: message)
                .bubbleStyle(vm: vm)
            
        default:
            Text(vm.message.description)
                .bubbleStyle(vm: vm)
        }
    }
}


#Preview("Messages") {
    VStack {
        MessageView(vm: MessageViewModelMock(name: "Craig Federighi"))
        MessageView(vm: MessageViewModelMock(message: .preview(
            content: .text("World"),
            isOutgoing: true
        )))
    }
}

#Preview("Loading Name") {
    VStack {
        MessageView(vm: MessageViewModelMock(showSender: true))
    }
}
