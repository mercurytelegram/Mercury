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
        GridItem(.adaptive(minimum: 50)),
        GridItem(.adaptive(minimum: 50)),
        GridItem(.adaptive(minimum: 50))

    ]
    
    init(isPresented: Binding<Bool>, sendService: SendMessageService?) {
        _isPresented = isPresented
        _vm = Mockable.state(
            value: { StickersPickerViewModel(sendService: sendService) },
            mock: { StickersPickerViewModelMock(sendService: sendService) }
        )
    }
    
    
    var body: some View {
        NavigationStack {
            List {
                LazyVGrid(columns: columns, spacing: 3) {
                    ForEach(vm.recentStickers) { sticker in
                        stickerCell(for: sticker)
                    }
                }
                .padding(.horizontal, -10)
                .padding(.bottom)
                .listRowBackground(Color.clear)
                
                ForEach(vm.stickerPacks) { pack in
                    NavigationLink(value: pack) {
                        stickerPackCell(for: pack)
                    }
                }
                
                if vm.isLoading {
                    ProgressView()
                }
            }
            .navigationTitle("Stickers")
            .toolbarForegroundStyle(.white, for: .navigationBar)
            .navigationDestination(for: StickerPackModel.self) { pack in
                let updatedPack = vm.stickerPacks.first(where: { $0.id == pack.id })!
                stickerPackDetail(for: updatedPack)
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
                .transition(.blurReplace)
                .clipped()
        }
        .onTapGesture {
            vm.sendService?.sendSticker(model)
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
                    .transition(.blurReplace)
                    .clipped()
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
    
    @ViewBuilder
    func stickerPackDetail(for pack: StickerPackModel) -> some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 3) {
                if pack.stickers.isEmpty {
                    ProgressView()
                } else {
                    ForEach(pack.stickers) { sticker in
                        stickerCell(for: sticker)
                    }
                }
            }
        }
        .task {
            await vm.loadStickerPack(pack)
        }
        .navigationTitle(pack.title)
        .toolbarForegroundStyle(.white, for: .navigationBar)
    }

}

#Preview(traits: .mock()) {
    StickersPickerSubpage(isPresented: .constant(true), sendService: SendMessageServiceMock { _ in })
}
