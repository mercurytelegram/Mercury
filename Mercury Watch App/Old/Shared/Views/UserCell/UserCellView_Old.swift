//
//  UserCellView.swift
//  Mercury Watch App
//
//  Created by Alessandro Alberti on 09/07/24.
//

import SwiftUI
import TDLibKit

struct UserCellView_Old: View {
    var vm: UserCellViewModel
    
    var body: some View {
        HStack(spacing: 10) {
            AvatarView_Old(model: vm.avatarModel)
                .frame(width: 40, height: 40)
            VStack(alignment: .leading) {
                Text(vm.fullName)
                    .fontWeight(.semibold)
            }
        }
        .redacted(reason: vm.redaction)
        .padding(.vertical)
    }
}

#Preview {
    List {
        UserCellView_Old(vm: UserCellViewModel())
        UserCellView_Old(vm: MockUserCellViewModel())
        UserCellView_Old(vm: MockUserCellViewModel(
            user: .preview(firstName: "Very Long", lastName: "Name"),
            imageName: "alessandro")
        )
    }
}
