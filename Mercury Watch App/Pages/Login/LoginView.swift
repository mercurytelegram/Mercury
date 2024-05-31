//
//  LoginView.swift
//  Mercury Watch App
//
//  Created by Alessandro Alberti on 23/04/24.
//

import SwiftUI
import EFQRCode
import TDLibKit

struct LoginView: View {

    @EnvironmentObject var vm: LoginViewModel
    
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
                    PasswordView(password: $vm.password) {
                        vm.validatePassword()
                    }
                }
            })
            .sheet(isPresented: $showInfo, content: {
                InfoView()
            })
        }
    }
    
    @ViewBuilder
    var qrView: some View {
        
        if  let image = vm.qrcodeImage {
            
            Image(uiImage: image)
                .resizable()
                .padding()
                .aspectRatio(1, contentMode: showFullscreenQR ? .fill : .fit)
                .clipShape(RoundedRectangle(cornerRadius: 20))
                .background{
                    RoundedRectangle(cornerRadius: 20)
                        .foregroundStyle(Color.white)
                        .ignoresSafeArea(edges: showFullscreenQR ? .all : .bottom)
                }
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
        .environmentObject(LoginViewModel())
}
