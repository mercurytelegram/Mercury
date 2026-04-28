//
//  ChatDetailViewModel+MessageContents.swift
//  Mercury Watch App
//
//  Created by Alessandro Alberti on 11/10/24.
//

import SwiftUI
import TDLibKit
import SDWebImageWebPCoder

extension ChatDetailViewModel {

    func messageContentFrom(_ msg: Message) async ->  MessageModel.MessageContent {
        switch msg.content {

        case .messageText(let message):
            return .text(message.text.attributedString)

        case .messageVoiceNote(let message):
            guard var model = await message.getModel()
            else { return .text(msg.description) }
            model.onPress = { self.setMessageAsOpened(msg.id) }
            return .voiceNote(model: model)

        case .messagePhoto(let message):
            return .photo(model: message.getModel(), caption: message.caption.attributedString)

        case .messageAnimation(let message):
            return .animation(model: message.getModel(), caption: message.caption.attributedString)

        case .messageVideoNote(let message):
            var model = message.getModel()
            model.onPress = { self.setMessageAsOpened(msg.id) }
            return .videoNote(model: model)

        case .messageSticker(let message):
            switch message.sticker.format {

            case .stickerFormatWebp:
                return .stickerImage(model: message.getImageModel())
            case .stickerFormatTgs:
                return .text(msg.description)
            case .stickerFormatWebm:
                return .text(msg.description)
            }

        case .messageLocation(let message):
            return .location(model: message.getModel())

        case .messageVenue(let message):
            return .location(model: message.getModel())

        case .messagePinMessage(_):
            return await getPillModel(message: msg, text: "pinned a message")

        case .messageChatChangeTitle(let message):
            return await getPillModel(
                message: msg,
                text: "changed the group name to _\(message.title)_"
            )

        case .messageChatChangePhoto(_):
            return await getPillModel(
                message: msg,
                text: "changed group photo"
            )

        case .messageVideoChatScheduled(_):
            return await getPillModel(message: msg, text: "scheduled a video chat")
            
        case .messageVideoChatStarted(_):
            return await getPillModel(message: msg, text: "started a video chat")
            
        case .messageVideoChatEnded(let message):
            let duration = message.duration
            let formatString = duration > 0 ? "ended the video chat (\(duration)s)" : "ended the video chat"
            return await getPillModel(message: msg, text: LocalizedStringKey(formatString))
            
        case .messageInviteVideoChatParticipants(_):
            return await getPillModel(message: msg, text: "invited to video chat")
            
        case .messageCall(_):
            return await getPillModel(message: msg, text: "Call")
            
        case .messageDocument(_):
            return .text("📄 Document")
            
        case .messageAudio(_):
            return .text("🎵 Audio")
            
        case .messagePoll(let message):
            return .text(AttributedString("📊 \(message.poll.question.text)"))
            
        case .messageContact(_):
            return .text("👤 Contact")
            
        case .messageChatAddMembers(_):
            return await getPillModel(message: msg, text: "joined the group")
            
        case .messageChatJoinByLink:
            return await getPillModel(message: msg, text: "joined by invite link")
            
        case .messageChatDeleteMember(_):
            return await getPillModel(message: msg, text: "left the group")
            
        case .messageBasicGroupChatCreate(_):
            return await getPillModel(message: msg, text: "created the group")
            
        case .messageSupergroupChatCreate(_):
            return await getPillModel(message: msg, text: "created the supergroup")
            
        case .messageChatUpgradeTo(_):
            return await getPillModel(message: msg, text: "upgraded to supergroup")
            
        case .messageChatUpgradeFrom(_):
            return await getPillModel(message: msg, text: "upgraded from basic group")
            
        case .messageForumTopicCreated(_):
            return await getPillModel(message: msg, text: "created a topic")
            
        case .messageForumTopicEdited(_):
            return await getPillModel(message: msg, text: "edited the topic")
            
        case .messageForumTopicIsClosedToggled(_):
            return await getPillModel(message: msg, text: "toggled topic closed state")
            
        case .messageForumTopicIsHiddenToggled(_):
            return await getPillModel(message: msg, text: "toggled topic visibility")
            
            
        case .messageUnsupported:
            return .pill(title: nil, description: "Message not supported")

        default:
            let text = msg.description
            if text.characters.isEmpty {
                return .pill(title: nil, description: "Unsupported message")
            }
            return .text(text)
        }

    }

    func getPillModel(message: Message, text: LocalizedStringKey) async ->  MessageModel.MessageContent {
        let sender = await self.senderNameFrom(message)
        return .pill(
            title: sender.name,
            description: text
        )
    }
}

extension MessageVideoNote {
    func getModel() -> VideoNoteModel {
        return VideoNoteModel(
            thumbnail: videoNote.getAsyncModel(),
            duration: videoNote.duration,
            isSecret: isSecret,
            isViewed: isViewed,
            getVideoURL: {
                await FileService.getStreamingFilePath(for: videoNote.video)
            }
        )
    }
}

extension MessageVoiceNote {
    func getModel() async -> VoiceNoteModel? {
        return VoiceNoteModel(
            isListened: self.isListened,
            getPlayer: {
                guard let file = await FileService.getFilePath(for: voiceNote.voice),
                      let player = try? PlayerService(audioFilePath: file)
                else { return nil }
                return player
            }
        )
    }
}

extension MessagePhoto {
    func getModel() -> AsyncImageModel {
        var thumbnail: UIImage? = nil
        if let data = photo.minithumbnail?.data {
            thumbnail = UIImage(data: data)
        }
        return AsyncImageModel(
            thumbnail: thumbnail,
            getImage: {
                guard let photo = photo.lowRes
                else { return nil }
                return await FileService.getImage(for: photo)
            }
        )
    }
}

extension MessageSticker {
    func getImageModel() -> StickerImageModel {
        return StickerImageModel(
            emoji: sticker.emoji,
            getImage: {
                guard let filePath = await FileService.getFilePath(for: sticker.sticker),
                      let data = try? Data(contentsOf: filePath)
                else { return nil }
                return SDImageWebPCoder.shared.decodedImage(with: data, options: nil)
            }
        )
    }
}

extension MessageLocation {
    func getModel() -> LocationModel {
        return LocationModel(
            coordinate: CLLocationCoordinate2D(
                latitude: self.location.latitude,
                longitude: self.location.longitude
            )
        )
    }
}

extension MessageVenue {
    func getModel() -> LocationModel {
        let style = pinStyle()

        return LocationModel(
            title: venue.title,
            coordinate: CLLocationCoordinate2D(
                latitude: venue.location.latitude,
                longitude: venue.location.longitude
            ),
            color: style.color,
            markerSymbol: style.symbol
        )
    }

    private func pinStyle() -> (symbol: String, color: Color) {
        switch venue.type {
        case "arts_entertainment/museum":
            return ("building.columns.fill", .pink)
        case "travel/hotel":
            return ("bed.double.fill", .purple)
        case let type where type.contains("food"):
            return ("fork.knife", .orange)
        case let type where type.contains("parks_outdoors"):
            return ("tree.fill", .green)
        case let type where type.contains("shops"):
            return ("bag.fill", .yellow)
        case let type where type.contains("building"):
            return ("building.2.fill", .gray)
        default:
            return ("mapin", .red)
        }
    }
}

extension MessageAnimation {
    func getModel() -> AnimationModel {
        return AnimationModel(
            thumbnail: animation.getAsyncModel(),
            getVideoURL: {
                await FileService.getFilePath(for: animation.animation)
            }
        )
    }
}
