//
//  LocationContentView.swift
//  Mercury Watch App
//
//  Created by Alessandro Alberti on 09/08/24.
//

import SwiftUI
import MapKit
import TDLibKit

struct LocationContentView_Old: View {
    @EnvironmentObject var vm: MessageViewModel_Old
    var title: String
    var coordinate: CLLocationCoordinate2D
    var color: Color?
    var markerSymbol: String
    
    var camera: MapCamera {
        var editCoord = coordinate
        if vm.showSender {
            editCoord.latitude += 0.00015
        }
        return MapCamera(centerCoordinate: editCoord, distance: 200)
    }
    
    var body: some View {
        Map(position: .constant(.camera(camera)), interactionModes: []) {
            Marker(title, systemImage: markerSymbol, coordinate: coordinate)
                .tint(color ?? .red)
        }
        .mapStyle(.hybrid(pointsOfInterest: .excludingAll))
        .frame(height: vm.showSender ? 130 : 100)
    }
    
    init(title: String = "", coordinate: CLLocationCoordinate2D, color: Color? = nil, markerSymbol: String = "mapin") {
        self.title = title
        self.coordinate = coordinate
        self.color = color
        self.markerSymbol = markerSymbol
    }
    
    init(venue: Venue) {
        self.title = venue.title
        self.coordinate = CLLocationCoordinate2D(latitude: venue.location.latitude, longitude: venue.location.longitude)
        switch venue.type {
        case "arts_entertainment/museum":
            self.color = .pink
            self.markerSymbol = "building.columns.fill"
        case "travel/hotel":
            self.color = .purple
            self.markerSymbol = "bed.double.fill"
        case let type where type.contains("food"):
            self.color = .orange
            self.markerSymbol = "fork.knife"
        case let type where type.contains("parks_outdoors"):
            self.color = .green
            self.markerSymbol = "tree.fill"
        case let type where type.contains("shops"):
            self.color = .yellow
            self.markerSymbol = "bag.fill"
        case let type where type.contains("building"):
            self.color = .gray
            self.markerSymbol = "building.2.fill"
        default:
            self.color = .red
            self.markerSymbol = "mapin"
        }
    }
}

#Preview {
    LocationContentView_Old(coordinate: CLLocationCoordinate2DMake(
        37.33187132756376, -122.02965972794414))
    .environmentObject(MessageViewModelMock() as MessageViewModel_Old)
}

#Preview {
    LocationContentView_Old(
        title: "",
        coordinate: CLLocationCoordinate2DMake(
        37.33187132756376, -122.02965972794414),
        color: .white,
        markerSymbol: ""
    )
    .environmentObject(MessageViewModelMock() as MessageViewModel_Old)
}
