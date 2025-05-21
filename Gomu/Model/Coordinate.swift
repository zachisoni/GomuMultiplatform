//
//  Coordinate.swift
//  Gomu
//
//  Created by Asad on 16/05/25.
//
import CoreLocation

struct Coordinate: Codable, Hashable {
    var latitude: Double
    var longitude: Double

    init(_ coordinate: CLLocationCoordinate2D) {
        self.latitude = coordinate.latitude
        self.longitude = coordinate.longitude
    }

    var clLocationCoordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
}
