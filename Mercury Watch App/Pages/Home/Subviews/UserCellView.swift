//
//  UserCellView.swift
//  Mercury Watch App
//
//  Created by Alessandro Alberti on 09/07/24.
//

import SwiftUI
import TDLibKit

struct UserCellView: View {
    
    let model: UserCellModel?
    
    var body: some View {
        Group {
            if let model {
                content(model)
            } else {
                loader()
            }
        }
        .padding(.vertical)
    }
    
    @ViewBuilder
    private func content(_ model: UserCellModel) -> some View {
        HStack(spacing: 10) {
            AvatarView(model: model.avatar)
                .frame(width: 40, height: 40)
            VStack(alignment: .leading) {
                Text(model.fullname)
                    .fontWeight(.semibold)
            }
        }
    }
    
    @ViewBuilder
    private func loader() -> some View {
        HStack(spacing: 10) {
            Circle()
                .fill(.tertiary)
                .frame(width: 40, height: 40)
            VStack(alignment: .leading) {
                Text("placeholder")
                    .fontWeight(.semibold)
            }
        }
        .redacted(reason: .placeholder)
    }
}

struct UserCellModel {
    var avatar: AvatarModel
    var fullname: String
}


#Preview {
    List {
        UserCellView(
            model: UserCellModel(avatar: .alessandro, fullname: "Alessandro")
        )
        UserCellView(
            model: UserCellModel(avatar: .init(letters: "MT"), fullname: "Marco Tammaro")
        )
        UserCellView(model: nil)
    }
}
