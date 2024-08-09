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
            MessageBubbleImageView(caption: message.caption.text) {
                TdImageView(tdImage: message.photo)
            }

        case .messageVoiceNote(let message):
            MessageBubbleView {
                VoiceNoteContentView(message: message)
            }
            
        case .messageVideo(let message):
            MessageBubbleImageView(caption: message.caption.text) {
                TdImageView(tdImage: message.video)
            }
            .overlay {
                Image(systemName: "play.circle.fill")
                    .font(.largeTitle)
                    .foregroundStyle(.white, .ultraThinMaterial)
            }
            
        case .messageLocation(let message):
            MessageBubbleImageView {
                LocationContentView(coordinate: CLLocationCoordinate2D(latitude: message.location.latitude, longitude: message.location.longitude))
                    
            }
        case .messageVenue(let message):
            MessageBubbleImageView {
                LocationContentView(venue: message.venue)
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

