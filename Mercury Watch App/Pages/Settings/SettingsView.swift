//
//  SettingsView.swift
//  Mercury Watch App
//
//  Created by Alessandro Alberti on 19/06/24.
//

import SwiftUI
import TDLibKit

struct SettingsView: View {
    @StateObject var settingsVM = SettingsViewModel()
    @StateObject var chatListVM = ChatListViewModel()
    
    var body: some View {
        NavigationStack(path: $settingsVM.navStack) {
            List {
                NavigationLink {
                    AccountDetailView(vm: settingsVM)
                } label: {
                    UserCellView(user: settingsVM.user)
                }
                
                
                Section {
                    // Folders
                    ForEach(chatListVM.folders, id: \.self) { folder in
                        NavigationLink(value: folder) {
                            Label {
                                Text(folder.title)
                            } icon: {
                                Image(systemName: folder.iconName)
                                    .font(.caption)
                                    .foregroundStyle(folder.color)
                            }
                        }
                        .listItemTint(folder.color)
                    }
                }
                
            }
            .navigationTitle("Mercury")
            .navigationDestination(for: ChatFolder.self) { folder in
                return ChatListView(vm: chatListVM).task {
                    chatListVM.selectChatFolder(folder)
                }
            }
            
        }
        .overlay(alignment: .bottom) {
            if settingsVM.showConnectingToast {
                connectingToast()
            }
        }
        .overlay {
            if settingsVM.showConnectingBorder {
                connectingBorder()
            }
        }
    }
    
    @ViewBuilder
    func connectingToast() -> some View {
        HStack(spacing: 5) {
            ProgressView()
            Text("Connecting...")
        }
        .padding(10)
        .background {
            Capsule()
                .foregroundStyle(.ultraThinMaterial)
                .background {
                    Capsule()
                        .foregroundStyle(.ultraThinMaterial)
                }
        }
        .fixedSize()
        .offset(y: 20)
        .transition(
            .asymmetric(
                insertion: .push(from: .bottom),
                removal: .push(from: .top)
            )
        )
    }
    
    @ViewBuilder
    func connectingBorder() -> some View {
        RoundedRectangle(cornerRadius: 42)
            .stroke(settingsVM.connectingBorderColor, lineWidth: 5)
            .ignoresSafeArea()
    }
}

#Preview {
    return SettingsView()
        .environmentObject(LoginViewModel())
}

