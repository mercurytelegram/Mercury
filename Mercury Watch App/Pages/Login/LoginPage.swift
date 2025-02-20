//
//  LoginPage.swift
//  Mercury Watch App
//
//  Created by Marco Tammaro on 02/11/24.
//

import SwiftUI

struct LoginPage: View {
    @State
    @Mockable(mockInit: LoginViewModelMock.init)
    var vm = LoginViewModel.init
    
    var body: some View {
        NavigationStack {
            VStack {
                QR()
                Text(vm.state == nil ? "Connecting..." : "Login with QR code")
                    .padding(.top)
                    .padding(.bottom, vm.showFullscreenQR ? 0 : -20)
            }
            .containerBackground(for: .navigation) {
                background()
            }
            .navigationTitle {
                Text("Mercury")
                    .foregroundStyle(vm.showFullscreenQR ? .white : .blue)
                    .opacity(vm.showFullscreenQR ? 0 : 1)
            }
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button(
                        "Info",
                        systemImage: "info",
                        action: vm.didPressInfoButton
                    )
                    .opacity(vm.showFullscreenQR ? 0 : 1)
                }
            }
            .sheet(isPresented: vm.showPassword) {
                InputCtaView(
                    model: vm.state == .twoFactorPasswordFailure ? .passwordError : .password,
                    onSubmit: vm.validatePassword
                )
            }
            .sheet(isPresented: vm.showLoader, content: loader)
            .sheet(isPresented: vm.showTutorial, content: tutorialView)
            .sheet(isPresented: vm.showPhoneNumber) {
                InputCtaView(
                    model: vm.state == .phoneNumberLoginFailure ? .phoneError : .phone,
                    onSubmit: vm.setPhoneNumber
                )
            }
            .sheet(isPresented: vm.showCode) {
                InputCtaView(
                    model: vm.state == .authCodeFailure ? .codeError : .code,
                    onSubmit: vm.validateAuthCode
                )
            }
        }
    }
    
    @ViewBuilder
    func QR() -> some View {
        QRCodeView(text: vm.qrCodeLink) {
            ProgressView()
        }
        .aspectRatio(
            vm.showFullscreenQR ? 0.75 : 1,
            contentMode: vm.showFullscreenQR ? .fill : .fit
        )
        .ignoresSafeArea(edges: vm.showFullscreenQR ? .all : .bottom)
        .padding(.top)
        .onTapGesture(perform: vm.didPressQR)
    }
    
    @ViewBuilder
    func tutorialView() -> some View {
        ScrollView {
            StepView(steps: vm.tutorialSteps)
            TextDivider("or")
            Text("if you can’t scan the QR code login with phone number")
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
                .padding()
            Button("Login", action: vm.didPressLoginButton)
        }
        .navigationTitle("Info")
        .scenePadding(.horizontal)
    }
    
    @ViewBuilder
    func loader() -> some View {
        ZStack {
            Rectangle()
                .foregroundStyle(.thinMaterial)
                .ignoresSafeArea(edges: .all)
            ProgressView()
        }
        // Loader should not be dismissable
        .toolbar(.hidden, for: .navigationBar)
    }
    
    @ViewBuilder
    func background() -> some View {
        
        let gradient = Gradient(
            colors: [
                .bgBlue,
                .bgBlue.opacity(0.2)
            ]
        )
        
        Rectangle()
            .foregroundStyle(gradient)
    }
    
}

#Preview(traits: .mock()) {
    LoginPage()
}
