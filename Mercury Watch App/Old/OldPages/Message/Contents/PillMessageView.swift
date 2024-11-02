//
//  PinnedMessageView.swift
//  Mercury Watch App
//
//  Created by Alessandro Alberti on 30/08/24.
//

import SwiftUI

struct PillMessageView: View {
    @EnvironmentObject var vm: MessageViewModel
    var description: String
    
    var user: String {
        vm.message.isOutgoing ? "You" : vm.userFullName
    }
    
    var body: some View {
        Text("**\(user)**\n\(description)")
            .multilineTextAlignment(.center)
            .font(.footnote)
            .padding()
            .padding(.horizontal)
            .background {
                RoundedRectangle(cornerRadius: 30)
                    .foregroundStyle(.ultraThinMaterial)
            }
    }
}

#Preview {
    ScrollView {
        PillMessageView(description: "pinned a message")
            .environmentObject(
                MessageViewModelMock(
                    name: "Craig Federighi",
                    showSender: true
                ) as MessageViewModel
            )
        Group {
            PillMessageView(description: "pinned a message")
            PillMessageView(description: "changed the group name to \"test\"")
        }
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


