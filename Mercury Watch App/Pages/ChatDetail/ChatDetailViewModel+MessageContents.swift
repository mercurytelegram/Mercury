//
//  ChatDetailViewModel+MessageContents.swift
//  Mercury Watch App
//
//  Created by Alessandro Alberti on 11/10/24.
//

import TDLibKit
import SwiftUI

extension ChatDetailViewModel {
    
    func messageContentFrom(_ msg: Message) async ->  MessageModel.MessageContent {
        switch msg.content {
            
        case .messageText(let message):
            return .text(message.text.attributedString)
            
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
            title: message.isOutgoing ? "me": sender,
            description: text
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
