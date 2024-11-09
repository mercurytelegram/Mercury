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
            
            case .pill(let text):
                PillMessageView(text: text)
           
            case .location(let locationModel):
                MessageBubbleView(model: self.model, style: .fullScreen(caption: "")) {
                    LocationView(model: locationModel)
                }
                
            case .voiceNote(let voiceModel, let onPress):
                MessageBubbleView(model: self.model) {
                    VoiceNoteView(
                        model: voiceModel,
                        isOutgoing: self.model.isOutgoing,
                        onPress: onPress
                    )
                }
            
            default:
                Text("")
                
//            case .photo(let image, let caption):
//                MessageBubbleView(model: self.model, style: .fullScreen(caption: caption)) {
//                    TdImageView(tdImage: image)
//                }
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
//                
//            case .sticker:
//                MessageBubbleView(model: self.model, style: .hideBackground) {
//                        switch message.sticker.format {
//                        case .stickerFormatWebp:
//                            WebpStickerView(sticker: message.sticker)
//                                .frame(maxWidth: 100)
//                                .padding()
//                        case .stickerFormatTgs:
//                            TgsStickerView(sticker: message.sticker)
//                        case .stickerFormatWebm:
//                            Spacer()
//                        }
//                }
                
//            case .chatChangePhoto:
//                VStack {
//                    PillMessageView(description: "changed group photo")
//                    TdImageView(tdImage: message.photo)
//                        .frame(width: 60, height: 60)
//                        .clipShape(RoundedRectangle(cornerRadius: 10))
//                }
            }
    }
}

struct MessageModel: Identifiable {
    
    var id: Int64
    
    var sender: String?
    var senderColor: Color
    var isSenderHidden: Bool = false
    
    var time: String
    var isOutgoing: Bool
    
    var reactions: [ReactionModel] = []
    var reply: ReplyModel? = nil
    
    var stateStyle: StateStyle?
    enum StateStyle {
        case sending, delivered, seen, failed
    }
    
    enum DatatYpe {
        case mp4, jpeg
    }
    
    var content: MessageContent
    enum MessageContent {
        case text(AttributedString)
        case pill(String)
        case location(model: LocationModel)
        case voiceNote(model: VoiceNoteModel, onPress: () -> Void)
        
        case photo(image: File, caption: String?)
        case video(imageURL: URL, caption: String?)
        case sticker
    }
    
}

//#Preview("Messages") {
//    VStack {
//        MessageView(vm: MessageViewModelMock(name: "Craig Federighi"))
//        MessageView(vm: MessageViewModelMock(message: .preview(isOutgoing: true)))
//    }
//}
//
//#Preview("Location") {
//    MessageView(vm: MessageViewModelMock())
//    
//}
//
//#Preview("Loading Name") {
//    MessageView(vm: MessageViewModelMock(showSender: true))
//}
//
//#Preview("Group Photo Change") {
//    VStack {
//        PillMessageView(description: "changed group photo")
//        TdImageView(tdImage: TDImageMock("astro"))
//            .frame(width: 60, height: 60)
//            .clipShape(RoundedRectangle(cornerRadius: 10))
//    }
//    .frame(maxWidth: .infinity, maxHeight: .infinity)
//    .background(.blue.opacity(0.3))
//    .environmentObject(MessageViewModelMock() as MessageViewModel)
//}

