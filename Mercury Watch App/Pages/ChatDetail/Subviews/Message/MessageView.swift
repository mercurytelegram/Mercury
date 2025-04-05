//
//  MessageView.swift
//  Mercury Watch App
//
//  Created by Alessandro Alberti on 16/05/24.
//

import SwiftUI
import TDLibKit
import MapKit
import TDLibKit

struct MessageView: View {
    let model: MessageModel
    
    var body: some View {
        switch model.content {
            
        case .text(let text):
            MessageBubbleView(model: self.model) {
                Text(text)
            }
            
        case .voiceNote(let voiceModel):
            MessageBubbleView(model: self.model) {
                VoiceNoteView(
                    model: voiceModel,
                    isOutgoing: self.model.isOutgoing
                )
            }
            
        case .photo(let imageModel, let caption):
            MessageBubbleView(model: self.model, style: .fullScreen(caption: caption ?? "")) {
                AsyncView(getData: imageModel.getImage) {
                    Group {
                        if let thumbnail = imageModel.thumbnail {
                            Image(uiImage: thumbnail)
                                .resizable()
                                .scaledToFill()
                        }
                        if imageModel.thumbnail == nil {
                            ProgressView()
                        }
                    }
                } buildContent: { image in
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                }
            }
            
        case .stickerImage(let stickerModel):
            MessageBubbleView(model: self.model, style: .clearBackground) {
                AsyncView(getData: stickerModel.getImage) {
                    Text(stickerModel.emoji)
                        .font(.largeTitle)
                } buildContent: { image in
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 100)
                }
            }
            
        case .location(let locationModel):
            MessageBubbleView(model: self.model, style: .fullScreen(caption: "")) {
                LocationView(model: locationModel)
            }
            
        case .pill(let title, let description):
            PillView(title: title, description: description)
            //
            //            case .video:
            //                MessageBubbleView(model: self.model)(style: .fullScreen, caption: message.caption.text) {
            //                    TdImageView(tdImage: message.video)
            //                }
            //                .overlay {
            //                    Image(systemName: "play.circle.fill")
            //                        .font(.largeTitle)
            //                        .foregroundStyle(.white, .ultraThinMaterial)
            //                }
        }
    }
}

struct MessageModel: Identifiable {
    
    var id: Int64
    
    var sender: String?
    var senderColor: Color?
    var isSenderHidden: Bool = false
    
    var date: Foundation.Date
    var time: String {
        date.formatted(.dateTime.hour().minute())
    }
    
    var isOutgoing: Bool = false
    
    var reactions: [ReactionModel] = []
    var reply: ReplyModel? = nil
    
    var stateStyle: StateStyle?
    enum StateStyle {
        case sending, delivered, seen, failed
    }
    
    var content: MessageContent
    enum MessageContent: Hashable {
        case text(AttributedString)
        case voiceNote(model: VoiceNoteModel)
        case photo(model: AsyncImageModel, caption: String?)
        case stickerImage(model: StickerImageModel)
        case location(model: LocationModel)
        case pill(title: String?, description: String)
        
        static func == (lhs: MessageContent, rhs: MessageContent) -> Bool {
            switch (lhs, rhs) {
            case let (.text(a), .text(b)): return a == b
            case let (.voiceNote(a), .voiceNote(b)): return a == b
            case let (.photo(a, ac), .photo(b, bc)): return a == b && ac == bc
            case let (.stickerImage(a), .stickerImage(b)): return a == b
            case let (.location(a), .location(b)): return a == b
            case let (.pill(at, ad), .pill(bt, bd)): return at == bt && ad == bd
            default: return false
            }
        }
        
        func hash(into hasher: inout Hasher) {
            switch self {
            case let .text(value):
                hasher.combine(0)
                hasher.combine(value)
            case let .voiceNote(model):
                hasher.combine(1)
                hasher.combine(model)
            case let .photo(model, caption):
                hasher.combine(2)
                hasher.combine(model)
                hasher.combine(caption)
            case let .stickerImage(model):
                hasher.combine(3)
                hasher.combine(model)
            case let .location(model):
                hasher.combine(4)
                hasher.combine(model)
            case let .pill(title, description):
                hasher.combine(5)
                hasher.combine(title)
                hasher.combine(description)
            }
        }
        
    }
}

struct StickerImageModel: Equatable, Hashable {
    let emoji: String
    let getImage: () async -> UIImage?
    
    static func == (lhs: StickerImageModel, rhs: StickerImageModel) -> Bool {
        return lhs.emoji == rhs.emoji
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(emoji)
    }
}

extension MessageModel {
    static func mock(
        sender: String = "",
        isOutgoing: Bool = true,
        reactions: [ReactionModel] = [],
        reply: ReplyModel? = nil,
        state: MessageModel.StateStyle = .delivered,
        content: MessageModel.MessageContent = .text("")
    ) -> Self {
        .init(
            id: 0,
            sender: sender,
            senderColor: .blue,
            isSenderHidden: sender.isEmpty,
            date: .now,
            isOutgoing: sender.isEmpty ? isOutgoing : false,
            reactions: reactions,
            reply: reply,
            stateStyle: isOutgoing ? state : nil,
            content: content
        )
    }
}

extension MessageModel: Equatable, Hashable {
    static func == (lhs: MessageModel, rhs: MessageModel) -> Bool {
        return lhs.id == rhs.id &&
        lhs.sender == rhs.sender &&
        lhs.isSenderHidden == rhs.isSenderHidden &&
        lhs.date == rhs.date &&
        lhs.isOutgoing == rhs.isOutgoing &&
        lhs.reactions == rhs.reactions &&
        lhs.reply == rhs.reply &&
        lhs.stateStyle == rhs.stateStyle &&
        lhs.content == rhs.content
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(sender)
        hasher.combine(isSenderHidden)
        hasher.combine(date)
        hasher.combine(isOutgoing)
        hasher.combine(reactions)
        hasher.combine(reply)
        hasher.combine(stateStyle)
        hasher.combine(content)
    }
}
