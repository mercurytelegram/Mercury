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
        List {
            profileSection()
                .listRowInsets(EdgeInsets(top: 8, leading: 8, bottom: 8, trailing: 8))
                .listRowBackground(Color.clear)
            
            accountsSection()
            
            Section("Tools") {
                NavigationLink {
                    StorageUsagePage()
                } label: {
                    SettingsNavigationRow(
                        title: "Storage",
                        subtitle: "Media cache and files",
                        systemImage: "internaldrive",
                        tint: .orange
                    )
                }
                
                NavigationLink {
                    QuickRepliesSettingsPage(vm: vm)
                } label: {
                    SettingsNavigationRow(
                        title: "Quick Replies",
                        subtitle: "\(vm.quickReplyTemplates.count) templates",
                        systemImage: "text.bubble",
                        tint: .green
                    )
                }
            }
            
            Section("App") {
                SettingsValueRow(
                    title: "Version",
                    value: vm.appVersion,
                    systemImage: "info.circle",
                    tint: .secondary
                )
                
                credits()
                    .listRowInsets(EdgeInsets(top: 8, leading: 8, bottom: 8, trailing: 8))
            }
            
            Section {
                Button(role: .destructive) {
                    vm.logout()
                } label: {
                    SettingsNavigationRow(
                        title: "Logout",
                        subtitle: nil,
                        systemImage: "rectangle.portrait.and.arrow.right",
                        tint: .red
                    )
                }
            }
        }
        .listStyle(.carousel)
        .navigationTitle("Settings")
    }
    
    @ViewBuilder
    func profileSection() -> some View {
        ZStack {
            if let thumbnail = vm.user?.thumbnail {
                Image(uiImage: thumbnail)
                    .resizable()
                    .scaledToFill()
                    .frame(height: 116)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .blur(radius: 24)
                    .opacity(0.55)
            }
            
            VStack(spacing: 5) {
                
                if let avatar = vm.user?.avatar {
                    AvatarView(model: avatar)
                        .frame(width: 56, height: 56)
                }
                
                Text(vm.user?.fullName ?? "Telegram")
                    .fontDesign(.rounded)
                    .fontWeight(.semibold)
                    .lineLimit(1)
                
                if let username = vm.user?.mainUserName, !username.isEmpty {
                    Text(username)
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }
                
                if let phoneNumber = vm.user?.phoneNumber, !phoneNumber.isEmpty {
                    Text(phoneNumber)
                        .font(.caption2)
                        .foregroundStyle(.tertiary)
                        .lineLimit(1)
                }
            }
            .padding(.vertical, 10)
            .frame(maxWidth: .infinity)
        }
    }
    
    @ViewBuilder
    func accountsSection() -> some View {
        Section("Accounts") {
            ForEach(vm.accounts) { account in
                Button {
                    vm.switchAccount(to: account)
                } label: {
                    AccountSettingsRow(
                        account: account,
                        isActive: account.id == vm.activeAccountId
                    )
                }
                .disabled(account.id == vm.activeAccountId)
            }
            
            Button {
                vm.addAccount()
            } label: {
                SettingsNavigationRow(
                    title: "Add Account",
                    subtitle: nil,
                    systemImage: "plus.circle",
                    tint: .blue
                )
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
    }
    
    @ViewBuilder
    func creditsAvatar(name: String, image: String) -> some View {
        VStack {
            Image(image)
                .resizable()
                .frame(width: 50, height: 50)
                .clipShape(Circle())
            Text(name)
                .font(.caption2)
                .multilineTextAlignment(.center)
        }
    }
}

private struct AccountSettingsRow: View {
    let account: TelegramAccount
    let isActive: Bool
    
    var body: some View {
        HStack(spacing: 10) {
            SettingsIcon(
                systemImage: isActive ? "checkmark.circle.fill" : "person.circle",
                tint: isActive ? .green : .secondary
            )
            
            VStack(alignment: .leading, spacing: 2) {
                Text(account.title)
                    .font(.footnote)
                    .fontWeight(.semibold)
                    .lineLimit(1)
                
                Text(isActive ? "Current account" : account.subtitle)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }
            
            Spacer(minLength: 0)
        }
    }
}

private struct SettingsNavigationRow: View {
    let title: String
    let subtitle: String?
    let systemImage: String
    let tint: Color
    
    var body: some View {
        HStack(spacing: 10) {
            SettingsIcon(systemImage: systemImage, tint: tint)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.footnote)
                    .fontWeight(.semibold)
                    .lineLimit(1)
                
                if let subtitle {
                    Text(subtitle)
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }
            }
        }
    }
}

private struct SettingsValueRow: View {
    let title: String
    let value: String
    let systemImage: String
    let tint: Color
    
    var body: some View {
        HStack(spacing: 10) {
            SettingsIcon(systemImage: systemImage, tint: tint)
            
            Text(title)
                .font(.footnote)
                .fontWeight(.semibold)
            
            Spacer(minLength: 4)
            
            Text(value)
                .font(.caption2)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.trailing)
                .lineLimit(2)
        }
    }
}

private struct SettingsIcon: View {
    let systemImage: String
    let tint: Color
    
    var body: some View {
        Image(systemName: systemImage)
            .font(.system(size: 15, weight: .semibold))
            .foregroundStyle(tint)
            .frame(width: 22, height: 22)
    }
}

#Preview(traits: .mock()) {
    NavigationStack {
        SettingsPage()
    }
}
