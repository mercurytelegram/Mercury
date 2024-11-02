//
//  LoginPage.swift
//  Mercury Watch App
//
//  Created by Marco Tammaro on 02/11/24.
//

import SwiftUI

struct ChatDetailPage: View {
    @State
    @Mockable(mockInit: ChatDetailViewModelMock.init)
    var vm = ChatDetailViewModel.init
    
    var body: some View {
        Text("Hello, World!")
    }
}

#Preview {
    ChatDetailPage()
}
