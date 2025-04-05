//
//  ReplyView.swift
//  Mercury Watch App
//
//  Created by Alessandro Alberti on 07/09/24.
//

import SwiftUI
import TDLibKit

struct ReplyView: View {
    let model: ReplyModel
    
    var body: some View {
        VStack (alignment: .leading) {
            Text(model.title)
                .fontWeight(.semibold)
                .foregroundStyle(model.color)
            Text(model.text)
                .lineLimit(2)
        }
        .padding()
        .padding(.leading, 3)
        .background {
            HStack(spacing: 0) {
                Rectangle()
                    .foregroundStyle(model.color)
                    .frame(width: 5)
                Rectangle()
                    .foregroundStyle(model.color.opacity(0.3))
            }
            .clipShape(RoundedRectangle(cornerRadius: 8))
        }
    }
}

struct ReplyModel: Equatable, Hashable {
    var color: Color
    var title: String
    var text: AttributedString
}

#Preview {
    ReplyView(model: .init(
        color: .blue,
        title: "Title",
        text: "Message content"
    ))
}
