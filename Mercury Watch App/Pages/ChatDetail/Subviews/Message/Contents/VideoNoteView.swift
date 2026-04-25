//
//  VideoNoteView.swift
//  Mercury Watch App
//
//  Created by Dmytro Manko on 25/04/26.
//

import AVFoundation
import AVKit
import SwiftUI
import WatchKit

struct VideoNoteModel {
    let thumbnail: AsyncImageModel
    let duration: Int
    var isSecret: Bool = false
    var isViewed: Bool = false
    let getVideoURL: () async throws -> URL?
    var onPress: (() -> Void)?
}

struct VideoNotePreviewView: View {
    let model: VideoNoteModel
    let onOpen: () -> Void

    private let previewSize: CGFloat = 112

    var body: some View {
        Button(action: onOpen) {
            ZStack {
                VideoNoteThumbnailView(model: model)
                    .frame(width: previewSize, height: previewSize)
                    .clipShape(Circle())
                    .blur(radius: model.isSecret ? 8 : 0)
                    .overlay {
                        Circle()
                            .stroke(.white.opacity(0.18), lineWidth: 1)
                    }

                Image(systemName: "play.fill")
                    .font(.system(size: 28, weight: .semibold))
                    .foregroundStyle(.white)
                    .shadow(radius: 3)

                VideoNoteDurationBadge(model: model)
                    .frame(width: previewSize, height: previewSize, alignment: .bottomTrailing)
            }
            .frame(width: previewSize, height: previewSize)
        }
        .buttonStyle(.plain)
    }
}

struct VideoNoteView: View {
    let model: VideoNoteModel
    var autoplay: Bool = false
    var showsCloseButton: Bool = true
    var onExpansionChange: ((Bool) -> Void)? = nil
    var onClose: (() -> Void)? = nil

    @State private var isOpening = false
    @State private var isPlaying = false
    @State private var videoURL: URL? = nil
    @State private var playbackProgress: Double = 0
    @State private var playbackStartDate: Foundation.Date? = nil
    @State private var accumulatedPlaybackTime: TimeInterval = 0
    @State private var movieRef: WKInterfaceInlineMovie? = nil

    private var videoSize: CGFloat {
        videoURL == nil ? 112 : 156
    }

    private var isExpanded: Bool {
        videoURL != nil
    }

    var body: some View {
        ZStack {
            playerContent()
                .frame(maxWidth: .infinity, alignment: .center)

            if showsCloseButton {
                closeButton()
                    .frame(
                        maxWidth: .infinity,
                        maxHeight: videoSize,
                        alignment: .topLeading
                    )
            }

        }
        .frame(width: isExpanded ? nil : videoSize, height: videoSize)
        .frame(maxWidth: isExpanded ? .infinity : nil)
        .onReceive(Timer.publish(every: 0.2, on: .main, in: .common).autoconnect()) { _ in
            updateProgress()
        }
        .onDisappear {
            resetPlayback()
        }
        .onAppear {
            if autoplay && videoURL == nil && !isOpening {
                togglePlayback()
            }
        }
        .onChange(of: isExpanded) { _, newValue in
            onExpansionChange?(newValue)
        }
        .animation(.snappy(duration: 0.25), value: videoSize)
        .animation(.snappy(duration: 0.25), value: isExpanded)
    }

    private func playerContent() -> some View {
        ZStack {
            mediaContent()
                .frame(width: videoSize, height: videoSize)
                .clipShape(Circle())
                .blur(radius: model.isSecret && videoURL == nil ? 8 : 0)
                .overlay {
                    Circle()
                        .stroke(.white.opacity(0.18), lineWidth: 1)
                }
                .overlay {
                    progressRing()
                }

            playbackIcon()
                .frame(width: videoSize, height: videoSize)

            VideoNoteDurationBadge(model: model)
                .frame(width: videoSize, height: videoSize, alignment: .bottomTrailing)
        }
        .frame(width: videoSize, height: videoSize)
        .contentShape(Circle())
        .onTapGesture {
            if !isOpening {
                togglePlayback()
            }
        }
    }

    @ViewBuilder
    private func mediaContent() -> some View {
        if let url = videoURL {
            InlineMovieView(url: url, isPlaying: isPlaying, movieRef: $movieRef)
        } else {
            VideoNoteThumbnailView(model: model)
        }
    }

    @ViewBuilder
    private func playbackIcon() -> some View {
        if isOpening {
            ProgressView()
                .tint(.white)
        } else if !isPlaying {
            Image(systemName: "play.fill")
                .font(.system(size: 28, weight: .semibold))
                .foregroundStyle(.white)
                .shadow(radius: 3)
        }
    }

    @ViewBuilder
    private func progressRing() -> some View {
        if videoURL != nil {
            ZStack {
                Circle()
                    .stroke(.white.opacity(0.2), lineWidth: 4)

                Circle()
                    .trim(from: 0, to: playbackProgress)
                    .stroke(
                        .blue,
                        style: StrokeStyle(
                            lineWidth: 4,
                            lineCap: .round
                        )
                    )
                    .rotationEffect(.degrees(-90))
            }
            .padding(2)
        }
    }

