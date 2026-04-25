//
//  AlertView.swift
//  Mercury Watch App
//
//  Created by Alessandro Alberti on 06/07/24.
//

import SwiftUI

struct AlertView: View {
    var symbolSystemName: String
    var tint: Color = .white
    var title: String
    var description: LocalizedStringKey = ""
    var ctaTitle: String?
    var onCtaTap: (() -> Void)?
    
    var body: some View {
        ScrollView {
            Image(systemName: symbolSystemName)
                .resizable()
                .scaledToFit()
                .foregroundStyle(tint)
                .symbolVariant(.fill)
                .frame(height: 60)
                .padding(.bottom)
            
            Text(title)
                .font(.title3)
                .fontWeight(.semibold)
                .multilineTextAlignment(.center)
                .padding(.bottom)
            
            Text(description)
                .font(.footnote)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
            
            if let ctaTitle {
                Button(ctaTitle){
                    onCtaTap?()
                }
                .tint(tint)
                .padding(.top)
            }
        }
        .scenePadding(.horizontal)
    }
    
    static func inDevelopment(_ feature: String = "this feature is") -> AlertView {
        AlertView(
            symbolSystemName: "hammer",
            tint: .blue,
            title: "In Development",
            description: "Sorry, \(feature) currently under development"
        )
    }
    
    static func termsOfService(_ completion: @escaping () -> Void) -> AlertView {
        AlertView(
            symbolSystemName: "person.2.shield",
            tint: .blue,
            title: "Terms of Service",
            description: """
                By using this app, you agree to not share any harmful, dangerous, or abusive content.
                
                All other conditions are governed by [Telegram’s Terms of Service](https://telegram.org/tos).
                """,
            ctaTitle: "I agree",
            onCtaTap: completion
        )
    }
}

#Preview("Terms of Service") {
    Spacer()
        .sheet(isPresented: .constant(true), content: {
            AlertView.termsOfService { }
                .toolbar(.hidden, for: .navigationBar)
        })
}

#Preview("Generic Alert") {
    Spacer()
        .sheet(isPresented: .constant(true), content: {
            AlertView(
                symbolSystemName: "exclamationmark.triangle",
                tint: .yellow,
                title: "Alert",
                description: "Description"
            )
        })
}

#Preview("inDevelopment") {
    Spacer()
        .sheet(isPresented: .constant(true), content: {
            AlertView.inDevelopment("audio recording is")
        })
}
