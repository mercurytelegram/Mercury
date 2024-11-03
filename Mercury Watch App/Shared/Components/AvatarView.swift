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
    
    init(image: TDImage) {
        self.model = AvatarModel(tdImage: image)
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

struct AvatarModel {
    var tdImage: TDImage?
    var letters: String = ""
    var color: Color = .blue
    var isOnline: Bool = false
    
    /// The id releated to the TDImage, nil if the avatar represent a group chat
    var userId: Int64? = nil
}

extension AvatarModel {
    static var marco: AvatarModel {
        AvatarModel(
            tdImage: TDImageMock("marco")
        )
    }
    
    static var alessandro: AvatarModel {
        AvatarModel(
            tdImage: TDImageMock("alessandro")
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