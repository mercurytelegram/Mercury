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

struct StickerPickerModel: Identifiable {
    let id = UUID()
    var sticker: Sticker
    
    func getImage() async -> UIImage? {
        guard let filePath = await FileService.getFilePath(for: sticker.sticker),
              let data = try? Data(contentsOf: filePath)
        else { return nil }
        return SDImageWebPCoder.shared.decodedImage(with: data, options: nil)
    }
}

@Observable
class StickersPickerViewModel {
    var stickers: [StickerPickerModel]
    var sendService: SendMessageService?
    
    init(sendService: SendMessageService?) {
        self.sendService = sendService
        self.stickers = []
    }
    
    func getStickers() async {
        guard let stickerList = try? await TDLibManager.shared.client?.getRecentStickers(isAttached: false) else { return }
        
        self.stickers = stickerList.stickers.map{ StickerPickerModel(sticker: $0) }
        
        // TODO: Load StickerSets
        // getInstalledStickerSets -> StickerSetInfo
    }
}

class StickersPickerViewModelMock: StickersPickerViewModel {
    init() {
        super.init(sendService: SendMessageServiceMock())
    }
}
