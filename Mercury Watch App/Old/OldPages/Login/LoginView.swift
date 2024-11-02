//
//  LoginView.swift
//  Mercury Watch App
//
//  Created by Alessandro Alberti on 23/04/24.
//

import SwiftUI
import TDLibKit
import QRCode

struct LoginView: View {

    @EnvironmentObject var vm: LoginViewModel_Old
    
    @State var showInfo = false
    @State var showFullscreenQR = false
    
    var body: some View {
        NavigationStack {
            VStack {
                qrView
                Text(vm.statusMessage)
                    .padding(.top)
                    .padding(.bottom, -10)
                
            }
            .containerBackground(.blue.gradient, for: .navigation)
            .navigationTitle {
                Text("Mercury")
                    .foregroundStyle(showFullscreenQR ? .white : .blue)
                    .opacity(showFullscreenQR ? 0 : 1)
            }
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Info", systemImage: "info") {
                        showInfo.toggle()
                    }
                    .opacity(showFullscreenQR ? 0 : 1)
                }
            }
            .sheet(isPresented: $vm.showPassword, content: {
                if vm.isValidatingPassword {
                    ProgressView()
                } else {
                    PasswordView(password: $vm.password, showError: vm.passwordValidationFailed) {
                        vm.validatePassword()
                    }
                }
            })
            .sheet(isPresented: $showInfo, content: {
                InfoView()
            })
            .onChange(of: vm.showPassword) {
                if vm.showPassword == false {
                    // User dismissed password view
                    vm.logout()
                }
            }
        }
    }
    
    @ViewBuilder
    var qrView: some View {
        
        if let link = vm.qrcodeLink, let shape = try? QRCodeShape(
            text: link,
            errorCorrection: .low
        ) {
            
            ZStack {
                RoundedRectangle(cornerRadius: 20)
                    .fill(.white)
                    
                shape
                .eyeShape(QRCode.EyeShape.Squircle())
                .pupilShape(QRCode.PupilShape.Squircle())
                .padding()
                .blendMode(.destinationOut)
            }
            .compositingGroup()
            .aspectRatio(showFullscreenQR ? 0.75 : 1, contentMode: showFullscreenQR ? .fill : .fit)
            .ignoresSafeArea(edges: showFullscreenQR ? .all : .bottom)
            .padding(.top)
            .onTapGesture {
                withAnimation(.bouncy) {
                    showFullscreenQR.toggle()
                }
            }
            
        } else {
            ProgressView()
        }
    }
    
}

#Preview {
    LoginView()
        .environmentObject(LoginViewModel_Old())
}
