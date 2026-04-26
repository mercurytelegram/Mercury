//
//  AnimationView.swift
//  Mercury Watch App
//
//  Created by Dmytro Manko on 26/04/26.
//

import SwiftUI
import WatchKit
import AVFoundation

// MARK: - AnimationModel

struct AnimationModel {
    let thumbnail: AsyncImageModel
    let getVideoURL: () async throws -> URL?
}

// MARK: - AnimationView

struct AnimationView: View {
    let model: AnimationModel
    
    @State private var videoURL: URL? = nil
    @State private var movieRef: WKInterfaceInlineMovie? = nil
    @State private var isLoading = false
    @State private var playTrigger = false
    
    var aspectRatio: CGFloat? {
        if let size = model.thumbnail.thumbnail?.size, size.height > 0 {
            return size.width / size.height
        }
        return nil
    }
    
    var body: some View {
        ZStack {
            if let url = videoURL {
                InlineMovieView(url: url, isPlaying: true, loops: true, autoplays: true, movieRef: $movieRef)
            } else {
                AsyncView(getData: model.thumbnail.getImage) {
                    Group {
                        if let thumbnail = model.thumbnail.thumbnail {
                            Image(uiImage: thumbnail)
                                .resizable()
                                .scaledToFill()
                        } else {
                            ZStack {
                                Color.black.opacity(0.35)
                                ProgressView()
                            }
                        }
                    }
                } buildContent: { image in
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                }
                
                if isLoading {
                    ProgressView()
                }
            }
        }
        .aspectRatio(aspectRatio, contentMode: .fit)
        .clipped()
        .onAppear {
            loadAnimation()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                movieRef?.playFromBeginning()
            }
        }
    }
    
    private func loadAnimation() {
        guard videoURL == nil && !isLoading else { return }
        
        isLoading = true
        Task {
            do {
                if let url = try await model.getVideoURL() {
                    try? AVAudioSession.sharedInstance().setCategory(.playback, mode: .moviePlayback)
                    try? AVAudioSession.sharedInstance().setActive(true)
                    
                    await MainActor.run {
                        self.videoURL = url
                        self.isLoading = false
                    }
                } else {
                    await MainActor.run { self.isLoading = false }
                }
            } catch {
                await MainActor.run { self.isLoading = false }
            }
        }
    }
}
