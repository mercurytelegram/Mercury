//
//  SettingsView.swift
//  Mercury Watch App
//
//  Created by Marco Tammaro on 24/05/24.
//

import SwiftUI

struct SettingsView: View {
    
    @EnvironmentObject var loginVM: LoginViewModel
    @Binding var isPresented: Bool
    
    var body: some View {
        NavigationStack {
            ScrollView {
                Button("Logout") {
                    loginVM.logout()
                    isPresented = false
                }
            }
            .scenePadding(.horizontal)
            .navigationTitle("Settings")
        }
    }
}

#Preview {
    SettingsView(isPresented: .constant(true))
}
