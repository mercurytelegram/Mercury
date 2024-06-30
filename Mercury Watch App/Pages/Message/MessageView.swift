//
//  MessageView.swift
//  Mercury Watch App
//
//  Created by Alessandro Alberti on 16/05/24.
//

import SwiftUI
import TDLibKit

struct MessageView: View {
    @StateObject var vm: MessageViewModel
    
    init(_ vm: MessageViewModel) {
        self._vm = StateObject(wrappedValue: vm)
    }
    
    var body: some View {
        VStack(alignment: .trailing){
            VStack(alignment: vm.textAlignment){
                if vm.showSender {
                    Text(vm.userFullName)
                        .fontWeight(.semibold)
                        .foregroundStyle(vm.titleColor)
                        .redacted(reason: vm.userNameRedaction)
                }
                content
            }
            
            HStack(spacing: 10) {
                Text(vm.date)
                    .font(.system(size: 15))
                    .foregroundStyle(.secondary)
                
                if vm.isSending {
                    ProgressView()
                        .font(.system(size: 15))
                        .foregroundStyle(.secondary)
                        .frame(width: 15, height: 15)
                }
            }
            
        }
        .padding()
        .padding(vm.message.isOutgoing ? .trailing : .leading, 5)
        .background {
            if vm.showBubble {
                BubbleShape(myMessage: vm.message.isOutgoing)
                    .foregroundStyle(vm.message.isOutgoing ? .blue.opacity(0.3) : .white.opacity(0.2))
            }
        }
        .frame(maxWidth: .infinity, alignment: vm.message.isOutgoing ? .trailing : .leading)
    }
    
    @ViewBuilder
    var content: some View {
        switch vm.message.content {
        case .messageText(let messageText):
            Text(messageText.text.attributedString)
            
        case .messagePhoto(let messagePhoto):
            TdPhotoView(tdPhoto: messagePhoto.photo)
                .clipShape(BubbleShape(myMessage: vm.message.isOutgoing))
                .padding(vm.message.isOutgoing ? .trailing : .leading, -10)

        case .messageVoiceNote(let message):
            HStack(alignment: .top, spacing: 5) {
                
                Button(action: {
                    vm.play()
                }, label: {
                    
                    Group {
                        if vm.isLoading {
                            ProgressView()
                        } else {
                            Image(systemName: vm.isPlaying ? "pause.fill" : "play.fill")
                        }
                    }
                    .font(.system(size: 24))
                    .padding(12)
                    .background(Color.blue)
                    .clipShape(Circle())
                    
                })
                .frame(width: 42, height: 42)
                .buttonStyle(.plain)
                
                VStack(alignment: .leading) {
                    
                    var elapsedTime: String {
                        let time = message.voiceNote.duration
                        let seconds = Int(time % 60)
                        let minutes = Int(time / 60)
                        return String(format:"%02d:%02d", minutes, seconds)
                    }
                
                    Waveform(data: message.voiceNote.waveform)
                        .frame(height: 42, alignment: .leading)
                    
                    Text(elapsedTime)
                        .font(.system(size: 15))
                        .bold()
                        .foregroundStyle(.blue)
                }
            }
            
        default:
            Text(vm.message.description)
        }
    }
}


#Preview("Messages") {
    VStack {
        MessageView(MessageViewModelMock(name: "Craig Federighi"))
        MessageView(MessageViewModelMock(message: .preview(
            content: .text("World"),
            isOutgoing: true
        )))
    }
}

#Preview("Loading") {
    VStack {
        MessageView(MessageViewModelMock())
        MessageView(MessageViewModelMock(message: .preview(
            content: .text("World"),
            isOutgoing: true
        )))
    }
}
