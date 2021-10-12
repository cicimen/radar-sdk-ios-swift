//
//  RadarCoordinate.swift
//  RadarSDK
//
//  Created by Egemen Gulkilik on 12.10.2021.
//

import CoreLocation
import Foundation

/// Represents a location coordinate.
class RadarCoordinate: NSObject {
    
    /// The coordinate.
    private(set) var coordinate: CLLocationCoordinate2D
    
    
    //TODO: NOT USED ANYWHERE IN SDK
    static func coordinates(fromObject object: Any) -> [RadarCoordinate]? {
        return nil
    }
    
    //TODO: NOT USED ANYWHERE IN SDK
    //init(object: Any?) {
    //
    //}
    
    init(coordinate: CLLocationCoordinate2D) {
        self.coordinate = coordinate
    }
    
    func dictionaryValue() -> [AnyHashable : Any] {
        return [
            "type": "Point",
            "coordinates": [NSNumber(value: coordinate.longitude), NSNumber(value: coordinate.latitude)]
        ]
    }
}

