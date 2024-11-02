//
//  PasswordView.swift
//  Mercury Watch App
//
//  Created by Alessandro Alberti on 2/11/24.
//

import SwiftUI

struct PasswordView: View {
    @Binding var password: String
    let model: PasswordModel
    var onSubmit : () -> () = {}
    
    var body: some View {
        ScrollView {
            Image(systemName: model.iconName)
                .resizable()
                .scaledToFit()
                .frame(height: 60)
                .rotationEffect(.degrees(45))
                .padding(.top, -25)
            
            Text(model.title)
                .font(.title3)
                .multilineTextAlignment(.center)
                .padding(.bottom)
                
            SecureField("\(Image(systemName: "lock.fill")) Password", text: $password, onCommit: onSubmit)
                .clipShape(RoundedRectangle(cornerRadius: 15))
                .clipped()
                .if(model.style == .error, transform: { view in
                    view.overlay {
                        RoundedRectangle(cornerRadius: 15).stroke(.red)
                    }
                })
                .padding(.horizontal, 1)
            
            Text(model.description)
                .font(.footnote)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.top)
        }
        .scenePadding(.horizontal)
    }
}

struct PasswordModel {
    var title: String
    var iconName: String
    var description: String
    var style: Style
    
    enum Style {
        case plain, error
    }
}

extension PasswordModel {
    static var plain: Self {
        .init(
            title: "Insert your Telegram Password",
            iconName: "key.fill",
            description: "You have Two-Step Verification enabled, so your account is protected with an additional password.",
            style: .plain
        )
    }
    
    static var error: Self {
        .init(
            title: "Wrong password, try again!",
            iconName: "key.fill",
            description: "You have Two-Step Verification enabled, so your account is protected with an additional password.",
            style: .error
        )
    }
}

#Preview("Plain") {
    PasswordView(password: .constant(""), model: .plain) {
        print("commit")
    }
}

#Preview("Error") {
    PasswordView(password: .constant(""), model: .error) {
        print("commit")
    }
}
