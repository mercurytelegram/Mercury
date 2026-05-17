//
//  ProfileDetail.swift
//  Mercury
//
//  Created by Marco Tammaro on 08/02/26.
//

import SwiftUI

enum ProfileDetailPageType: Hashable {
    case savedMessages
    case user(userId: Int64)
    case basicGroup(groupId: Int64, chatId: Int64)
    case superGroup(groupId: Int64, chatId: Int64)
}

struct ProfileDetailPage: View {
    
    @State
    @Mockable
    var vm: ProfileDetailViewModel
    @State private var profileTypeToOpen: ProfileDetailPageType?
    @State private var chatIdToOpen: Int64?
    
    @Environment(\.dismiss) private var dismiss
    private let showsNavigationStack: Bool

    
    init(type: ProfileDetailPageType, showsNavigationStack: Bool = true) {
        self.showsNavigationStack = showsNavigationStack
        _vm = Mockable.state(
            value: { ProfileDetailViewModel(type: type) },
            mock: { ProfileDetailViewModelMock() }
        )
    }
    
    var body: some View {
        if showsNavigationStack {
            NavigationStack {
                routedContent()
            }
        } else {
            routedContent()
        }
    }
    
    @ViewBuilder
    private func routedContent() -> some View {
        content()
            .navigationDestination(
                isPresented: Binding(
                    get: { profileTypeToOpen != nil },
                    set: { if !$0 { profileTypeToOpen = nil } }
                )
            ) {
                if let profileTypeToOpen {
                    ProfileDetailPage(type: profileTypeToOpen, showsNavigationStack: false)
                }
            }
            .navigationDestination(
                isPresented: Binding(
                    get: { chatIdToOpen != nil },
                    set: { if !$0 { chatIdToOpen = nil } }
                )
            ) {
                if let chatIdToOpen {
                    ChatRouterPage(chatId: chatIdToOpen, messageThreadId: nil)
                }
            }
    }
    
    @ViewBuilder
    private func content() -> some View {
        
        GeometryReader { geo in
            ZStack {
                backgroundImage()
                    .frame(width: geo.size.width, height: geo.size.height)
                    .clipped()
                
                ScrollView {
                    
                    VStack(alignment: .leading) {
                        if let title = vm.title {
                            Text(title)
                                .font(.title2)
                                .fontDesign(.rounded)
                                .fontWeight(.semibold)
                        }
                        if let subtitle = vm.subtitle {
                            Text(subtitle)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .safeAreaPadding([.bottom, .leading])
                    .padding(.bottom, 20)
                    .frame(width: geo.size.width, alignment: .leading)
                    .frame(height: geo.size.height, alignment: .bottom)
                    
                    bottomView()
                        .padding(.bottom)
                }
            }
        }
        .ignoresSafeArea()
    }
    
    @ViewBuilder
    private func backgroundImage() -> some View {
        
        if let avatarModel = vm.avatarModel {
            
            AvatarView(model: avatarModel)
                .scaledToFill()
                .overlay {
                    Rectangle()
                        .foregroundStyle(Gradient(colors: [.clear, .clear, .black]))
                }
                .ignoresSafeArea()
        }
    }
    
    @ViewBuilder
    private func bottomView() -> some View {
        VStack(spacing: 10) {
            if !vm.infoRows.isEmpty {
                profileSection {
                    ForEach(vm.infoRows) { row in
                        infoRow(row)
                    }
                }
            }
            
            if vm.canMessageUser {
                profileSection {
                    messageButton()
                }
            }
            
            if vm.canJoinChat {
                profileSection {
                    joinButton()
                }
            }
            
            if vm.isLoadingMembers {
                profileSection {
                    ProgressView()
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 4)
                }
            } else if !vm.members.isEmpty {
                profileSection {
                    membersView()
                }
            }

            if vm.isBlockEnabled {
                profileSection {
                    blockButton()
                }
            }
        }
        .safeAreaPadding(.horizontal)
    }
    
    @ViewBuilder
    private func profileSection<Content: View>(
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            content()
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background {
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .fill(.regularMaterial)
        }
        .overlay {
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .stroke(.white.opacity(0.12), lineWidth: 1)
        }
    }
    
    @ViewBuilder
    private func infoRow(_ row: ProfileInfoRow) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(row.title)
                .font(.caption2)
                .foregroundStyle(.secondary)
            Text(row.value)
                .font(.footnote)
                .fontWeight(.medium)
                .lineLimit(3)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    @ViewBuilder
    private func membersView() -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Members")
                .font(.caption2)
                .foregroundStyle(.secondary)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            ForEach(vm.members) { member in
                Button {
                    profileTypeToOpen = .user(userId: member.id)
                } label: {
                    memberRow(member)
                }
                .buttonStyle(.plain)
                
                if member.id != vm.members.last?.id {
                    Divider()
                        .padding(.leading, 44)
                }
            }
        }
        .padding(.top, 4)
    }
    
    @ViewBuilder
    private func memberRow(_ member: ProfileMemberModel) -> some View {
        HStack(spacing: 10) {
            AvatarView(model: member.avatarModel)
                .frame(width: 34, height: 34)
            
            VStack(alignment: .leading, spacing: 1) {
                Text(member.title)
                    .font(.footnote)
                    .fontWeight(.semibold)
                    .lineLimit(1)
                if let subtitle = member.subtitle {
                    Text(subtitle)
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }
            }
            
            Spacer(minLength: 4)
            
            Image(systemName: "chevron.right")
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .contentShape(Rectangle())
    }
    
    @ViewBuilder
    private func messageButton() -> some View {
        Button {
            Task {
                chatIdToOpen = await vm.openChatToUser()
            }
        } label: {
            Label("Message", systemImage: "message.fill")
        }
    }
    
    @ViewBuilder
    private func joinButton() -> some View {
        Button {
            vm.joinChat()
        } label: {
            Label(vm.isJoiningChat ? "Joining..." : "Join", systemImage: "person.badge.plus.fill")
        }
        .disabled(vm.isJoiningChat)
        .tint(.blue)
    }
    
    @ViewBuilder
    private func blockButton() -> some View {
        let title = "Block"
        if #available(watchOS 26.0, *) {
            Button(title) {
                vm.onBlockUserTap()
                dismiss()
            }
            .buttonStyle(.glass)
            .tint(.red)
        } else {
            Button(title) {
                vm.onBlockUserTap()
                dismiss()
            }
            .tint(.red)
        }
    }
    
}

#Preview(traits: .mock()) {
    ProfileDetailPage(type: .user(userId: 0))
}
