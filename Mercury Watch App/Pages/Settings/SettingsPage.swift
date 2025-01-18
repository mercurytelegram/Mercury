//
//  LoginPage.swift
//  Mercury Watch App
//
//  Created by Marco Tammaro on 02/11/24.
//

import SwiftUI

struct SettingsPage: View {
    
    @State
    @Mockable(mockInit: SettingsViewModelMock.init)
    var vm = SettingsViewModel.init
    
    var body: some View {
        ScrollView {
            avatarHeader()
            Spacer()
            Button("Logout", role: .destructive) {
                vm.logout()
            }
            credits()
                .padding(.top)
        }
    }
    
    @ViewBuilder
    func avatarHeader() -> some View {
        ZStack {
            Image(uiImage: vm.user?.thumbnail ?? UIImage())
            .resizable()
            .frame(height: 120)
            .clipShape(Ellipse())
            .blur(radius: 30)
            .opacity(0.8)
            
            VStack {
                
                if let avatar = vm.user?.avatar {
                    AvatarView(model: avatar)
                        .frame(width: 50, height: 50)
                }
                
                Text(vm.user?.fullName ?? "")
                    .fontDesign(.rounded)
                    .fontWeight(.semibold)
                Text(vm.user?.mainUserName ?? "")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                Text(vm.user?.phoneNumber ?? "")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
        }
        .frame(height: 120)
    }
    
    @ViewBuilder
    func credits() -> some View {
        VStack {
            TextDivider("by")
            HStack {
                creditsAvatar(
                    name: "Alessandro\nAlberti",
                    image: "alessandro"
                )
                Spacer()
                creditsAvatar(
                    name: "Marco\nTammaro",
                    image: "marco"
                )
            }
        }
        .padding(.horizontal)
    }
    
    @ViewBuilder
    func creditsAvatar(name: String, image: String) -> some View {
        VStack {
            Image(image)
                .resizable()
                .frame(width: 50, height: 50)
                .clipShape(Circle())
            Text(name)
                .multilineTextAlignment(.center)
        }
    }
}

#Preview(traits: .mock()) {
    SettingsPage()
}
