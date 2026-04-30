//
//  ForumTopicsPage.swift
//  Mercury Watch App
//
//  Created by Dmytro Manko on 26/04/26.
//

import SwiftUI

struct ForumTopicsPage: View {
    
    @State
    @Mockable
    var vm: ForumTopicsViewModel
    
    init(chatId: Int64) {
        _vm = Mockable.state(
            value: { ForumTopicsViewModel(chatId: chatId) },
            mock: { ForumTopicsViewModelMock() }
        )
    }
    
    var body: some View {
        Group {
            if vm.isLoading {
                ProgressView()
            } else if let error = vm.error {
                Text(error)
                    .font(.caption)
                    .foregroundStyle(.red)
                    .multilineTextAlignment(.center)
                    .padding()
            } else if vm.topics.isEmpty {
                ContentUnavailableView(
                    "No Topics",
                    systemImage: "bubble.left.and.bubble.right",
                    description: Text("This forum has no visible topics yet.")
                )
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
            }
        }
        .navigationTitle("Topics")
    }
}

#Preview(traits: .mock()) {
    NavigationStack {
        ForumTopicsPage(chatId: 0)
    }
}
