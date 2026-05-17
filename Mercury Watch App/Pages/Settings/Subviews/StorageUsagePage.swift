//
//  StorageUsagePage.swift
//  Mercury Watch App
//
//  Created by Codex on 28/04/26.
//

import SwiftUI

struct StorageUsagePage: View {
    @State
    @Mockable(mockInit: StorageUsageViewModelMock.init)
    private var vm = StorageUsageViewModel.init
    
    var body: some View {
        Group {
            if vm.isLoading {
                ProgressView()
            } else {
                List {
                    if let title = vm.cleaningTitle {
                        StorageCleaningView(title: title)
                            .listRowBackground(Color.clear)
                    }
                    
                    Section {
                        VStack(alignment: .leading, spacing: 6) {
                            Text(vm.totalSize)
                                .font(.title3)
                                .fontWeight(.semibold)
                            Text("\(vm.fileCount) cached files")
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        
                        HStack {
                            Label("Media Cache", systemImage: "internaldrive")
                            Spacer()
                            Text(vm.totalSize)
                                .foregroundStyle(.secondary)
                        }
                        
                        HStack {
                            Label("Files", systemImage: "doc")
                            Spacer()
                            Text("\(vm.fileCount)")
                                .foregroundStyle(.secondary)
                        }
                    }
                    
                    if let statusMessage = vm.statusMessage {
                        Text(statusMessage)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    
                    Button(role: .destructive) {
                        vm.clearAllCache()
                    } label: {
                        if vm.isClearingAll {
                            Label("Clearing...", systemImage: "arrow.triangle.2.circlepath")
                        } else {
                            Label("Clear All Cache", systemImage: "trash")
                        }
                    }
                    .disabled(vm.isClearing)
                    
                    Section("Chats") {
                        if vm.chats.isEmpty {
                            ContentUnavailableView(
                                "Cache Empty",
                                systemImage: "checkmark.circle",
                                description: Text("No clearable chat cache.")
                            )
                        } else {
                            ForEach(vm.chats) { chat in
                                NavigationLink {
                                    StorageChatUsagePage(vm: vm, chat: chat)
                                } label: {
                                    HStack {
                                        VStack(alignment: .leading) {
                                            Text(chat.title)
                                                .lineLimit(1)
                                            Text("\(chat.fileCount) files")
                                                .font(.caption2)
                                                .foregroundStyle(.secondary)
                                        }
                                        Spacer()
                                        Text(chat.formattedSize)
                                            .foregroundStyle(.secondary)
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
        .navigationTitle("Storage Usage")
        .task {
            await vm.load()
        }
    }
}

#Preview(traits: .mock()) {
    NavigationStack {
        StorageUsagePage()
    }
}

private struct StorageChatUsagePage: View {
    var vm: StorageUsageViewModel
    let chat: StorageChatUsageModel
    
    var body: some View {
        List {
            if vm.clearingChatId == chat.id {
                StorageCleaningView(title: "Clearing \(chat.title)")
                    .listRowBackground(Color.clear)
            }
            
            Section {
                HStack {
                    Text("Used")
                    Spacer()
                    Text(chat.formattedSize)
                        .foregroundStyle(.secondary)
                }
                
                HStack {
                    Text("Files")
                    Spacer()
                    Text("\(chat.fileCount)")
                        .foregroundStyle(.secondary)
                }
            }
            
            Button(role: .destructive) {
                vm.clearCache(for: chat)
            } label: {
                if vm.clearingChatId == chat.id {
                    Label("Clearing...", systemImage: "arrow.triangle.2.circlepath")
                } else {
                    Label("Clear Chat Cache", systemImage: "trash")
                }
            }
            .disabled(vm.isClearing)
            
            Section("File Types") {
                ForEach(chat.fileTypes) { fileType in
                    HStack {
                        Text(fileType.title)
                        Spacer()
                        Text(fileType.formattedSize)
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
        .navigationTitle(chat.title)
    }
}

private struct StorageCleaningView: View {
    let title: String
    @State private var isAnimating = false
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: "arrow.triangle.2.circlepath")
                .font(.system(size: 24, weight: .semibold))
                .foregroundStyle(.blue)
                .rotationEffect(.degrees(isAnimating ? 360 : 0))
                .animation(
                    .linear(duration: 1).repeatForever(autoreverses: false),
                    value: isAnimating
                )
            
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
        .onAppear {
            isAnimating = true
        }
    }
}
