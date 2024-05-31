//
//  InfoView.swift
//  Mercury Watch App
//
//  Created by Alessandro Alberti on 23/04/24.
//

import SwiftUI

struct InfoView: View {
    @EnvironmentObject var vm: LoginViewModel
    
    var steps = [
        "Open Telegram on your phone",
        "Go to Settings → Devices → Link Desktop Device",
        "Point your phone at the QR code to confirm login"
    ]
    
    var body: some View {
        NavigationStack {
            ScrollView {
                ForEach(steps.indices, id: \.self) { index in
                    infoCell(number: index + 1, text: steps[index])
                        .padding(.vertical)
                }
                Divider()
                Text("If you can't scan the QR code:")
                    .foregroundStyle(.secondary)
                    .padding()
                Button("Demo"){
                    vm.useMock = true
                }
            }
            .scenePadding(.horizontal)
            .navigationTitle("Info")
        }
        
    }
    
    func infoCell(number: Int, text: String) -> some View {
        HStack {
            Image(systemName: "\(number).circle.fill")
                .font(.title)
            .foregroundStyle(.white, .blue)
            Text(text)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

#Preview {
    InfoView()
}
