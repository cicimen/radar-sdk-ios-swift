//
//  RadarRouteGeometry.swift
//  RadarSDK
//
//  Created by Egemen Gulkilik on 13.10.2021.
//

import Foundation
import CoreLocation

/// Represents the geometry of a route.
class RadarRouteGeometry {
    
    /// The geometry of the route.
    private(set) var coordinates: [RadarCoordinate]?
    
    private init(coordinates: [RadarCoordinate]) {
        self.coordinates = coordinates
    }
    
    convenience init?(_ dict: [AnyHashable : Any]) {
        var arr = [RadarCoordinate]()
        if let coordinatesArr = dict["coordinates"] as? [AnyHashable] {
            for coordinateObj in coordinatesArr {
                if let coordinateArr = coordinateObj as? [AnyHashable], coordinateArr.count == 2 {
                    if let longitudeNumber = coordinateArr[0] as? NSNumber, let latitudeNumber = coordinateArr[1] as? NSNumber  {
                        arr.append(RadarCoordinate(coordinate: CLLocationCoordinate2DMake(CLLocationDegrees(latitudeNumber.floatValue), CLLocationDegrees(longitudeNumber.floatValue))))
                    } else {
                        return nil
                    }
                } else {
                    return nil
                }
            }
        } else {
            return nil
        }
        self.init(coordinates: arr)
    }
    
    func dictionaryValue() -> [AnyHashable : Any] {
        var dict: [AnyHashable : Any] = [:]
        dict["type"] = "LineString"
        if let coordinates = coordinates {
            var mutableCoordinates: [[AnyHashable]] = []
            for coordinate in coordinates {
                mutableCoordinates.append([coordinate.coordinate.longitude, coordinate.coordinate.latitude])
            }
            dict["coordinates"] = mutableCoordinates
        }
        return dict
    }
}
