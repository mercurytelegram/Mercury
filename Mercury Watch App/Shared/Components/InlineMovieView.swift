import SwiftUI
import WatchKit

struct InlineMovieView: WKInterfaceObjectRepresentable {
    let url: URL
    let isPlaying: Bool
    let loops: Bool
    let autoplays: Bool
    @Binding var movieRef: WKInterfaceInlineMovie?

    init(url: URL, isPlaying: Bool, loops: Bool = false, autoplays: Bool = false, movieRef: Binding<WKInterfaceInlineMovie?> = .constant(nil)) {
        self.url = url
        self.isPlaying = isPlaying
        self.loops = loops
        self.autoplays = autoplays
        self._movieRef = movieRef
    }

    func makeWKInterfaceObject(context: Context) -> WKInterfaceInlineMovie {
        let movie = WKInterfaceInlineMovie()
        movie.setMovieURL(url)
        movie.setLoops(loops)
        movie.setAutoplays(autoplays)
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
