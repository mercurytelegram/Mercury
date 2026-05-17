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
        HStack(spacing: 6) {
            Capsule()
                .foregroundStyle(model.color)
                .frame(width: 3)
            
            VStack(alignment: .leading, spacing: 1) {
                Text(model.title)
                    .font(.caption2)
                    .fontWeight(.semibold)
                    .foregroundStyle(model.color)
                    .lineLimit(1)
                Text(model.text)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }
        }
        .padding(.vertical, 3)
        .frame(maxWidth: 130, alignment: .leading)
    }
}

struct ReplyModel {
    var color: Color
    var title: String
    var text: AttributedString
}

struct ForwardModel {
    var color: Color
    var title: String
}

#Preview {
    ReplyView(model: .init(
        color: .blue,
        title: "Title",
        text: "Message content"
    ))
}
