//
//  ForumTopicsPage.swift
//  Mercury Watch App
//
//  Created by Dmytro Manko on 26/04/26.
//

import SwiftUI

struct ForumTopicsPage: View {
    
    @State var vm: ForumTopicsViewModel
    
    init(chatId: Int64) {
        _vm = State(initialValue: ForumTopicsViewModel(chatId: chatId))
    }
    
    var body: some View {
        if vm.isLoading {
            ProgressView()
        } else if let error = vm.error {
            Text(error)
                .foregroundStyle(.red)
                .multilineTextAlignment(.center)
                .padding()
        } else {
            List(vm.topics, id: \.messageThreadId) { topic in
                NavigationLink {
                    ChatDetailPage(
                        chatId: topic.id ?? vm.chatId,
                        messageThreadId: topic.messageThreadId ?? 0
                    )
                } label: {
                    ChatCellView(model: topic) {} onPressMuteButton: {}
                }
            }
            .listStyle(.carousel)
            .navigationTitle("Topics")
        }
    }
}
