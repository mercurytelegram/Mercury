//
//  MessageView.swift
//  Mercury Watch App
//
//  Created by Alessandro Alberti on 16/05/24.
//

import MapKit
import SwiftUI
import TDLibKit

struct MessageView: View {
    let model: MessageModel
    var onVideoNoteOpen: ((VideoNoteModel) -> Void)? = nil

    var body: some View {
        switch model.content {

        case .text(let text):
            MessageBubbleView(model: model) {
                Text(text)
            }

        case .voiceNote(let voiceModel):
            MessageBubbleView(model: model) {
                VoiceNoteView(
                    model: voiceModel,
                    isOutgoing: model.isOutgoing
                )
            }

        case .photo(let imageModel, let caption):
            MessageBubbleView(model: model, style: .fullScreen(caption: caption)) {
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

        case .videoNote(let videoNoteModel):
            MessageBubbleView(model: model, style: .clearBackground) {
                VideoNotePreviewView(model: videoNoteModel) {
                    onVideoNoteOpen?(videoNoteModel)
                }
            }

        case .stickerImage(let stickerModel):
            MessageBubbleView(model: model, style: .clearBackground) {
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
            MessageBubbleView(model: model, style: .fullScreen()) {
                LocationView(model: locationModel)
            }

        case .animation(let animationModel, let caption):
            MessageBubbleView(model: model, style: .fullScreen(caption: caption)) {
                AnimationView(model: animationModel)
            }

        case .photoAlbum(let models, let caption):
            MessageBubbleView(model: model, style: .fullScreen(caption: caption)) {
                PhotoAlbumView(models: models)
            }

        case .pill(let title, let description):
            PillView(title: title, description: description)
        }
    }
}

struct PhotoAlbumView: View {
    let models: [AsyncImageModel]
    
    var body: some View {
        VStack(spacing: 2) {
            if models.count == 2 {
                HStack(spacing: 2) {
                    photoView(for: 0)
                    photoView(for: 1)
                }
            } else if models.count == 3 {
                HStack(spacing: 2) {
                    photoView(for: 0)
                    photoView(for: 1)
                }
                photoView(for: 2)
            } else if models.count >= 4 {
                HStack(spacing: 2) {
                    photoView(for: 0)
                    photoView(for: 1)
                }
                HStack(spacing: 2) {
                    photoView(for: 2)
                    photoView(for: 3)
                }
                if models.count > 4 {
                    Text("+\(models.count - 4)")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                        .padding(.top, 2)
                }
            } else {
                // Fallback for 1 or 0
                if let first = models.first {
                    photoView(for: 0)
                }
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
    
    @ViewBuilder
    private func photoView(for index: Int) -> some View {
        let model = models[index]
        AsyncView(getData: model.getImage) {
            Group {
                if let thumbnail = model.thumbnail {
                    Image(uiImage: thumbnail)
                        .resizable()
                        .scaledToFill()
                } else {
                    Color.black.opacity(0.35)
                }
            }
        } buildContent: { image in
            Image(uiImage: image)
                .resizable()
                .scaledToFill()
        }
        .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
        .aspectRatio(1, contentMode: .fill)
        .clipped()
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
    var mediaAlbumId: TdInt64? = nil

    var stateStyle: StateStyle?
    enum StateStyle {
        case sending, delivered, seen, failed
    }

    var content: MessageContent
    enum MessageContent {
        case text(AttributedString)
        case voiceNote(model: VoiceNoteModel)
        case photo(model: AsyncImageModel, caption: AttributedString?)
        case photoAlbum(models: [AsyncImageModel], caption: AttributedString?)
        case videoNote(model: VideoNoteModel)
        case stickerImage(model: StickerImageModel)
        case location(model: LocationModel)
        case animation(model: AnimationModel, caption: AttributedString?)
        case pill(title: String?, description: LocalizedStringKey)

        var isVideoNote: Bool {
            if case .videoNote = self {
                return true
            }
            return false
        }
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
            mediaAlbumId: nil,
            stateStyle: isOutgoing ? state : nil,
            content: content
        )
    }
}

// MARK: - Previews

#Preview("Video Note") {
    MessageView(model: .mock(
        content: .videoNote(model: VideoNoteModel(
            thumbnail: AsyncImageModel(thumbnail: UIImage(named: "astro"), getImage: { nil }),
            duration: 15,
            getVideoURL: { nil }
        ))
    ))
}

#Preview("Animation (GIF)") {
    MessageView(model: .mock(
        content: .animation(
            model: AnimationModel(
                thumbnail: AsyncImageModel(thumbnail: UIImage(named: "astro"), getImage: { nil }),
                getVideoURL: { nil }
            ),
            caption: "Look at this cool GIF!"
        )
    ))
}
