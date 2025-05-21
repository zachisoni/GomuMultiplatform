//
//  MapView.swift
//  Gomu
//
//  Created by Asad on 14/05/25.
//

import SwiftUI
import MapKit

struct MapView: View {
    @ObservedObject var locationManager: LocationManager
    let initPosition = CLLocationCoordinate2D(latitude: -6.1754, longitude: 106.8272)
    var body: some View {
        Map(position: .constant(
            MapCameraPosition.region(
                MKCoordinateRegion(
                    center: locationManager.coordinates.last ?? initPosition,
                    span: MKCoordinateSpan(latitudeDelta: 0.005, longitudeDelta: 0.005)
                )
            )
        )){
            Annotation(
                "Your Location",
                coordinate: locationManager.coordinates.last ?? initPosition
            ){
                Image(systemName: "figure.walk")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 20, height: 20)
                    .padding(10)
                    .foregroundStyle(Color.white)
                    .background(Color.red)
                    .clipShape(Circle())
            }
            MapPolyline(coordinates: locationManager.coordinates, contourStyle: .straight)
                .stroke(.blue, lineWidth: 5)
        }
        .preferredColorScheme(.light)
    }
}
