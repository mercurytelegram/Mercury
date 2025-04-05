//
//  PillView.swift
//  Mercury Watch App
//
//  Created by Alessandro Alberti on 30/08/24.
//

import SwiftUI

struct PillView: View {
    var title: String? = nil
    let description: String
    
    var body: some View {
        VStack {
            Group {
                if let title {
                    Text(title)
                        .bold()
                }
                Text(LocalizedStringKey(description))
            }
            .multilineTextAlignment(.center)
            .font(.footnote)
        }
        .padding()
        .padding(.horizontal)
        .background {
            RoundedRectangle(cornerRadius: 30)
                .foregroundStyle(.ultraThinMaterial)
        }
    }
}

#Preview {
    ScrollView {
        PillView(
            title: "Title",
            description: "Description"
        )
        
        PillView(
            title: "Alessandro",
            description: "changed the group name to _test_"
        )
        
        PillView(description: "Yesterday")
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(.blue.opacity(0.3))
}


