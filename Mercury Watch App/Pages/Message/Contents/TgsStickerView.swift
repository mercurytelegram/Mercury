//
//  TgsStickerView.swift
//  Mercury Watch App
//
//  Created by Alessandro Alberti on 11/1/24.
//

import SwiftUI
import TDLibKit

struct TgsStickerView: View {
    let sticker: Sticker
    @State private var data: Data?
    var body: some View {
        Group {
            if let data {
                LottieView(from: data)
            } else {
                Text(sticker.emoji)
                    .font(.largeTitle)
            }
        }
        .task {
            if let filePath = await FileService.getFilePath(for: sticker.sticker) {
                let lottieData = FileService.getLottieJson(for: filePath)
                await MainActor.run {
                    self.data = lottieData
                }
            }
        }
        
    }
    
    
}
