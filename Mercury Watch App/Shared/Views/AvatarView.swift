//
//  AvatarView.swift
//  Mercury Watch App
//
//  Created by Alessandro Alberti on 08/05/24.
//

import SwiftUI
import TDLibKit


struct AvatarView: View {
    var model: AvatarModel
    @State private var image: Image?
    
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
        .task {
            guard let photo = model.tdPhoto else { return }
            
            // Thumbnail
            if let imageData = photo.minithumbnail?.data,
               let uiImage = UIImage(data: imageData) {
                self.image = Image(uiImage: uiImage)
            }
            // Small
            self.image = await FileService.getImage(for: photo.small)
        }
    }
    
    @ViewBuilder func circle(_ size: CGFloat) -> some View {
        if let image {
            image
                .resizable()
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
let avatarImageModel = AvatarModel(isOnline: true)
let avatarLettersModel = AvatarModel(letters: "AA", isOnline: true)

#Preview("Big Image") {
    AvatarView(model: avatarImageModel)
        .frame(width: 150, height: 150)
}

#Preview("Small Image") {
    AvatarView(model: avatarImageModel)
        .frame(width: 50, height: 50)
}

#Preview("Big Letters") {
    AvatarView(model: avatarLettersModel)
        .frame(width: 150, height: 150)
}


#Preview("Small Letters") {
    AvatarView(model: avatarLettersModel)
        .frame(width: 50, height: 50)
}

#endif
