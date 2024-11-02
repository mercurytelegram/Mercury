//
//  QRCodeView.swift
//  Mercury Watch App
//
//  Created by Alessandro Alberti on 2/11/24.
//

import SwiftUI
import QRCode


struct QRCodeView<Content: View>: View {
    private var shape: QRCodeShape?
    let placeholder: Content
    let color: Color?
    
    init(
        text: String?,
        color: Color? = nil,
        placeholder: @escaping () -> Content = { EmptyView() }
    ) {
        self.placeholder = placeholder()
        self.color = color
        self.shape = nil
        
        guard let text else { return }
        shape = try? QRCodeShape(
            text: text,
            errorCorrection: .low
        )
    }
    
    var body: some View {
        if let shape {
            ZStack {
                RoundedRectangle(cornerRadius: 20)
                    .fill(.white)
                shape
                .eyeShape(QRCode.EyeShape.Squircle())
                .pupilShape(QRCode.PupilShape.Squircle())
                .padding()
                .if(color != nil) { view in
                    view.foregroundStyle(color!)
                }
                .if(color == nil) { view in
                    view.blendMode(.destinationOut)
                }
            }
            .compositingGroup()
        } else {
            placeholder
        }
    }
}

#Preview("Transparent") {
    QRCodeView(text: "Hello World")
        .aspectRatio(contentMode: .fit)
        .padding()
        .background {
            Color.blue.opacity(0.5)
        }
}

#Preview("Colored") {
    QRCodeView(text: "Hello World", color: .orange)
        .aspectRatio(contentMode: .fit)
}

#Preview("Placeholder") {
    QRCodeView(text: nil) {
        Text("Placeholder")
    }
    .aspectRatio(contentMode: .fit)
}
