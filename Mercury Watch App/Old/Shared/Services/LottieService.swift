//
//  LottieService.swift
//  Mercury Watch App
//
//  Created by Alessandro Alberti on 11/1/24.
//

import Foundation
import SDWebImageLottieCoder

class LottieHelper {
    
    var frameIndex: Int = 0
    var coder: SDImageLottieCoder?
    let speed: Int
    
    init (lottieJSONData: Data, speed: Int = 1) {
        self.coder = SDImageLottieCoder(
            animatedImageData: lottieJSONData,
            options: [SDImageCoderOption.decodeLottieResourcePath: Bundle.main.resourcePath!]
        )
        self.speed = speed
    }
    
    func getImage() -> UIImage? {
        
        if frameIndex >= coder?.animatedImageFrameCount ?? 0 {
            self.frameIndex = 0
        }
        
        let image = coder?.animatedImageFrame(at: UInt(frameIndex))
        frameIndex += speed
        return image
    }
}
