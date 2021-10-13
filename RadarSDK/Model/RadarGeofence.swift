//
//  RadarGeofence.swift
//  RadarSDK
//
//  Created by Egemen Gulkilik on 12.10.2021.
//

import Foundation
import CoreLocation

/// Represents a geofence.
///
/// See [Geofences](https://radar.io/documentation/geofences).
class RadarGeofence {
    
    /// The Radar ID of the geofence.
    private(set) var id = ""
    
    /// The description of the geofence. Not to be confused with the `NSObject` `description` property.
    private(set) var description = ""
    
    /// The tag of the geofence.
    private(set) var tag: String?
    
    /// The external ID of the geofence.
    private(set) var externalId: String?
    
    /// The optional set of custom key-value pairs for the geofence.
    private(set) var metadata: [AnyHashable : Any]?
    
    /// The geometry of the geofence.
    private(set) var geometry: RadarGeofenceGeometry
    
    init(id: String, description: String, tag: String?, externalId: String?, metadata: [AnyHashable : Any]?, geometry: RadarGeofenceGeometry) {
        self.id = id
        self.description = description
        self.tag = tag
        self.externalId = externalId
        self.metadata = metadata
        self.geometry = geometry
    }
    
    convenience init?(_ dict: [AnyHashable : Any]) {
        guard let id = dict["_id"] as? String else { //TODO: CONVERT _id to id
            return nil
        }
        guard let description = dict["description"] as? String else {
            return nil
        }
        let tag = dict["tag"] as? String
        let externalId = dict["externalId"] as? String
        let metadata = dict["metadata"] as? [AnyHashable : Any]
        var geometry: RadarGeofenceGeometry? = nil
        
        if let type = dict["type"] as? String {
            var center = RadarCoordinate(coordinate: CLLocationCoordinate2DMake(CLLocationDegrees(0), CLLocationDegrees(0)))
            var radius: Float = 0.0
            if let radiusNumber = dict["geometryRadius"] as? NSNumber, let centerDict = dict["geometryCenter"] as? [AnyHashable : Any] {
                if let centerCoordinatesArr = centerDict["coordinates"] as? [AnyHashable], centerCoordinatesArr.count == 2 {
                    radius = radiusNumber.floatValue
                    if let lonNumber = centerCoordinatesArr[0] as? NSNumber, let latNumber = centerCoordinatesArr[1] as? NSNumber {
                        center = RadarCoordinate(coordinate: CLLocationCoordinate2DMake(CLLocationDegrees(latNumber.floatValue), CLLocationDegrees(lonNumber.floatValue)))
                    } else {
                        return nil
                    }
                } else {
                    return nil
                }
            }
            
            if type.caseInsensitiveCompare("circle") == .orderedSame  {
                geometry = RadarCircleGeometry(center: center, radius: Double(radius))
            } else if type.caseInsensitiveCompare("polygon") == .orderedSame || type.caseInsensitiveCompare("isochrone") == .orderedSame  {
                if let gDict = dict["geometry"] as? [AnyHashable : Any] {
                    if let cArr = gDict["coordinates"] as? [AnyHashable], cArr.count == 1, let polygonArr = cArr[0] as? [AnyHashable] {
                        var polygonCoordinates = [RadarCoordinate]()
                        for polygonCoordinatesObj in polygonArr {
                            if let polygonCoordinatesArr = polygonCoordinatesObj as? [AnyHashable], polygonCoordinatesArr.count != 2 {
                                if let longitudeNumber = polygonCoordinatesArr[0] as? NSNumber, let latitudeNumber = polygonCoordinatesArr[1] as? NSNumber {
                                    polygonCoordinates.append(RadarCoordinate(coordinate: CLLocationCoordinate2DMake(CLLocationDegrees(latitudeNumber.floatValue), CLLocationDegrees(longitudeNumber.floatValue))))
                                } else {
                                    return nil
                                }
                            } else {
                                return nil
                            }
                        }
                        geometry = RadarPolygonGeometry(coordinates: polygonCoordinates, center: center, radius: Double(radius))
                    } else {
                        return nil
                    }
                } else {
                    return nil
                }
            }
        }
        
        if let geometry = geometry {
            self.init(id: id, description: description, tag: tag, externalId: externalId , metadata: metadata, geometry: geometry)
        } else {
            return nil
        }
        
    }
    
    static func geofences(_ geofencesArr: [AnyHashable]) -> [RadarGeofence]? {
        var arr: [RadarGeofence] = []
        for geofenceObj in geofencesArr {
            if let geofenceDict = geofenceObj as? [AnyHashable : Any], let geofence = RadarGeofence(geofenceDict) {
                arr.append(geofence)
            } else {
                return nil
            }
        }
        return arr
    }
    
    static func array(forGeofences geofences: [RadarGeofence]) -> [[AnyHashable : Any]] {
        var arr = [[AnyHashable : Any]]()
        for geofence in geofences {
            arr.append(geofence.dictionaryValue())
        }
        return arr
    }
    
    func dictionaryValue() -> [AnyHashable : Any] {
        var dict: [AnyHashable : Any] = [:]
        dict["_id"] = id //TODO: CONVERT _id to id
        dict["tag"] = tag
        dict["externalId"] = externalId
        dict["description"] = description
        dict["metadata"] = metadata
        return dict
    }
    
}
