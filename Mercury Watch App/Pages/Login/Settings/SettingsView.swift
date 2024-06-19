//
//  SettingsView.swift
//  Mercury Watch App
//
//  Created by Alessandro Alberti on 19/06/24.
//

import SwiftUI
import UIKit

struct SettingsView: View {
    @State private var navStack: [String] = ["All Chats"]
    @State private var folders = ["All Chats", "Archived"]
    @EnvironmentObject var loginVM: LoginViewModel
    @State var chatListVM = ChatListViewModel()
    
    var body: some View {
        NavigationStack(path: $navStack) {
            List {
                ForEach(folders, id: \.self) { folder in
                    NavigationLink(value: folder) {
                        Label {
                            Text(folder)
                        } icon: {
                            Image(systemName: "folder")
                                .foregroundStyle(.blue)
                        }
                    }
                }
            }
            .listStyle(.carousel)
            .navigationTitle("Mercury")
            .navigationDestination(for: String.self) { folder in
                chatListVM.folder = folder
                return ChatListView(vm: chatListVM)
            }
        }
        .onAppear {
            if loginVM.useMock {
                chatListVM = MockChatListViewModel()
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

