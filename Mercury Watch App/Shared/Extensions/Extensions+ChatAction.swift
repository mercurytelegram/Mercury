//
//  Extensions+ChatAction.swift
//  Mercury Watch App
//
//  Created by Marco Tammaro on 29/05/24.
//

import Foundation
import TDLibKit

extension ChatAction {
    
    var description: AttributedString? {
        switch self {
        case .chatActionCancel:
            return nil
        case .chatActionTyping:
            return "typing"
        case .chatActionRecordingVoiceNote:
            return "recording"
        case .chatActionRecordingVideo:
            return "recording video"
        case .chatActionRecordingVideoNote:
            return "recording video note"
        case .chatActionChoosingContact:
            return "selecting contact"
        case .chatActionChoosingLocation:
            return "selecting location"
        case .chatActionChoosingSticker:
            return "selecting sticker"
        case .chatActionStartPlayingGame:
            return "starting game"
        case .chatActionUploadingDocument(_):
            return "uploading document"
        case .chatActionUploadingPhoto(_):
            return "uploading photo"
        case .chatActionUploadingVideo(_):
            return "uploading video"
        case .chatActionUploadingVideoNote(_):
            return "uploading video note"
        case .chatActionUploadingVoiceNote(_):
            return "uploading recording"
        case .chatActionWatchingAnimations(_):
            return "watching animations"
        }
    }
    
}
