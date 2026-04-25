//
//  ProfileDetail.swift
//  Mercury
//
//  Created by Marco Tammaro on 08/02/26.
//

import SwiftUI

enum ProfileDetailPageType {
    case user(userId: Int64)
    case basicGroup(groupId: Int64, chatId: Int64)
    case superGroup(groupId: Int64, chatId: Int64)
}

struct ProfileDetailPage: View {
    
    @State
    @Mockable
    var vm: ProfileDetailViewModel
    
    @Environment(\.dismiss) private var dismiss

    
    init(type: ProfileDetailPageType) {
        _vm = Mockable.state(
            value: { ProfileDetailViewModel(type: type) },
            mock: { ProfileDetailViewModelMock() }
        )
    }
    
    var body: some View {
        
        GeometryReader { geo in
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
            .background {
                backgroundImage()
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
        VStack {
            // TODO: add profile info rows
            if vm.isBlockEnabled {
                blockButton()
            }
        }
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
