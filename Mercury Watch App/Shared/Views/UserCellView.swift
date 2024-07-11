//
//  UserCellView.swift
//  Mercury Watch App
//
//  Created by Alessandro Alberti on 09/07/24.
//

import SwiftUI
import TDLibKit

struct UserCellView: View {
    var user: User?
    
    var body: some View {
        HStack(spacing: 10) {
            AvatarView(model: AvatarModel(tdPhoto: user?.profilePhoto, letters: nameLetters))
                .frame(width: 40, height: 40)
            VStack(alignment: .leading) {
                Text(fullName)
                    .fontWeight(.semibold)
            }
        }
        .redacted(reason: redaction)
        .padding(.vertical)
    }
    
    private var fullName: String {
        let firstName = user?.firstName ?? "PlaceHolder"
        let lastName = user?.lastName ?? "PlaceHolder"
        
        return firstName + " " + lastName
    }
    
    private var nameLetters: String {
        let firstLetter = user?.firstName.prefix(1) ?? "P"
        let secondLetter = user?.lastName.prefix(1) ?? "P"
        
        return "\(firstLetter)\(secondLetter)"
    }
    
    private var redaction: RedactionReasons {
        user == nil ? .placeholder : []
    }
}

#Preview {
    List {
        UserCellView()
        UserCellView(user: .preview())
    }
}
