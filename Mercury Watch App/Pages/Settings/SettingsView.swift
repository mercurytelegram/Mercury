//
//  SettingsView.swift
//  Mercury Watch App
//
//  Created by Alessandro Alberti on 19/06/24.
//

import SwiftUI
import TDLibKit

struct SettingsView: View {
    @State private var navStack: [ChatFolder] = [.main]
    @EnvironmentObject var loginVM: LoginViewModel
    @StateObject var chatListVM = ChatListViewModel()
    
    var body: some View {
        NavigationStack(path: $navStack) {
            List {
                NavigationLink("Account") {
                    Button("Logout", role: .destructive) {
                        loginVM.logout()
                    }
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
    
    enum destinations {
       case account, all, folder
    }
}

#Preview {
    let vm = LoginViewModel()
    vm.useMock = true
    
    return SettingsView()
        .environmentObject(vm)
}

