//
//  LoginPage.swift
//  Mercury Watch App
//
//  Created by Marco Tammaro on 02/11/24.
//

import SwiftUI

struct LoginPage: View {
    @State
    @Mockable(mockInit: LoginViewModelMock.init)
    var vm = LoginViewModel.init
    
    var body: some View {
        Text("Hello, World!")
    }
}

#Preview {
    LoginPage()
}
