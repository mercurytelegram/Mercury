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
        if model.style == .savedMessages {
            savedMessagesPlaceholder(size)
        } else if let getImage = model.avatarImage?.getImage {
            AsyncView(
                getData: getImage,
                placeholder: {
                    Group {
                        if let thumbnail = model.avatarImage?.thumbnail {
                            Image(uiImage: thumbnail)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .if(!model.isFullScreen) {
                                    $0.clipShape(Circle())
                                }
                            
                        } else {
                            placeholder(size)
                        }
                    }
                }
            ) { data in
                Image(uiImage: data)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .if(!model.isFullScreen) {
                        $0.clipShape(Circle())
                    }
            }
            .id(model.avatarImage?.thumbnail)
        } else {
            placeholder(size)
        }
        
    }
    
    @ViewBuilder
    func placeholder(_ size: CGFloat) -> some View {
        
        Group {
            if model.isFullScreen {
                Rectangle()
            } else {
                Circle()
            }
        }
            .foregroundStyle(model.color.gradient)
            .overlay {
                Text(model.letters)
                    .font(.system(size: size/2, weight: .semibold, design: .rounded))
                    .foregroundStyle(.white)
            }
    }
    
    @ViewBuilder
    func savedMessagesPlaceholder(_ size: CGFloat) -> some View {
        Group {
            if model.isFullScreen {
                Rectangle()
            } else {
                Circle()
            }
        }
        .foregroundStyle(
            LinearGradient(
                colors: [
                    Color(red: 0.17, green: 0.62, blue: 0.98),
                    Color(red: 0.08, green: 0.44, blue: 0.89)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .overlay {
            BookmarkShape()
                .fill(.white)
                .frame(width: size * 0.34, height: size * 0.48)
                .offset(y: -size * 0.01)
        }
    }
}

private struct BookmarkShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let cornerRadius = min(rect.width, rect.height) * 0.16
        let notchDepth = rect.height * 0.22
        
        path.move(to: CGPoint(x: rect.minX + cornerRadius, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX - cornerRadius, y: rect.minY))
        path.addQuadCurve(
            to: CGPoint(x: rect.maxX, y: rect.minY + cornerRadius),
            control: CGPoint(x: rect.maxX, y: rect.minY)
        )
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.midX, y: rect.maxY - notchDepth))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.minY + cornerRadius))
        path.addQuadCurve(
            to: CGPoint(x: rect.minX + cornerRadius, y: rect.minY),
            control: CGPoint(x: rect.minX, y: rect.minY)
        )
        path.closeSubpath()
        
        return path
    }
}

struct AvatarModel: Equatable {
    enum Style {
        case standard
        case savedMessages
    }
    
    var avatarImage: AsyncImageModel?
    var letters: String = ""
    var color: Color = .blue
    var isOnline: Bool = false
    var isFullScreen = false
    var style: Style = .standard
    
    /// The id releated to the TDImage, nil if the avatar represent a group chat
    var userId: Int64? = nil
    
    static func == (lhs: AvatarModel, rhs: AvatarModel) -> Bool {
        return lhs.letters == rhs.letters &&
        lhs.color == rhs.color &&
        lhs.isOnline == rhs.isOnline &&
        lhs.isFullScreen == rhs.isFullScreen &&
        lhs.style == rhs.style &&
        lhs.userId == rhs.userId &&
        lhs.avatarImage == rhs.avatarImage
    }
}

extension AvatarModel {
    static func savedMessages(isFullScreen: Bool = false) -> AvatarModel {
        AvatarModel(isFullScreen: isFullScreen, style: .savedMessages)
    }
    
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
    
    static func huston(isFullScreen: Bool = false) -> AvatarModel {
        AvatarModel(
            avatarImage: AsyncImageModel(
                thumbnail: UIImage(named: "huston"),
                getImage: { UIImage(named: "huston") }
            ), isFullScreen: isFullScreen
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
    AvatarView(model: .init(letters: "AA", isFullScreen: true))
        .frame(width: 150, height: 150)
}


#Preview("Small Letters") {
    AvatarView(model: .init(letters: "MT"))
        .frame(width: 50, height: 50)
}

#Preview("Saved Messages") {
    AvatarView(model: .savedMessages())
        .frame(width: 80, height: 80)
}
