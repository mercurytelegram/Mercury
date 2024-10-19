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
    @StateObject var vm: MessageViewModel
    
    init(vm: MessageViewModelMock) {
        self._vm = StateObject(wrappedValue: vm)
    }
    
    init(message: Message, chat: ChatCellModel) {
        self._vm = StateObject(wrappedValue: MessageViewModel(message: message, chat: chat))
    }
    
    var body: some View {
        Group {
            switch vm.message.content {
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
            case .messageSticker(let message):
                MessageBubbleView(style: .hideBackground) {
                    WebpStickerView(sticker: message.sticker)
                        .frame(maxWidth: 100)
                        .padding()
                }
            default:
                MessageBubbleView {
                    Text(vm.message.description)
                }
            }
        }
        .environmentObject(vm)
    }
}

#Preview("Messages") {
    VStack {
        MessageView(vm: MessageViewModelMock(name: "Craig Federighi"))
        MessageView(vm: MessageViewModelMock(message: .preview(isOutgoing: true)))
    }
}

#Preview("Location") {
    MessageView(vm: MessageViewModelMock())
    
}

#Preview("Loading Name") {
    MessageView(vm: MessageViewModelMock(showSender: true))
}

#Preview("Group Photo Change") {
    VStack {
        PillMessageView(description: "changed group photo")
        TdImageView(tdImage: TDImageMock("craig"))
            .frame(width: 60, height: 60)
            .clipShape(RoundedRectangle(cornerRadius: 10))
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(.blue.opacity(0.3))
    .environmentObject(MessageViewModelMock() as MessageViewModel)
}

