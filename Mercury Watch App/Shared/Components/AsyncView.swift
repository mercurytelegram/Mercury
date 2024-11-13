//
//  AsyncView.swift
//  Mercury Watch App
//
//  Created by Alessandro Alberti on 11/7/24.
//

import SwiftUI

struct AsyncView<Content: View, Placeholder: View, Data>: View {
    @State private var data: Data? = nil
    
    let getData: () async throws -> Data?
    var placeholder: () -> Placeholder
    let content: (Data) -> Content?
    
    init(
        getData: @escaping () async throws -> Data?,
        placeholder: @escaping () -> Placeholder = { ProgressView() },
        buildContent: @escaping (Data) -> Content
    ) {
        self.placeholder = placeholder
        self.getData = getData
        self.content = buildContent
    }
    
    var body: some View {
        if let data {
            content(data)
        } else {
            placeholder()
                .task {
                    let loadedData = try? await getData()
                    await MainActor.run {
                        withAnimation {
                            self.data = loadedData
                        }
                    }
                }
        }
    }
}

struct AsyncImageModel {
    let thumbnail: UIImage?
    let getImage: () async throws -> UIImage?
}


#Preview("Loader") {
    AsyncView(getData: getAsyncPreviewImage) { image in
        return Image(uiImage: image)
            .resizable()
            .aspectRatio(contentMode: .fit)
    }
}

#Preview("Placeholder") {
    AsyncView(getData: getAsyncPreviewImage) {
        Text("Placeholder...")
    } buildContent: { image in
        return Image(uiImage: image)
            .resizable()
            .aspectRatio(contentMode: .fit)
    }
}

#Preview("Error") {
    AsyncView(getData: getAsyncPreviewResult) {
        Text("Placeholder...")
    } buildContent: { result in
        Group {
            switch result {
            case .success(let image):
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
            case .failure(let error):
                Text("Error...")
            }
        }
    }
}

private func getAsyncPreviewImage() async throws -> UIImage? {
    let second: UInt64 = 1_000_000_000
    try? await Task.sleep(nanoseconds: 3 * second)
    
    return UIImage(named: "astro")
}

private func getAsyncPreviewResult() async throws -> Result<UIImage, Error> {
    let second: UInt64 = 1_000_000_000
    try? await Task.sleep(nanoseconds: 3 * second)
    
    return .failure(NSError(domain: "", code: 0))
}
