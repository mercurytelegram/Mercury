//
//  AvatarView.swift
//  Mercury
//
//  Created by Marco Tammaro on 03/11/24.
//

import SwiftUI

struct AvatarView: View {
    var model: AvatarModel
    
    init(model: AvatarModel) {
        self.model = model
    }
    
    init(image: AsyncImageModel) {
        self.model = AvatarModel(avatarImage: image)
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
    
    @ViewBuilder
    func circle(_ size: CGFloat) -> some View {
        if let getImage = model.avatarImage?.getImage {
            AsyncView(
                getData: getImage,
                placeholder: { placeholder(size) }
            ) { data in
                Image(uiImage: data)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .clipShape(Circle())
            }
        } else {
            placeholder(size)
        }
        
    }
    
    @ViewBuilder
    func placeholder(_ size: CGFloat) -> some View {
        Circle()
            .foregroundStyle(model.color.gradient)
            .overlay {
                Text(model.letters)
                    .font(.system(size: size/2, weight: .semibold, design: .rounded))
                    .foregroundStyle(.white)
            }
    }
}

struct AvatarModel: Equatable {
    var avatarImage: AsyncImageModel?
    var letters: String = ""
    var color: Color = .blue
    var isOnline: Bool = false
    
    /// The id releated to the TDImage, nil if the avatar represent a group chat
    var userId: Int64? = nil
    
    static func == (lhs: AvatarModel, rhs: AvatarModel) -> Bool {
        return lhs.letters == rhs.letters &&
        lhs.color == rhs.color &&
        lhs.isOnline == rhs.isOnline &&
        lhs.userId == rhs.userId
        //TODO: && lhs.tdImage. == rhs.tdImage
    }
}

extension AvatarModel {
    static var marco: AvatarModel {
        AvatarModel(
            avatarImage: AsyncImageModel(
                thumbnail: UIImage(named: "marco"),
                getImage: { UIImage(named: "marco") }
            )
        )
    }
    
    static var alessandro: AvatarModel {
        AvatarModel(
            avatarImage: AsyncImageModel(
                thumbnail: UIImage(named: "alessandro"),
                getImage: { UIImage(named: "alessandro") }
            )
        )
    }
    
    static var astro: AvatarModel {
        AvatarModel(
            avatarImage: AsyncImageModel(
                thumbnail: UIImage(named: "astro"),
                getImage: { UIImage(named: "astro") }
            )
        )
    }
}


#Preview("Big Image") {
    AvatarView(model: .alessandro)
        .frame(width: 150, height: 150)
}

#Preview("Small Image") {
    AvatarView(model: .marco)
        .frame(width: 50, height: 50)
}

#Preview("Big Letters") {
    AvatarView(model: .init(letters: "AA"))
        .frame(width: 150, height: 150)
}


#Preview("Small Letters") {
    AvatarView(model: .init(letters: "MT"))
        .frame(width: 50, height: 50)
}
