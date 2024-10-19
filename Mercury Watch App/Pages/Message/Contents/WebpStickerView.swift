//
//  WebpStickerView.swift
//  Mercury Watch App
//
//  Created by Alessandro Alberti on 10/19/24.
//

import SwiftUI
import TDLibKit
import SDWebImageWebPCoder

struct WebpStickerView: View {
    @State private var image: UIImage?
    var sticker: Sticker
    
    var body: some View {
        Group {
            if let image {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
            } else {
                Text(sticker.emoji)
                    .font(.largeTitle)
            }
        }.task {
            await loadSticker()
        }
    }
    
    
    func loadSticker() async {
        guard let filePath = await FileService.getFilePath(for: sticker.sticker),
              let data = try? Data(contentsOf: filePath),
              let image = SDImageWebPCoder.shared.decodedImage(with: data, options: nil)
        else { return }
        
        await MainActor.run {
            withAnimation {
                self.image = image
            }
        }
        
    }
}
