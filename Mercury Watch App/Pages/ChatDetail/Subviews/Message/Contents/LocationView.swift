//
//  LocationView.swift
//  Mercury Watch App
//
//  Created by Alessandro Alberti on 09/08/24.
//

import SwiftUI
import MapKit
import TDLibKit

struct LocationView: View {
    
    let model: LocationModel
    
    var camera: MapCamera {
        var editCoord = model.coordinate
        if model.shiftCenter {
            editCoord.latitude += 0.00015
        }
        return MapCamera(centerCoordinate: editCoord, distance: 200)
    }
    
    var body: some View {
        Map(position: .constant(.camera(camera)), interactionModes: []) {
            Marker(model.title, systemImage: model.markerSymbol, coordinate: model.coordinate)
                .tint(model.color ?? .red)
        }
        .mapStyle(.hybrid(pointsOfInterest: .excludingAll))
        .frame(height: model.shiftCenter ? 130 : 100)
    }
}

struct LocationModel: Equatable, Hashable {
    var title: String = ""
    var coordinate: CLLocationCoordinate2D
    var color: Color?
    var markerSymbol: String = "mapin"
    var shiftCenter: Bool = false
    
    static func == (lhs: LocationModel, rhs: LocationModel) -> Bool {
        return lhs.title == rhs.title &&
        lhs.coordinate.latitude == rhs.coordinate.latitude &&
        lhs.coordinate.longitude == rhs.coordinate.longitude &&
        lhs.markerSymbol == rhs.markerSymbol &&
        lhs.shiftCenter == rhs.shiftCenter
    }
    
    func hash(into hasher: inout Hasher) {
            hasher.combine(title)
            hasher.combine(coordinate.latitude)
            hasher.combine(coordinate.longitude)
            hasher.combine(markerSymbol)
            hasher.combine(shiftCenter)
        }
}

#Preview {
    LocationView(
        model: .init(
            title: "",
            coordinate: CLLocationCoordinate2DMake(
                37.33187132756376,
                -122.02965972794414
            ),
            markerSymbol: ""
        )
    )
}

#Preview {
    LocationView(
        model: .init(
            title: "",
            coordinate: CLLocationCoordinate2DMake(
                37.33187132756376,
                -122.02965972794414
            ),
            color: .white,
            markerSymbol: ""
        )
    )
}
