//
//  LottieView.swift
//  Mercury Watch App
//
//  Created by Alessandro Alberti on 11/1/24.
//

import SwiftUI

struct LottieView: View {
    let lottie: LottieHelper
    
    init(from data: Data) {
        self.lottie = LottieHelper(lottieJSONData: data, speed: 3)
    }
    
    var body: some View {
        TimelineView(.animation(minimumInterval: 1/20)) { _ in
            
            if let image = lottie.getImage() {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
            }
            
        }
    }
}

#Preview {
    if let sticker = Bundle.main.url(
        forResource: "sticker",
        withExtension: "tgs"
    ), let data = FileService.getLottieJson(for: sticker) {
        return LottieView(from: data)
    }
    return Text("error decoding tgs")
}
