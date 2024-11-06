//
//  PinnedMessageView.swift
//  Mercury Watch App
//
//  Created by Alessandro Alberti on 30/08/24.
//

import SwiftUI

struct PillMessageView_Old: View {
    @EnvironmentObject var vm: MessageViewModel_Old
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
        PillMessageView_Old(description: "pinned a message")
            .environmentObject(
                MessageViewModelMock(
                    name: "Craig Federighi",
                    showSender: true
                ) as MessageViewModel_Old
            )
        Group {
            PillMessageView_Old(description: "pinned a message")
            PillMessageView_Old(description: "changed the group name to \"test\"")
        }
        .environmentObject(
            MessageViewModelMock(
                message: .preview(
                    isOutgoing: true)
            ) as MessageViewModel_Old
        )
        
            
        
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(.blue.opacity(0.3))
}


