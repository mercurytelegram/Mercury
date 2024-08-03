//
//  BubbleImageTest.swift
//  Mercury Watch App
//
//  Created by Alessandro Alberti on 03/08/24.
//

import SwiftUI

struct MessageBubbleImageView<Content> : View where Content : View {
    @EnvironmentObject var vm: MessageViewModel
    var caption: String?
    @ViewBuilder var content: () -> Content
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            content()
            if let caption, caption != "" {
                Text(caption)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.leading, 10)
                    .padding(.top, 5)
                    .padding(.bottom, 25)
                    .background(vm.bubbleColor)
            }
        }
        .clipShape(BubbleShape(myMessage: false))
        .overlay {
            MessageBubbleView(showBackground: false) {
                Spacer()
                    .frame(maxWidth: .infinity)
            }
        }
    }
}


#Preview {
    
    return MessageBubbleImageView {
        Image("test")
            .resizable()
            .aspectRatio(contentMode: .fill)
    }
        .scaleEffect(0.8)
        .environmentObject(
            MessageViewModelMock(
                name: "Craig Federighi",
                showSender: true
            ) as MessageViewModel
        )
}

#Preview {
    
    return MessageBubbleImageView(caption: "Hello") {
        Image("test")
            .resizable()
            .aspectRatio(contentMode: .fill)
    }
        .scaleEffect(0.8)
        .environmentObject(
            MessageViewModelMock(
                name: "Craig Federighi",
                showSender: true
            ) as MessageViewModel
        )
}
