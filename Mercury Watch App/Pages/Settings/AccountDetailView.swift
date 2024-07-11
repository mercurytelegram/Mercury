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
            Button("Logout", role: .destructive) {
                loginVM.logout()
            }
            Text("This section is currently under development")
                .font(.footnote)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.bottom)
        }
    }
}

#Preview {
    AccountDetailView()
        .environmentObject(LoginViewModel())
}
