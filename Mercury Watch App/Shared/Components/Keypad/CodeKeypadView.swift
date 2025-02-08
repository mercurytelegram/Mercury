//
//  CodeKeypadView.swift
//  Mercury Watch App
//
//  Created by Alessandro Alberti on 25/04/24.
//

import SwiftUI

struct CodeKeypadView: View {
    @State var code = ""
    var onSubmit: (String) -> Void
    
    var body: some View {
        VStack {
            HStack {
                ForEach(0...4, id: \.self) { index in
                    RoundedRectangle(cornerRadius: 10)
                        .frame(height: 30)
                        .foregroundStyle(.tertiary)
                        .overlay {
                            if code.count > index {
                                Text("\(code[code.index(code.startIndex, offsetBy: index)])")
                                    .transition(
                                        .move(edge: .bottom)
                                        .combined(with: .opacity)
                                    )
                                    
                            }
                        }
                        .clipped()
                }
            }
            KeypadView(value: $code, maxLenght: 5)
                .edgesIgnoringSafeArea(.bottom)
        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Confirm", systemImage: "checkmark") {
                    self.onSubmit(code)
                }
                    .foregroundStyle(.white, .blue)
            }
        }
    }
}

#Preview {
    NavigationStack {
        CodeKeypadView { code in
            print(code)
        }
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Back", systemImage: "xmark") {}
                }
            }
            .containerBackground(.blue.gradient, for: .navigation)
    }
}
