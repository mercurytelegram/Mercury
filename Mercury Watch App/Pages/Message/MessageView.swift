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
    
    init(_ vm: MessageViewModel) {
        self._vm = StateObject(wrappedValue: vm)
    }
    
    var body: some View {
        VStack(alignment: .trailing){
            VStack(alignment: vm.textAlignment){
                if vm.showSender {
                    Text(vm.userFullName)
                        .fontWeight(.semibold)
                        .foregroundStyle(vm.titleColor)
                        .redacted(reason: vm.userNameRedaction)
                }
                content
            }
            Text(vm.date)
                .font(.system(size: 15))
                .foregroundStyle(.secondary)
        }
        .padding()
        .padding(vm.message.isOutgoing ? .trailing : .leading, 5)
        .background {
            if vm.showBubble {
                BubbleShape(myMessage: vm.message.isOutgoing)
                    .foregroundStyle(vm.message.isOutgoing ? .blue.opacity(0.3) : .white.opacity(0.2))
            }
        }
        .frame(maxWidth: .infinity, alignment: vm.message.isOutgoing ? .trailing : .leading)
    }
    
    @ViewBuilder
    var content: some View {
        switch vm.message.content {
        case .messageText(let messageText):
            Text(messageText.text.attributedString)
        case .messagePhoto(let messagePhoto):
            TdPhotoView(tdPhoto: messagePhoto.photo)
                .clipShape(BubbleShape(myMessage: vm.message.isOutgoing))
                .padding(vm.message.isOutgoing ? .trailing : .leading, -10)
        default:
            Text(vm.message.description)
        }
    }
}


#Preview("Messages") {
    VStack {
        MessageView(MessageViewModelMock(name: "Craig Federighi"))
        MessageView(MessageViewModelMock(message: .preview(
            content: .text("World"),
            isOutgoing: true
        )))
    }
}

#Preview("Loading") {
    VStack {
        MessageView(MessageViewModelMock())
        MessageView(MessageViewModelMock(message: .preview(
            content: .text("World"),
            isOutgoing: true
        )))
    }
}
