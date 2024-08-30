//
//  MessageView.swift
//  Mercury Watch App
//
//  Created by Alessandro Alberti on 16/05/24.
//

import SwiftUI
import TDLibKit
import MapKit

struct MessageView: View {
    var message: Message
    
    var body: some View {
        switch message.content {
        case .messageText(let message):
            MessageBubbleView {
                Text(message.text.attributedString)
            }
            
        case .messagePhoto(let message):
            MessageBubbleView(style: .fullScreen, caption: message.caption.text) {
                TdImageView(tdImage: message.photo)
            }

        case .messageVoiceNote(let message):
            MessageBubbleView {
                VoiceNoteContentView(message: message)
            }
            
        case .messageVideo(let message):
            MessageBubbleView(style: .fullScreen, caption: message.caption.text) {
                TdImageView(tdImage: message.video)
            }
            .overlay {
                Image(systemName: "play.circle.fill")
                    .font(.largeTitle)
                    .foregroundStyle(.white, .ultraThinMaterial)
            }
            
        case .messageLocation(let message):
            MessageBubbleView(style: .fullScreen) {
                LocationContentView(coordinate: CLLocationCoordinate2D(latitude: message.location.latitude, longitude: message.location.longitude))
            }
        case .messageVenue(let message):
            MessageBubbleView(style: .fullScreen) {
                LocationContentView(venue: message.venue)
            }
        case .messagePinMessage(_):
            PillMessageView(description: "pinned a message")
        case .messageChatChangeTitle(let message):
            PillMessageView(description: "changed the group name to \"\(message.title)\"")
        case .messageChatChangePhoto(let message):
            VStack {
                PillMessageView(description: "changed group photo")
                TdImageView(tdImage: message.photo)
                    .frame(width: 60, height: 60)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
            }
        default:
            MessageBubbleView {
                Text(message.description)
            }
        }
    }
}

#Preview("Messages") {
    VStack {
        MessageView(message: .preview())
            .environmentObject(MessageViewModelMock(name: "Craig Federighi") as MessageViewModel)
        MessageView(message: .preview(
            content: .text("World")
        ))
        .environmentObject(MessageViewModelMock(message: .preview(isOutgoing: true)) as MessageViewModel)
    }
}

#Preview("Location") {
    MessageView(message: .preview(content: .location()))
        .environmentObject(MessageViewModelMock() as MessageViewModel)
    
}

#Preview("Loading Name") {
    MessageView(message: .preview())
        .environmentObject(MessageViewModelMock(showSender: true) as MessageViewModel)
}

#Preview("Group Photo Change") {
    VStack {
        PillMessageView(description: "changed group photo")
        TdImageView(tdImage: TDImageMock("craig"))
            .frame(width: 60, height: 60)
            .clipShape(RoundedRectangle(cornerRadius: 10))
    }
    .environmentObject(MessageViewModelMock() as MessageViewModel)
}

