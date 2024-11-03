//
//  AvatarView.swift
//  Mercury Watch App
//
//  Created by Alessandro Alberti on 08/05/24.
//

import SwiftUI
import TDLibKit


struct AvatarView_Old: View {
    var model: AvatarModel_Old
    
    init(model: AvatarModel_Old) {
        self.model = model
    }
    
    init(image: TDImage) {
        self.model = AvatarModel_Old(tdImage: image)
    }
    
    var body: some View {
        GeometryReader { proxy in
            let size = proxy.size.width
            let onlineSize = size/5
            let onlineMaskSize = size/3.5
            let onlineOffset = CGSize(
                width: (onlineSize - onlineMaskSize)/2,
                height: (onlineSize - onlineMaskSize)/2
            )
            
            circle(size)
                .mask {
                    Rectangle()
                        .overlay(alignment: .bottomTrailing) {
                            if model.isOnline {
                                Circle()
                                    .frame(width: onlineMaskSize)
                                    .blendMode(.destinationOut)
                            }
                        }
                }
                .overlay(alignment: .bottomTrailing) {
                    if model.isOnline {
                        Circle()
                            .fill(.green)
                            .frame(width: onlineSize)
                            .offset(onlineOffset)
                    }
                }
        }
    }
    
    @ViewBuilder func circle(_ size: CGFloat) -> some View {
        if let image = model.tdImage {
            TdImageView(tdImage: image)
                .clipShape(Circle())
        } else {
            Circle()
                .foregroundStyle(model.color.gradient)
                .overlay {
                    Text(model.letters)
                        .font(.system(size: size/2, weight: .semibold, design: .rounded))
                        .foregroundStyle(.white)
                }
        }
        
    }
}


#if DEBUG
let avatarImageModel = AvatarModel_Old(tdImage: TDImageMock("alessandro"), isOnline: true)
let avatarLettersModel = AvatarModel_Old(letters: "AA", isOnline: true)

#Preview("Big Image") {
    AvatarView_Old(model: avatarImageModel)
        .frame(width: 150, height: 150)
}

#Preview("Small Image") {
    AvatarView_Old(model: avatarImageModel)
        .frame(width: 50, height: 50)
}

#Preview("Big Letters") {
    AvatarView_Old(model: avatarLettersModel)
        .frame(width: 150, height: 150)
}


#Preview("Small Letters") {
    AvatarView_Old(model: avatarLettersModel)
        .frame(width: 50, height: 50)
}

#endif