    @ViewBuilder
    private func closeButton() -> some View {
        if videoURL != nil {
            Button {
                closePlayback()
            } label: {
                closeButtonLabel()
            }
            .buttonStyle(.plain)
        }
    }

    @ViewBuilder
    private func closeButtonLabel() -> some View {
        let label = Image(systemName: "chevron.left")
            .font(.system(size: 17, weight: .semibold))
            .foregroundStyle(.white)
            .frame(width: 36, height: 36)

        if #available(watchOS 26.0, *) {
            label.glassEffect(.regular, in: Circle())
        } else {
            label.background(.ultraThinMaterial, in: Circle())
        }
    }

    private func togglePlayback() {
        if videoURL != nil {
            if isPlaying {
                pausePlayback()
            } else {
                playbackStartDate = Foundation.Date()
                isPlaying = true
                movieRef?.play()
            }
            return
        }

        Task {
            await MainActor.run {
                model.onPress?()
                isOpening = true
            }

            defer {
                Task { @MainActor in
                    isOpening = false
                }
            }

            guard let url = try? await model.getVideoURL() else { return }

            try? AVAudioSession.sharedInstance().setCategory(.playback, mode: .moviePlayback)
            try? AVAudioSession.sharedInstance().setActive(true)

            await MainActor.run {
                self.videoURL = url
                self.isPlaying = true
                self.playbackProgress = 0
                self.playbackStartDate = Foundation.Date()
                self.accumulatedPlaybackTime = 0
            }
        }
    }

    private func pausePlayback() {
        if let playbackStartDate {
            accumulatedPlaybackTime += Foundation.Date().timeIntervalSince(playbackStartDate)
        }
        movieRef?.pause()
        playbackStartDate = nil
        isPlaying = false
    }

    private func resetPlayback() {
        movieRef?.pause()
        movieRef = nil
        videoURL = nil
        playbackStartDate = nil
        isPlaying = false
        playbackProgress = 0
        accumulatedPlaybackTime = 0
        try? AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
    }

    private func closePlayback() {
        resetPlayback()
        onClose?()
    }

    private func updateProgress() {
        guard videoURL != nil else { return }

        let duration = TimeInterval(model.duration)
        guard duration > 0 else { return }

        let activePlaybackTime: TimeInterval
        if isPlaying, let playbackStartDate {
            activePlaybackTime = accumulatedPlaybackTime + Foundation.Date().timeIntervalSince(playbackStartDate)
        } else {
            activePlaybackTime = accumulatedPlaybackTime
        }

        playbackProgress = min(max(activePlaybackTime / duration, 0), 1)

        if playbackProgress >= 0.99, isPlaying {
            resetPlayback()
        }
    }
}

// MARK: - InlineMovieView

private struct InlineMovieView: WKInterfaceObjectRepresentable {
    let url: URL
    let isPlaying: Bool
    @Binding var movieRef: WKInterfaceInlineMovie?

    func makeWKInterfaceObject(context: Context) -> WKInterfaceInlineMovie {
        let movie = WKInterfaceInlineMovie()
        movie.setMovieURL(url)
        movie.setLoops(false)
        movie.setAutoplays(false)
        DispatchQueue.main.async {
            movieRef = movie
            if isPlaying {
                movie.playFromBeginning()
            }
        }
        return movie
    }

    func updateWKInterfaceObject(_ movie: WKInterfaceInlineMovie, context: Context) {
        if isPlaying {
            movie.play()
        } else {
            movie.pause()
        }
    }
}

// MARK: - Supporting Views

private struct VideoNoteDurationBadge: View {
    let model: VideoNoteModel

    var body: some View {
        HStack(spacing: 4) {
            if !model.isViewed {
                Circle()
                    .fill(.blue)
                    .frame(width: 6, height: 6)
            }

            Text(duration)
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(.white)
        }
        .padding(.horizontal, 7)
        .padding(.vertical, 3)
        .background(.ultraThinMaterial, in: Capsule())
        .padding(5)
    }

    private var duration: String {
        let seconds = model.duration % 60
        let minutes = model.duration / 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}

private struct VideoNoteThumbnailView: View {
    let model: VideoNoteModel

    var body: some View {
        AsyncView(getData: model.thumbnail.getImage) {
            Group {
                if let thumbnail = model.thumbnail.thumbnail {
                    Image(uiImage: thumbnail)
                        .resizable()
                        .scaledToFill()
                } else {
                    ZStack {
                        Color.black.opacity(0.35)

                        Image(systemName: "video.circle.fill")
                            .font(.system(size: 40))
                            .foregroundStyle(.white.opacity(0.6))
                    }
                }
            }
        } buildContent: { image in
            Image(uiImage: image)
                .resizable()
                .scaledToFill()
        }
    }
}
