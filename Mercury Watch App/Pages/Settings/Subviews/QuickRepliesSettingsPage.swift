//
//  QuickRepliesSettingsPage.swift
//  Mercury Watch App
//
//  Created by Codex on 28/04/26.
//

import SwiftUI

struct QuickRepliesSettingsPage: View {
    var vm: SettingsViewModel
    
    var body: some View {
        List {
            Section {
                ForEach(Array(vm.quickReplyTemplates.enumerated()), id: \.offset) { index, template in
                    Button {
                        vm.editQuickReply(at: index)
                    } label: {
                        HStack {
                            Text(template)
                                .lineLimit(2)
                            Spacer()
                            Image(systemName: "pencil")
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }
            
            Button("Reset", systemImage: "arrow.counterclockwise") {
                vm.resetQuickReplies()
            }
            .tint(.orange)
        }
        .navigationTitle("Quick Replies")
    }
}

#Preview {
    NavigationStack {
        QuickRepliesSettingsPage(vm: SettingsViewModelMock())
    }
}
