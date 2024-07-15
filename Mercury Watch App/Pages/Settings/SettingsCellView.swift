//
//  SettingsCellView.swift
//  Mercury Watch App
//
//  Created by Alessandro Alberti on 15/07/24.
//

import SwiftUI

struct SettingsCellView: View {
    var text: String
    var iconName: String
    var color: Color
    
    var body: some View {
        HStack {
            ZStack {
                RoundedRectangle(cornerRadius: 5)
                    .frame(width: 30, height: 30)
                    .foregroundStyle(color)
                Image(systemName: iconName)
                    .symbolVariant(.fill)
            }
            .padding(.trailing)
            
            Text(text)
        }
    }
}

#Preview {
    List {
        SettingsCellView(text: "Account", iconName: "person", color: .green)
        SettingsCellView(text: "Appearance", iconName: "sun.max", color: .orange)
    }
}
