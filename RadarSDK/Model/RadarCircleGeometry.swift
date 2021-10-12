//
//  RadarCircleGeometry.swift
//  RadarSDK
//
//  Created by Egemen Gulkilik on 12.10.2021.
//

import Foundation
import UIKit

/// Represents the geometry of a circle geofence.
class RadarCircleGeometry: RadarGeofenceGeometry {
    
    /// The center of the circle geofence.
    private(set) var center: RadarCoordinate
    
    /// The radius of the circle geofence in meters.
    private(set) var radius = 0.0
    
    init(center: RadarCoordinate, radius: Double) {
        self.center = center
        self.radius = radius
    }
}

