//
//  ChatCellView.swift
//  Mercury Watch App
//
//  Created by Alessandro Alberti on 08/05/24.
//

import SwiftUI
import TDLibKit


struct ChatCellView: View {
    var model: ChatCellModel
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                AvatarView(model: model.avatar)
                    .frame(width: 50, height: 50)
                VStack(alignment: .leading) {
                    Text(model.td.title)
                        .font(.headline)
                        .lineLimit(2)
                    HStack {
                        if model.unreadCount != 0 {
                            Image(systemName: model.unreadSymbol)
                                .font(.title3)
                                .foregroundStyle(.white, model.unreadSymbolColor)
                        }
                        Text(model.time)
                            .font(.caption)
                            .foregroundStyle(.tertiary)
                    }
                }
                .padding(.leading, 5)
            }
            
            if let action = model.action {
                
                HStack(spacing: 10) {
                    Image(systemName: "ellipsis")
                        .symbolEffect(.variableColor, isActive: true)
                        .foregroundColor(.blue)
                    Text(action)
                        .lineLimit(3)
                        .foregroundStyle(.secondary)
                }
                
            } else if let msg = model.message, msg != "" {
                Text(msg)
                    .lineLimit(3)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical)
        .swipeActions(allowsFullSwipe: false) {
            Button(role: .destructive) {
                print("Deleting conversation")
            } label: {
                Label("Delete", systemImage: "trash.fill")
            }
            
            Button {
                print("Muting conversation")
            } label: {
                Label("Mute", systemImage: "speaker.slash.fill")
            }
            .tint(.orange)
            
            
        }
    }
}

#if DEBUG
#Preview("Unread") {
    List {
        ChatCellView(model: .preview())
        ChatCellView(model: .preview(unreadCount: 3))
        ChatCellView(model: .preview(showUnreadMention: true))
        ChatCellView(model: .preview(showUnreadReaction: true))
    }
    .listStyle(.carousel)
}

#Preview("Message") {
    List {
        ChatCellView(model: .preview(message: "Lorem ipsum dolor sit amet, consectetur"))
        ChatCellView(model: .preview(message: "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Duis rhoncus efficitur."))
    }
    .listStyle(.carousel)
}
#endif
