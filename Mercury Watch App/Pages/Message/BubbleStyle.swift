//
//  BubbleStyle.swift
//  Mercury Watch App
//
//  Created by Alessandro Alberti on 16/07/24.
//

import SwiftUI

struct BubbleStyle: ViewModifier {
    @StateObject var vm: MessageViewModel
    
    func body(content: Content) -> some View {
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
            BubbleShape(myMessage: vm.message.isOutgoing)
                .foregroundStyle(vm.message.isOutgoing ? .blue.opacity(0.7) : .white.opacity(0.2))
            
        }
        .frame(maxWidth: .infinity, alignment: vm.message.isOutgoing ? .trailing : .leading)
    }
}

extension View {
    func bubbleStyle(vm: MessageViewModel) -> some View {
        modifier(BubbleStyle(vm: vm))
    }
}

#Preview("Message") {
    VStack {
        Text("Hello")
            .bubbleStyle(vm: MessageViewModelMock(
                name: "Craig Federighi",
                showSender: true)
        )
        
        Text("World!")
            .bubbleStyle(vm: MessageViewModelMock(
                message: .preview(
                isOutgoing: true)
            ))
    }
}

#Preview("Loading") {
    VStack {
        Text("Hello")
            .bubbleStyle(vm: MessageViewModelMock(
                name: "placeholder",
                showSender: true)
        )
        
        Text("World!")
            .bubbleStyle(vm: MessageViewModelMock(
                message: .preview(
                isOutgoing: true),
                isSending: true
            ))
    }
}
