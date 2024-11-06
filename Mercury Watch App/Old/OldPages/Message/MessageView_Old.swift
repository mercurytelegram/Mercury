//
//  MessageView.swift
//  Mercury Watch App
//
//  Created by Alessandro Alberti on 16/05/24.
//

import SwiftUI
import TDLibKit
import MapKit

struct MessageView_Old: View {
    @StateObject var vm: MessageViewModel_Old
    
    init(vm: MessageViewModelMock) {
        self._vm = StateObject(wrappedValue: vm)
    }
    
    init(message: Message, chat: ChatCellModel_Old) {
        self._vm = StateObject(wrappedValue: MessageViewModel_Old(message: message, chat: chat))
    }
    
    var body: some View {
        Group {
            switch vm.message.content {
            case .messageText(let message):
                MessageBubbleView_Old {
                    Text(message.text.attributedString)
                }
                
            case .messagePhoto(let message):
                MessageBubbleView_Old(style: .fullScreen, caption: message.caption.text) {
                    TdImageView(tdImage: message.photo)
                }

            case .messageVoiceNote(let message):
                MessageBubbleView_Old {
                    VoiceNoteContentView_Old(message: message)
                }
                
            case .messageVideo(let message):
                MessageBubbleView_Old(style: .fullScreen, caption: message.caption.text) {
                    TdImageView(tdImage: message.video)
                }
                .overlay {
                    Image(systemName: "play.circle.fill")
                        .font(.largeTitle)
                        .foregroundStyle(.white, .ultraThinMaterial)
                }
                
            case .messageLocation(let message):
                MessageBubbleView_Old(style: .fullScreen) {
                    LocationContentView_Old(coordinate: CLLocationCoordinate2D(latitude: message.location.latitude, longitude: message.location.longitude))
                }
            case .messageVenue(let message):
                MessageBubbleView_Old(style: .fullScreen) {
                    LocationContentView_Old(venue: message.venue)
                }
            case .messagePinMessage(_):
                PillMessageView_Old(description: "pinned a message")
            case .messageChatChangeTitle(let message):
                PillMessageView_Old(description: "changed the group name to \"\(message.title)\"")
            case .messageChatChangePhoto(let message):
                VStack {
                    PillMessageView_Old(description: "changed group photo")
                    TdImageView(tdImage: message.photo)
                        .frame(width: 60, height: 60)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                }
            case .messageSticker(let message):
                MessageBubbleView_Old(style: .hideBackground) {
                        switch message.sticker.format {
                        case .stickerFormatWebp:
                            WebpStickerView(sticker: message.sticker)
                                .frame(maxWidth: 100)
                                .padding()
                        case .stickerFormatTgs:
                            TgsStickerView(sticker: message.sticker)
                        case .stickerFormatWebm:
                            Spacer()
                        }
                    
                }
            default:
                MessageBubbleView_Old {
                    Text(vm.message.description)
                }
            }
        }
        .environmentObject(vm)
    }
}

#Preview("Messages") {
    VStack {
        MessageView_Old(vm: MessageViewModelMock(name: "Craig Federighi"))
        MessageView_Old(vm: MessageViewModelMock(message: .preview(isOutgoing: true)))
    }
}

#Preview("Location") {
    MessageView_Old(vm: MessageViewModelMock())
    
}

#Preview("Loading Name") {
    MessageView_Old(vm: MessageViewModelMock(showSender: true))
}

#Preview("Group Photo Change") {
    VStack {
        PillMessageView_Old(description: "changed group photo")
        TdImageView(tdImage: TDImageMock("astro"))
            .frame(width: 60, height: 60)
            .clipShape(RoundedRectangle(cornerRadius: 10))
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(.blue.opacity(0.3))
    .environmentObject(MessageViewModelMock() as MessageViewModel_Old)
}

