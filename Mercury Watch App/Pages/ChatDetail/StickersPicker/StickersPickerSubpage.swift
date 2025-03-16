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
            LazyVGrid(columns: columns, spacing: 3) {
                ForEach(vm.recentStickers) { sticker in
                    stickerCell(for: sticker)
                }
            }
            
            ForEach(vm.stickerPacks) { pack in
                stickerPackCell(for: pack)
            }
            
            if vm.isLoading {
                ProgressView()
            }
        }
        .task {
            await vm.getStickers()
        }
    }
    
    @ViewBuilder
    func stickerCell(for model: StickerModel) -> some View {
        AsyncView(getData: model.getImage) {
            Text(model.sticker?.emoji ?? "")
                .font(.largeTitle)
        } buildContent: { image in
            Image(uiImage: image)
                .resizable()
                .scaledToFit()
        }
        .onTapGesture {
            if let sticker = model.sticker {
                vm.sendService?.sendSticker(sticker)
            }
            isPresented = false
        }
        .clipShape(.rect(cornerRadius: 7))
        .padding(4)
        .background {
            RoundedRectangle(cornerRadius: 10)
                .foregroundStyle(.quaternary)
        }
    }
    
    @ViewBuilder
    func stickerPackCell(for pack: StickerPackModel) -> some View {
        HStack {
            AsyncView(getData: pack.getThumbnail, buildContent: { image in
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
            })
            .frame(width: 50, height: 50)
            .clipShape(.rect(cornerRadius: 10))
            
            VStack(alignment: .leading) {
                Text(pack.title)
                    .font(.title3)
                    .lineLimit(2)
                Text("\(pack.size) stickers")
                    .foregroundStyle(.secondary)
            }
            .padding(.leading)
        }
        .padding(.vertical)
        .frame(maxWidth: .infinity, alignment: .leading)
    }


}

#Preview(traits: .mock()) {
    StickersPickerSubpage(isPresented: .constant(true), sendService: SendMessageServiceMock())
}
