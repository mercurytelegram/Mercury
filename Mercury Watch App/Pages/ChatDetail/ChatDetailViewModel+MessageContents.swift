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
            return .photo(model: message.getModel(), caption: message.caption.text)
            
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
            
            
        default:
            return .text(msg.description)
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
