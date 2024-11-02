//
//  LoginPage.swift
//  Mercury Watch App
//
//  Created by Marco Tammaro on 02/11/24.
//

import SwiftUI

struct SettingsPage: View {
    @State
    @Mockable(mockInit: SettingsViewModelMock.init)
    var vm = SettingsViewModel.init
    
    var body: some View {
        Text("Hello, World!")
    }
}

#Preview {
    SettingsPage()
}
