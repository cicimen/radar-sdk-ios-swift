//
//  RadarTripOptions.swift
//  RadarSDK
//
//  Created by Egemen Gulkilik on 12.10.2021.
//

import Foundation


let kExternalId = "externalId"
let kRadarTripOptionsMetadata = "metadata"
let kDestinationGeofenceTag = "destinationGeofenceTag"
let kDestinationGeofenceExternalId = "destinationGeofenceExternalId"
let kMode = "mode"

/// An options class used to configure trip tracking.
///
/// See [Docs](https://radar.io/documentation/sdk/ios) .
public class RadarTripOptions {
    
    /// A stable unique ID for the trip.
    var externalId = ""
    
    /// An optional set of custom key-value pairs for the trip.
    var metadata: [AnyHashable : Any]?
    
    /// For trips with a destination, the tag of the destination geofence.
    var destinationGeofenceTag: String?
    
    /// For trips with a destination, the external ID of the destination geofence.
    var destinationGeofenceExternalId: String?
    
    /// For trips with a destination, the travel mode.
    var mode: RadarRouteMode
    
    init(externalId: String, destinationGeofenceTag: String?, destinationGeofenceExternalId: String?) {
        self.externalId = externalId
        self.destinationGeofenceTag = destinationGeofenceTag
        self.destinationGeofenceExternalId = destinationGeofenceExternalId
        mode = .car
    }
    
    convenience init(fromDictionary dict: [AnyHashable : Any]) {
        self.init(externalId: dict[kExternalId] as? String ?? "",
                  destinationGeofenceTag: dict[kDestinationGeofenceTag] as? String,
                  destinationGeofenceExternalId: dict[kDestinationGeofenceExternalId] as? String)
        metadata = dict[kMetadata] as?  [AnyHashable : Any]
        let modeStr = dict[kMode] as? String
        if modeStr == "foot" {
            mode = .foot
        } else if modeStr == "bike" {
            mode = .bike
        } else if modeStr == "truck" {
            mode = .truck
        } else if modeStr == "motorbike" {
            mode = .motorbike
        } else {
            mode = .car
        }
    }
    
    func dictionaryValue() -> [AnyHashable : Any] {
        var dict: [AnyHashable : Any] = [:]
        dict[kExternalId] = externalId
        dict[kMetadata] = metadata
        dict[kDestinationGeofenceTag] = destinationGeofenceTag
        dict[kDestinationGeofenceExternalId] = destinationGeofenceExternalId
        dict[kMode] = Radar.stringForMode(mode)
        return dict
    }
}

