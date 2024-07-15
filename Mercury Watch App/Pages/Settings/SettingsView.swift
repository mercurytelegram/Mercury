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
                    chatListVM.selectChat(folder)
                }
            }
        }
    }
}

#Preview {
    return SettingsView()
        .environmentObject(LoginViewModel())
}

