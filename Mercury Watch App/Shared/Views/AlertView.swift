//
//  AlertView.swift
//  Mercury Watch App
//
//  Created by Alessandro Alberti on 06/07/24.
//

import SwiftUI

struct AlertView: View {
    var symbolSystemName: String
    var symbolColor: Color = .white
    var title: String
    var description: String = ""
    
    var body: some View {
        ScrollView {
            Image(systemName: symbolSystemName)
                .resizable()
                .scaledToFit()
                .foregroundStyle(symbolColor)
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
        }
        .scenePadding(.horizontal)
    }
    
    static func inDevelopment(_ feature: String = "this feature is") -> AlertView {
        AlertView(
            symbolSystemName: "hammer",
            symbolColor: .blue,
            title: "In Development",
            description: "Sorry, \(feature) currently under development"
        )
    }
}

#Preview("Generic Alert") {
    Spacer()
        .sheet(isPresented: .constant(true), content: {
            AlertView(
                symbolSystemName: "exclamationmark.triangle",
                symbolColor: .yellow,
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
