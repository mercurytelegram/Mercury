//
//  StickersPickerViewModel.swift
//  Mercury Watch App
//
//  Created by Alessandro Alberti on 12/03/25.
//

import SwiftUI
import UIKit
import Foundation
import TDLibKit
import SDWebImageWebPCoder

struct StickerModel: Identifiable {
    let id = UUID()
    var sticker: Sticker?
    var getImage: () async -> UIImage?

    init(sticker: Sticker) {
        self.sticker = sticker
        self.getImage = {
            guard let filePath = await FileService.getFilePath(for: sticker.sticker),
                  let data = try? Data(contentsOf: filePath)
            else { return nil }
            return SDImageWebPCoder.shared.decodedImage(with: data, options: nil)
        }
    }
    
    init(getImage: @escaping () async -> UIImage?) {
        self.getImage = getImage
    }

}

struct StickerPackModel: Identifiable {
    let id = UUID()
    var setId: TdInt64?
    var title: String
    var stickers: [StickerModel]
    var size: Int
    var getThumbnail: () async -> UIImage?
    
    init(set: StickerSetInfo) {
        self.title = set.title
        self.setId = set.id
        self.stickers = []
        self.size = set.size
        
        self.getThumbnail = {
            // get thumbnail
            if let file = set.thumbnail?.file,
               let filePath = await FileService.getFilePath(for: file),
               let data = try? Data(contentsOf: filePath) {
                return SDImageWebPCoder.shared.decodedImage(with: data, options: nil)
            }
            // else get cover sticker
            if let file = set.covers.first?.thumbnail?.file,
               let filePath = await FileService.getFilePath(for: file),
               let data = try? Data(contentsOf: filePath) {
                return SDImageWebPCoder.shared.decodedImage(with: data, options: nil) ?? nil
            }
            return nil
        }
    }
    
    init(title: String, stickers: [StickerModel], size: Int, getThumbnail: @escaping () async -> UIImage?, setId: TdInt64? = nil) {
        self.title = title
        self.stickers = stickers
        self.size = size
        self.getThumbnail = getThumbnail
        self.setId = setId
    }
}


@Observable
class StickersPickerViewModel {
    var sendService: SendMessageService?
    var recentStickers: [StickerModel]
    var stickerPacks: [StickerPackModel] = []
    var isLoading = true
    
    init(sendService: SendMessageService?) {
        self.sendService = sendService
        self.recentStickers = []
    }
    
    func getStickers() async {
        // Recent Stickers
        if let recentStickerList = try? await TDLibManager.shared.client?.getRecentStickers(isAttached: false) {
            let recentStickers = recentStickerList.stickers.map{ StickerModel(sticker: $0) }
            await MainActor.run {
                withAnimation {
                    self.recentStickers = recentStickers
                }
            }
        }
        
        // Sticker Packs
        if let stickerPacks = try? await TDLibManager.shared.client?.getInstalledStickerSets(stickerType: .stickerTypeRegular) {
            let stickerPacks = stickerPacks.sets.map{ StickerPackModel(set: $0) }
            await MainActor.run {
                withAnimation {
                    self.stickerPacks = stickerPacks
                    self.isLoading = false
                }
            }
        }
    }
}

class StickersPickerViewModelMock: StickersPickerViewModel {
    init() {
        super.init(sendService: SendMessageServiceMock())
        
        self.isLoading = false
        self.recentStickers = [
            .init(getImage: { UIImage(named: "alessandro") }),
            .init(getImage: { UIImage(named: "marco") }),
            .init(getImage: { UIImage(named: "alessandro") })
        ]
        
        self.stickerPacks = [
            .init(title: "Title", stickers: [], size: 10, getThumbnail: { UIImage(named: "alessandro") }),
            .init(title: "Title", stickers: [], size: 10, getThumbnail: { UIImage(named: "marco") })
        ]


    }
}
