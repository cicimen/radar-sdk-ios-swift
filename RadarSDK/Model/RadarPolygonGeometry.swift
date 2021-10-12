//
//  RadarPolygonGeometry.swift
//  RadarSDK
//
//  Created by Egemen Gulkilik on 12.10.2021.
//

import Foundation

/// Represents the geometry of polygon geofence.
class RadarPolygonGeometry: RadarGeofenceGeometry {
    
    /// The geometry of the polygon geofence. A closed ring of coordinates.
    private(set) var coordinates: [RadarCoordinate]?
    
    /// The calculated centroid of the polygon geofence.
    private(set) var center: RadarCoordinate
    
    /// The calculated radius of the polygon geofence in meters.
    private(set) var radius = 0.0
    
    init(coordinates: [RadarCoordinate]?, center: RadarCoordinate, radius: Double) {
        self.coordinates = coordinates
        self.center = center
        self.radius = radius
    }
    
}
