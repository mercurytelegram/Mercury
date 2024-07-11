//
//  AccountDetailView.swift
//  Mercury Watch App
//
//  Created by Alessandro Alberti on 09/07/24.
//

import SwiftUI

struct AccountDetailView: View {
    @EnvironmentObject var loginVM: LoginViewModel
    
    var body: some View {
        VStack {
            Text("This section is currently under development")
                .font(.footnote)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.bottom)
            Button("Logout", role: .destructive) {
                loginVM.logout()
            }
        }
    }
}

#Preview {
    AccountDetailView()
        .environmentObject(LoginViewModel())
}
