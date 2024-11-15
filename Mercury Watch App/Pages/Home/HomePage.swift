//
//  LoginPage.swift
//  Mercury Watch App
//
//  Created by Marco Tammaro on 02/11/24.
//

import SwiftUI

struct HomePage: View {
    
    @State
    @Mockable(mockInit: HomeViewModelMock.init)
    var vm = HomeViewModel.init
    
    var body: some View {
        NavigationStack(path: $vm.navigationPath) {
            List {
                NavigationLink {
                    SettingsPage()
                } label: {
                    UserCellView(model: vm.userCellModel)
                }
                
                Section {
                    ForEach(AppState.shared.folders, id: \.self) { folder in
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
                return ChatListPage(folder: folder)
            }
            .navigationDestination(for: ChatCellModel.self) { chat in
                if let id = chat.id {
                    ChatDetailPage(chatId: id)
                }
            }
        }
    }
}


#Preview {
    HomePage()
}
