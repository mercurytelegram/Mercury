//
//  StickersPickerViewModel.swift
//  Mercury Watch App
//
//  Created by Alessandro Alberti on 12/03/25.
//

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

@Observable
class StickersPickerViewModel {
    var sendService: SendMessageService?
    var recentStickers: [StickerModel]
    var isLoading = true
    
    init(sendService: SendMessageService?) {
        self.sendService = sendService
        self.recentStickers = []
    }
    
    func getStickers() async {
        guard let stickerList = try? await TDLibManager.shared.client?.getRecentStickers(isAttached: false) else { return }
        
        self.recentStickers = stickerList.stickers.map{ StickerModel(sticker: $0) }
        
        self.isLoading = false
        // TODO: Load StickerSets
        // getInstalledStickerSets -> StickerSetInfo
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

    }
}
