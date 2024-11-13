//
//  TdPhotoView.swift
//  Mercury Watch App
//
//  Created by Alessandro Alberti on 17/05/24.
//

import SwiftUI
import TDLibKit

struct TdImageView: View {
    @State private var image: UIImage?
    var tdImage: TDImage
    var showHighRes: Bool = false
    
    
    var body: some View {
        Group {
            if let image {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
            } else {
                Spacer()
            }
        }
        .task {
            if let data = tdImage.minithumbnail?.data {
                self.image = UIImage(data: data)
            }
            
            if let file = tdImage.lowRes {
                self.image = await FileService.getImage(for: file)
            }
            
            if showHighRes, let file = tdImage.highRes {
                self.image = await FileService.getImage(for: file)
            }
            
        }
    }
}
