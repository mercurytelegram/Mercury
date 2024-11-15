//
//  AccountDetailView.swift
//  Mercury Watch App
//
//  Created by Alessandro Alberti on 09/07/24.
//

import SwiftUI

struct AccountDetailView_Old: View {
    @EnvironmentObject var loginVM: LoginViewModel_Old
    @ObservedObject var vm: SettingsViewModel_Old
    
    var body: some View {
        ScrollView {
            avatarHeader()
            Spacer()
            Button("Logout", role: .destructive) {
                loginVM.logout()
            }
            credits()
                .padding(.top)
        }
    }
    
    func avatarHeader() -> some View {
        ZStack {
            Image(uiImage: vm.profileThimbnail())
                .resizable()
                .frame(height: 120)
                .clipShape(Ellipse())
                .blur(radius: 30)
                .opacity(0.8)
            
            VStack {
                AvatarView_Old(model: AvatarModel_Old(tdImage: vm.profileTDImage()))
                    .frame(width: 50, height: 50)
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
    
    func credits() -> some View {
        VStack {
            HStack {
                Rectangle()
                    .frame(height: 1)
                    .foregroundStyle(.secondary)
                Text("by")
                Rectangle()
                    .frame(height: 1)
                    .foregroundStyle(.secondary)
            }
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

#Preview {
    AccountDetailView_Old(vm: MockSettingsViewModel())
        .environmentObject(LoginViewModel_Old())
}
