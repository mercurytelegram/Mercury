//
//  PasswordView.swift
//  Mercury Watch App
//
//  Created by Alessandro Alberti on 23/04/24.
//

import SwiftUI

struct PasswordView: View {
    @Binding var password: String
    let showError: Bool
    var onCommit : () -> ()
    
    var body: some View {
        ScrollView {
            Image(systemName: "key.fill")
                .resizable()
                .scaledToFit()
                .frame(height: 60)
                .rotationEffect(.degrees(45))
                .padding(.top, -25)
            
            Text(showError ? "Wrong password, try again" : "Insert your Telegram Password")
                .font(.title3)
                .multilineTextAlignment(.center)
                .padding(.bottom)
                
            SecureField("\(Image(systemName: "lock.fill")) Password", text: $password, onCommit: onCommit)
            
            Text("You have Two-Step Verification enabled, so your account is protected with an additional password.")
                .font(.footnote)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.top)
        }
        .scenePadding(.horizontal)
    }
}

#Preview {
    PasswordView(password: .constant(""), showError: false, onCommit: {})
}

#Preview("With Error") {
    PasswordView(password: .constant(""), showError: true, onCommit: {})
}
