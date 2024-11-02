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
        Text("Hello, World!")
    }
}

#Preview {
    HomePage()
}
