//
//  ChatCellView.swift
//  Mercury Watch App
//
//  Created by Alessandro Alberti on 08/05/24.
//

import SwiftUI
import TDLibKit


struct ChatCellView: View {
    @State private var showMuteAlert = false
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
                        if model.hasUnreadMsg {
                            if model.showUnreadSymbol {
                                Image(systemName: model.unreadSymbol)
                                    .font(.title3)
                                    .foregroundStyle(.white, model.unreadSymbolColor)
                            } else {
                                unreadNumber
                            }
                            
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
            Button {
                showMuteAlert = true
            } label: {
                Label("Mute", systemImage: "speaker.slash.fill")
            }
            .tint(.orange)
        }
        .sheet(isPresented: $showMuteAlert) {
            AlertView.inDevelopment("mute is")
        }
    }
    
    @ViewBuilder
    var unreadNumber: some View {
        let size: CGFloat = 22
        Text("\(model.unreadCount)")
            .font(.system(size: 16))
            .fontDesign(.rounded)
            .fontWeight(.medium)
            .padding(.horizontal, 5)
            .background {
                RoundedRectangle(cornerRadius: size)
                    .frame(height: size)
                    .frame(minWidth: size)
                    .foregroundStyle(.blue)
            }
            .frame(minWidth: 25)
            .padding(.vertical, 1)
    }
    
}

#if DEBUG
#Preview("Unread") {
    List {
        ChatCellView(model: .preview())
        ChatCellView(model: .preview(unreadCount: 3))
        ChatCellView(model: .preview(unreadCount: 30))
        ChatCellView(model: .preview(unreadCount: 300))
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

#Preview("Test") {
    let number = 1
    return ChatCellView(model: .preview(unreadCount: 1)).unreadNumber
}

#endif
