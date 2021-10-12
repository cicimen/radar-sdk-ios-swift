//
//  RadarBeacon.swift
//  RadarSDK
//
//  Created by Egemen Gulkilik on 12.10.2021.
//

import Foundation
import CoreLocation

/// Represents a Bluetooth beacon.
///
/// See [Beacons](https://radar.io/documentation/beacons) .
class RadarBeacon {
    
    // The Radar ID of the beacon.
    private(set) var id = ""
    
    // The description of the beacon. Not to be confused with the `NSObject` `description` property.
    private(set) var description = ""
    
    // The tag of the beacon.
    private(set) var tag: String?
    
    // The external ID of the beacon.
    private(set) var externalId: String?
    
    // The UUID of the beacon.
    private(set) var uuid = ""
    
    // The major ID of the beacon.
    private(set) var major = ""
    
    // The minor ID of the beacon.
    private(set) var minor = ""
    
    // The optional set of custom key-value pairs for the beacon.
    private(set) var metadata: [AnyHashable : Any]?
    
    // The location of the beacon.
    private(set) var geometry: RadarCoordinate
    
    init(id: String, description: String, tag: String, externalId: String, uuid: String, major: String, minor: String, metadata: [AnyHashable : Any]?, geometry: RadarCoordinate) {
        self.id = id
        self.description = description
        self.tag = tag
        self.externalId = externalId
        self.uuid = uuid
        self.major = major
        self.minor = minor
        self.metadata = metadata
        self.geometry = geometry
    }
    
    convenience init?(_ dict: [AnyHashable : Any]) {
        let id = dict["_id"] as? String  //TODO: CONVERT _id to id
        let description = dict["description"] as? String
        let tag = dict["tag"] as? String
        let externalId = dict["externalId"] as? String
        let uuid = dict["uuid"] as? String
        let major = dict["major"] as? String
        let minor = dict["minor"] as? String
        let metadata = dict["metadata"] as? [AnyHashable : Any]
        var geometry = RadarCoordinate(coordinate: CLLocationCoordinate2DMake(CLLocationDegrees(0), CLLocationDegrees(0)))
        
        if let geometryDict = dict["geometry"] as? [AnyHashable : Any] {
            if let geometryCoordinatesArr = geometryDict["coordinates"] as? [AnyHashable], geometryCoordinatesArr.count == 2 {
                if let longitudeNumber = geometryCoordinatesArr[0] as? NSNumber, let latitudeNumber = geometryCoordinatesArr[1] as? NSNumber {
                    geometry = RadarCoordinate(coordinate: CLLocationCoordinate2DMake(CLLocationDegrees(latitudeNumber.floatValue), CLLocationDegrees(longitudeNumber.floatValue)))
                } else {
                    return nil
                }
            } else {
                return nil
            }
        }
        
        if let id = id, let description = description, let tag = tag, let externalId = externalId, let uuid = uuid, let major = major, let minor = minor  {
            self.init(id: id, description: description, tag: tag , externalId: externalId, uuid: uuid, major: major, minor: minor, metadata: metadata, geometry: geometry)
        } else {
            return nil
        }
    }
    
    static func beacons(_ beaconsArr: [AnyHashable]) -> [RadarBeacon]? {
        var arr: [RadarBeacon] = []
        for beaconObj in beaconsArr {
            if let beaconDict = beaconObj as? [AnyHashable : Any], let beacon = RadarBeacon(beaconDict) {
                arr.append(beacon)
            } else {
                return nil
            }
        }
        return arr
    }
    
    static func array(forBeacons beacons: [RadarBeacon]) -> [[AnyHashable : Any]] {
        var arr = [[AnyHashable : Any]]()
        for beacon in beacons {
            arr.append(beacon.dictionaryValue())
        }
        return arr
    }
    
    func dictionaryValue() -> [AnyHashable : Any] {
        var dict: [AnyHashable : Any] = [:]
        dict["_id"] = id   //TODO: CONVERT _id to id
        dict["description"] = description
        dict["tag"] = tag
        dict["externalId"] = externalId
        dict["uuid"] = uuid
        dict["minor"] = minor
        dict["metadata"] = metadata
        return dict
    }

}
