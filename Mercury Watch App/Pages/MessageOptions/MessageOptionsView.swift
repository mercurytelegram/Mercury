//
//  MessageOptionsView.swift
//  Mercury Watch App
//
//  Created by Alessandro Alberti on 11/09/24.
//

import SwiftUI
import TDLibKit

struct MessageOptionsView: View {
    @Binding var isPresented: Bool
    @StateObject var vm: MessageOptionsViewModel
    
    init(isPresented: Binding<Bool>, message: Message, chat: Chat) {
        self._isPresented = isPresented
        self._vm = StateObject(
            wrappedValue: MessageOptionsViewModel(
                messageId: message.id,
                chatId: chat.id
            ))
    }
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: vm.columns) {
                ForEach(vm.emojis, id: \.self) { emoji in
                    Button(action: {
                        Task {
                            await vm.sendReaction(emoji)
                            await MainActor.run {
                                isPresented = false
                            }
                        }
                    }, label: {
                        Text(emoji)
                            .font(.system(size: 35))
                    })
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .padding(.horizontal)
        }
    }
}

#Preview {
    Rectangle()
        .foregroundStyle(.blue.opacity(0.8))
        .ignoresSafeArea()
        .sheet(isPresented: .constant(true), content: {
            MessageOptionsView(isPresented: .constant(true), message: .preview(), chat: .preview())
        })
}
    

