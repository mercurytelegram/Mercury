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
    enum MessageContent {
        case text(AttributedString)
        case voiceNote(model: VoiceNoteModel)
        case photo(model: AsyncImageModel, caption: String?)
        case stickerImage(model: StickerImageModel)
        case location(model: LocationModel)
        case pill(title: String?, description: LocalizedStringKey)
    }
}

struct StickerImageModel {
    let emoji: String
    let getImage: () async -> UIImage?
}

extension MessageModel {
    static func mock(
        id: Int = 0,
        sender: String = "",
        isOutgoing: Bool = true,
        reactions: [ReactionModel] = [],
        reply: ReplyModel? = nil,
        state: MessageModel.StateStyle = .delivered,
        content: MessageModel.MessageContent = .text("")
    ) -> Self {
        .init(
            id: Int64(id),
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

