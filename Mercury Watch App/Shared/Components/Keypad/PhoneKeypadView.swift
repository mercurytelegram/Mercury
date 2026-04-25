//
//  PhoneKeypadView.swift
//  Mercury Watch App
//
//  Created by Alessandro Alberti on 24/04/24.
//

import SwiftUI

struct PhoneKeypadView: View {
    @State var phoneNumber = ""
    var onSubmit: (String) -> Void
    
    var body: some View {
        VStack(alignment: .trailing) {
            HStack {
                Image(systemName: "plus")
                    .font(.title3)
                    .padding(.leading)
                Text(phoneNumber)
                    .font(.title3)
                    .padding(.leading)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .frame(height: 30)
                            .foregroundStyle(.tertiary)
                    )
                    .contentTransition(.numericText(value: Double(phoneNumber) ?? 0))
            }
            .frame(height: 30)
            KeypadView(value: $phoneNumber, maxLenght: 15)
                .edgesIgnoringSafeArea(.bottom)
        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Confirm", systemImage: "checkmark") {
                    self.onSubmit(phoneNumber)
                }
                    .foregroundStyle(.white, .blue)
            }
        }
    }
}

#Preview {
    NavigationStack {
        PhoneKeypadView { number in
            print(number)
        }
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Back", systemImage: "xmark") {}
                }
            }
            .containerBackground(.blue.gradient, for: .navigation)
    }
    
}
