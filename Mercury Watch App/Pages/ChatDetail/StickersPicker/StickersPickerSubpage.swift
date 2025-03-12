//
//  StickersPickerSubpage.swift
//  Mercury Watch App
//
//  Created by Alessandro Alberti on 12/03/25.
//

import SwiftUI

struct StickersPickerSubpage: View {
    @State
    @Mockable
    var vm: StickersPickerViewModel
    
    @Binding var isPresented: Bool
    
    let columns = [
        GridItem(.adaptive(minimum: 60))
    ]
    
    init(isPresented: Binding<Bool>, sendService: SendMessageService?) {
        _isPresented = isPresented
        _vm = Mockable.state(
            value: { StickersPickerViewModel(sendService: sendService) },
            mock: { StickersPickerViewModelMock() }
        )
    }
    
    
    var body: some View {
        ScrollView {
            if vm.stickers.isEmpty {
                ProgressView()
                    .task {
                        await vm.getStickers()
                    }
            }
            LazyVGrid(columns: columns, spacing: 3) {
                ForEach(vm.stickers) { model in
                    AsyncView(getData: model.getImage) {
                        Text(model.sticker.emoji)
                            .font(.largeTitle)
                    } buildContent: { image in
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFit()
                    }
                    .onTapGesture {
                        vm.sendService?.sendSticker(model.sticker)
                        isPresented = false
                    }
                }
                
            }
        }
    }
}

#Preview(traits: .mock()) {
    StickersPickerSubpage(isPresented: .constant(true), sendService: SendMessageServiceMock())
}
