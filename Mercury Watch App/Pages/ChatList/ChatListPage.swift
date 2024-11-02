//
//  LoginPage.swift
//  Mercury Watch App
//
//  Created by Marco Tammaro on 02/11/24.
//

import SwiftUI

struct ChatListPage: View {
    @State
    @Mockable(mockInit: ChatListViewModelMock.init)
    var vm = ChatListViewModel.init
    
    var body: some View {
        Text("Hello, World!")
    }
}

#Preview {
    ChatListPage()
}
