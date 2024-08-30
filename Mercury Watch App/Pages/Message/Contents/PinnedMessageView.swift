//
//  PinnedMessageView.swift
//  Mercury Watch App
//
//  Created by Alessandro Alberti on 30/08/24.
//

import SwiftUI

struct PinnedMessageView: View {
    @EnvironmentObject var vm: MessageViewModel
    
    var user: String {
        vm.message.isOutgoing ? "You" : vm.userFullName
    }
    
    var body: some View {
        Text("**\(user)**\n pinned a message")
            .multilineTextAlignment(.center)
            .font(.footnote)
            .padding()
            .padding(.horizontal)
            .background {
                Capsule()
                    .foregroundStyle(.ultraThinMaterial)
            }
    }
}

#Preview {
    VStack {
        PinnedMessageView()
            .environmentObject(
                MessageViewModelMock(
                    name: "Craig Federighi",
                    showSender: true
                ) as MessageViewModel
            )
            
        PinnedMessageView()
            .environmentObject(
                MessageViewModelMock(
                    message: .preview(
                        isOutgoing: true)
                ) as MessageViewModel
            )
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(.blue.opacity(0.3))
}


