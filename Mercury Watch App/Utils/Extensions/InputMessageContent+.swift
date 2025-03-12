//
//  InputMessageContent+.swift
//  Mercury Watch App
//
//  Created by Alessandro Alberti on 12/03/25.
//

import Foundation
import TDLibKit

extension InputMessageContent {
    static func from(sticker: Sticker) -> Self {
        .inputMessageSticker(.init(
            emoji: sticker.emoji,
            height: sticker.height,
            sticker: .inputFileId(.init(id: sticker.sticker.id)),
            thumbnail: .init(
                height: sticker.thumbnail?.height ?? 0,
                thumbnail: .inputFileId(.init(id: sticker.thumbnail?.file.id ?? 0)),
                width: sticker.thumbnail?.width ?? 0),
            width: sticker.width))
    }
}
