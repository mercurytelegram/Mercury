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
            accountsSection()
                .padding(.horizontal)
                .padding(.top, 4)
            appInfo()
                .padding(.horizontal)
                .padding(.top, 4)
            settingsLinks()
                .padding(.horizontal)
                .padding(.top, 4)
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
    func appInfo() -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Label("Version", systemImage: "info.circle")
                Spacer()
                Text(vm.appVersion)
                    .foregroundStyle(.secondary)
            }
            
            HStack {
                Label("Telegram", systemImage: "paperplane.circle")
                Spacer()
                Text(vm.telegramSessionStatus)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.trailing)
            }
        }
        .font(.footnote)
    }
    
    @ViewBuilder
    func accountsSection() -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Accounts")
                .font(.headline)
            
            ForEach(vm.accounts) { account in
                Button {
                    vm.switchAccount(to: account)
                } label: {
                    HStack {
                        Image(systemName: account.id == vm.activeAccountId ? "checkmark.circle.fill" : "person.circle")
                            .foregroundStyle(account.id == vm.activeAccountId ? .green : .secondary)
                        VStack(alignment: .leading, spacing: 2) {
                            Text(account.title)
                                .font(.footnote)
                                .fontWeight(.semibold)
                            Text(account.subtitle)
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                        }
                        Spacer()
                    }
                }
                .disabled(account.id == vm.activeAccountId)
            }
            
            Button {
                vm.addAccount()
            } label: {
                Label("Add Account", systemImage: "plus.circle")
            }
        }
    }
    
    @ViewBuilder
    func settingsLinks() -> some View {
        VStack(spacing: 8) {
            NavigationLink {
                StorageUsagePage()
            } label: {
                Label("Storage Usage", systemImage: "internaldrive")
            }
            
            NavigationLink {
                QuickRepliesSettingsPage(vm: vm)
            } label: {
                Label("Quick Replies", systemImage: "text.bubble")
            }
        }
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
