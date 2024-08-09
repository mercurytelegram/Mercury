//
//  BubbleStyle.swift
//  Mercury Watch App
//
//  Created by Alessandro Alberti on 16/07/24.
//

import SwiftUI

struct MessageBubbleView<Content> : View where Content : View {
    @EnvironmentObject var vm: MessageViewModel
    var showBackground: Bool = true
    @ViewBuilder var content: () -> Content
    
    var body: some View {
        VStack(alignment: .trailing){
            VStack(alignment: vm.textAlignment){
                if vm.showSender {
                    Text(vm.userFullName)
                        .fontWeight(.semibold)
                        .foregroundStyle(vm.titleColor)
                        .redacted(reason: vm.userNameRedaction)
                }
                content()
            }
            
            HStack() {
                Text(vm.date)
                    .font(.system(size: 15))
                    .foregroundStyle(.secondary)
                
                if vm.state == .sending {
                    SendingLoaderView()
                }
            }
            
        }
        .padding()
        .padding(vm.message.isOutgoing ? .trailing : .leading, 5)
        .background {
            if showBackground {
                BubbleShape(myMessage: vm.message.isOutgoing)
                    .foregroundStyle(vm.bubbleColor)
            }        }
        .frame(maxWidth: .infinity, alignment: vm.message.isOutgoing ? .trailing : .leading)
    }
}

#Preview("Message") {
    VStack {
        MessageBubbleView {
            Text("Hello")
        }
        .environmentObject(
            MessageViewModelMock(
                name: "Craig Federighi",
                showSender: true
            ) as MessageViewModel
        )
        
        MessageBubbleView {
            Text("World")
        }
        .environmentObject(
            MessageViewModelMock(
                message: .preview(
                    isOutgoing: true)
            ) as MessageViewModel
        )
    }
}

#Preview("Loading") {
    VStack {
        MessageBubbleView {
            Text("Hello")
        }
        .environmentObject(
            MessageViewModelMock(
                name: "placeholder",
                showSender: true
            ) as MessageViewModel
        )
        
        MessageBubbleView {
            Text("World")
        }
        .environmentObject(
            MessageViewModelMock(
                message: .preview(
                    isOutgoing: true),
                isSending: true
            ) as MessageViewModel
        )
    }
}
