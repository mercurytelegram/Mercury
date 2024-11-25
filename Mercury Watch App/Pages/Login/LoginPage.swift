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
                Text(vm.statusMessage)
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
            .sheet(
                isPresented: $vm.showTutorialView,
                content: tutorialView
            )
            .sheet(isPresented: $vm.showPasswordView) {
                passwordView()
            }
        }
        .onChange(
            of: vm.showPasswordView,
            vm.didChangeShowPasswordValue
        )
        .overlay {
            if AppState.shared.isAuthenticated == nil {
                loader()
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
            Divider()
            Text("If you can't scan the QR code:")
                .foregroundStyle(.secondary)
                .padding()
            Button("Demo", action: vm.didPressDemoButton)
        }
        .navigationTitle("Info")
        .scenePadding(.horizontal)
    }
    
    @ViewBuilder
    func passwordView() -> some View {
        PasswordView(
            password: $vm.password,
            model: vm.passwordModel,
            onSubmit: vm.validatePassword
        )
        .overlay {
            if vm.isValidatingPassword {
                loader()
            }
        }
    }
    
    @ViewBuilder
    func loader() -> some View {
        ZStack {
            Rectangle()
                .foregroundStyle(.thinMaterial)
                .ignoresSafeArea(edges: .all)
            ProgressView()
        }
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
