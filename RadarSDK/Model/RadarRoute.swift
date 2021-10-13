//
//  RadarRoute.swift
//  RadarSDK
//
//  Created by Egemen Gulkilik on 13.10.2021.
//

import Foundation

/// Represents a route between an origin and a destination.
///
/// See [Routing](https://radar.io/documentation/api#routing).
class RadarRoute {
    
    // The distance of the route.
    private(set) var distance: RadarRouteDistance
    
    // The duration of the route.
    private(set) var duration: RadarRouteDuration
    
    // The geometry of the route.
    private(set) var geometry: RadarRouteGeometry
    
    init(distance: RadarRouteDistance, duration: RadarRouteDuration, geometry: RadarRouteGeometry) {
        self.distance = distance
        self.duration = duration
        self.geometry = geometry
    }
    
    convenience init?(_ dict: [AnyHashable : Any]) {
        var distance: RadarRouteDistance?
        var duration: RadarRouteDuration?
        var geometry: RadarRouteGeometry?
        
        if let distanceDict = dict["distance"] as? [AnyHashable : Any] {
            distance = RadarRouteDistance(distanceDict)
        }
        
        if let durationDict = dict["duration"] as? [AnyHashable : Any] {
            duration = RadarRouteDuration(durationDict)
        }
        
        if let geometryDict = dict["geometry"] as? [AnyHashable : Any]  {
            geometry = RadarRouteGeometry(geometryDict)
        }
        
        if let distance = distance, let duration = duration, let geometry = geometry {
            self.init(distance: distance, duration: duration, geometry: geometry)
        } else {
            return nil
        }
    }
    
    func dictionaryValue() -> [AnyHashable : Any] {
        var dict: [AnyHashable : Any] = [:]
        dict["distance"] = distance.dictionaryValue()
        dict["duration"] = duration.dictionaryValue()
        dict["geometry"] = geometry.dictionaryValue()
        return dict
    }
    
}
