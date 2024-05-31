//
//  TdPhotoView.swift
//  Mercury Watch App
//
//  Created by Alessandro Alberti on 17/05/24.
//

import SwiftUI
import TDLibKit

struct TdPhotoView: View {
    @State private var image: Image?
    var tdPhoto: Photo
    
    
    var body: some View {
        Group {
            if let image {
                image
                    .resizable()
                    .aspectRatio(contentMode: .fit)
            } else {
                Spacer()
            }
        }
        .task {
            if let data = tdPhoto.minithumbnail?.data,
               let uiImage = UIImage(data: data) {
                self.image = Image(uiImage: uiImage)
            }
            
            if let file = tdPhoto.sizes.first?.photo {
                self.image = await FileService.getImage(for: file)
            }
            
        }
    }
}

//#Preview {
//    TdPhotoView()
//}
