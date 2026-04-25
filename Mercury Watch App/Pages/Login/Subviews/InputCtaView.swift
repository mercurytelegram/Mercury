//
//  InputCtaView.swift
//  Mercury Watch App
//
//  Created by Alessandro Alberti on 2/7/25.
//

import SwiftUI

struct InputCtaModel {
    var title: String
    var iconName: String
    var iconRotationDegrees: Double = 0
    var description: String?
    var inputPlaceholder: String
    var inputIconName: String
    var tint: Color
    var keyboardType: KeyboardType
    
    enum KeyboardType: Identifiable {
        case phone, code, text
        
        var id: Self { self }
    }
}

struct InputCtaView: View {
    @State private var showKeyboard: InputCtaModel.KeyboardType? = nil
    @State private var text: String?
    
    var model: InputCtaModel
    var onSubmit: (String) -> Void
    
    var body: some View {
        ScrollView {
            Image(systemName: model.iconName)
                .resizable()
                .scaledToFit()
                .symbolVariant(.fill)
                .rotationEffect(
                    .degrees(model.iconRotationDegrees)
                )
                .frame(height: 60)
                .padding(.top, -25)
                .padding(.bottom)
                .foregroundStyle(model.tint, .white)
            
            Text(model.title)
                .font(.title3)
                .multilineTextAlignment(.center)
                .padding(.bottom)
            if model.keyboardType == .text {
                TextFieldLink(label: ctaView, onSubmit: self.onSubmit)
                .buttonStyle(.scaling)
            } else {
                Button(action: didTapOnCta) {
                    ctaView()
                }
                .buttonStyle(.scaling)
            }
            
            if let description = model.description {
                Text(description)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.top)
            }
        }
        .scenePadding(.horizontal)
        .sheet(item: $showKeyboard) { keyboardType in
            switch keyboardType {
            case .phone:
                PhoneKeypadView { phone in
                    self.showKeyboard = nil
                    self.text = phone
                    self.onSubmit(phone)
                }
            case .code:
                CodeKeypadView { code in
                    self.showKeyboard = nil
                    self.text = code
                    self.onSubmit(code)
                }
            default:
                EmptyView()
            }
        }
    }
    
    @ViewBuilder
    func ctaView() -> some View {
        HStack {
            Image(systemName: model.inputIconName)
                .foregroundStyle(model.tint)
            Text(text ?? model.inputPlaceholder)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(12)
        .background {
            RoundedRectangle(cornerRadius: 15)
                .foregroundStyle(.quaternary)
        }
    }
    
    func didTapOnCta() {
        if model.keyboardType == .text {
            WKExtension.shared()
                .visibleInterfaceController?
                .presentTextInputController(
                    withSuggestions: [],
                    allowedInputMode: .plain) { result in
                        guard let result = result as? [String],
                              let text = result.first
                        else { return }
                        
                        self.text = text
                        self.onSubmit(text)
                    }
        } else {
            self.showKeyboard = model.keyboardType
        }
    }
}

extension InputCtaModel {
    static var phone: Self {
        .init(
            title: "Enter your phone number",
            iconName: "phone",
            inputPlaceholder: "Phone",
            inputIconName: "circle.grid.3x3.circle",
            tint: .green,
            keyboardType: .phone
        )
    }
    
    static func phoneError(_ placeholder: String? = nil) -> Self {
        var model = Self.phone
        model.title = "Invalid phone number"
        model.iconName = "exclamationmark.circle.fill"
        model.tint = .red
        model.description = "The provided phone number doesn't seem to exist! Make sure to include the region prefix"
        
        if let placeholder {
            model.inputPlaceholder = placeholder
        }
        
        return model
    }
    
    static var code: Self {
        .init(
            title: "Enter the code you’ve received",
            iconName: "ellipsis.bubble",
            description: "We've sent the code to the Telegram app on your other device.",
            inputPlaceholder: "Code",
            inputIconName: "circle.grid.3x3.circle",
            tint: .blue,
            keyboardType: .code
        )
    }
    
    static func codeError(_ placeholder: String? = nil) -> Self {
        var model = Self.code
        model.title = "Wrong Code, try again!"
        model.iconName = "exclamationmark.bubble.fill"
        model.tint = .red
        
        if let placeholder {
            model.inputPlaceholder = placeholder
        }
        
        return model
    }
    
    static var password: Self {
        .init(
            title: "Enter your Telegram password",
            iconName: "key",
            iconRotationDegrees: 45,
            description: "You have Two-Step Verification enabled, so your account is protected with an additional password.",
            inputPlaceholder: "Password",
            inputIconName: "lock.fill",
            tint: .blue,
            keyboardType: .text
        )
    }
    
    static var passwordError: Self {
        var model = Self.password
        model.title = "Wrong password, try again!"
        model.iconName = "exclamationmark.circle.fill"
        model.tint = .red
        
        return model
    }
}

#Preview("Phone") {
    InputCtaView(model: .phone, onSubmit: {_ in})
}

#Preview("Phone Error") {
    InputCtaView(model: .phoneError(), onSubmit: {_ in})
}

#Preview("Code") {
    InputCtaView(model: .code, onSubmit: {_ in})
}

#Preview("Code error") {
    InputCtaView(model: .codeError(), onSubmit: {_ in})
}

#Preview("Password") {
    InputCtaView(model: .password, onSubmit: {_ in})
}
