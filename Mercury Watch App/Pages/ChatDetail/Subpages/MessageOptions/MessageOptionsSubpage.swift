//
//  MessageOptionsView.swift
//  Mercury Watch App
//
//  Created by Alessandro Alberti on 11/09/24.
//

import SwiftUI
import TDLibKit

struct MessageOptionsSubpage: View {
    
    @State
    @Mockable
    var vm: MessageOptionsViewModel
    
    @Binding var isPresented: Bool
    
    init(isPresented: Binding<Bool>, model: MessageOptionsModel) {
        self._isPresented = isPresented
        _vm = Mockable.state(
            value: { MessageOptionsViewModel(model: model) },
            mock: { MessageOptionsViewModelMock() }
        )
    }
    
    private let columns = [
        GridItem(.adaptive(minimum: 40))
    ]
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns) {
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
                            .font(.system(size: 30))
                            .background {
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(.white.opacity(0.2))
                                    .opacity(vm.selectedEmoji == emoji ? 1 : 0)
                                    
                            }
                    })
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .padding(.horizontal)
        }
    }
}

struct MessageOptionsModel {
    var chatId: Int64
    var messageId: Int64
    var sendService: SendMessageService
}

#Preview {
    Rectangle()
        .foregroundStyle(.blue.opacity(0.8))
        .ignoresSafeArea()
        .sheet(isPresented: .constant(true), content: {
            MessageOptionsSubpage(
                isPresented: .constant(true),
                model: .init(
                    chatId: 0,
                    messageId: 0,
                    sendService: SendMessageServiceMock()
                )
            )
        })
}
    

