//
//  RadarTrip.swift
//  RadarSDK
//
//  Created by Egemen Gulkilik on 13.10.2021.
//

import Foundation
import CoreLocation

/// The statuses for trips.
enum RadarTripStatus: Int {
    /// Unknown
    case unknown
    /// `started`
    case started
    /// `approaching`
    case approaching
    /// `arrived`
    case arrived
    /// `expired`
    case expired
    /// `completed`
    case completed
    /// `canceled`
    case canceled
}

/// Represents a trip.
///
/// See [Trip Tracking](https://radar.io/documentation/trip-tracking).
public class RadarTrip {
    
    /// The Radar ID of the trip.
    private(set) var id = ""
    
    /// The external ID of the trip.
    private(set) var externalId: String?
    
    /// The optional set of custom key-value pairs for the trip.
    private(set) var metadata: [AnyHashable: Any]?
    
    /// For trips with a destination, the tag of the destination geofence.
    private(set) var destinationGeofenceTag: String?
    
    /// For trips with a destination, the external ID of the destination geofence.
    private(set) var destinationGeofenceExternalId: String?
    
    /// For trips with a destination, the location of the destination geofence.
    private(set) var destinationLocation: RadarCoordinate?
    
    /// The travel mode for the trip.
    private(set) var mode: RadarRouteMode
    
    /// For trips with a destination, the distance to the destination geofence in meters based on the travel mode for the trip.
    private(set) var etaDistance: Float = 0.0
    
    /// For trips with a destination, the ETA to the destination geofence in minutes based on the travel mode for the trip.
    private(set) var etaDuration: Float = 0.0
    
    /// The status of the trip.
    private(set) var status: RadarTripStatus
    
    init(id: String, externalId: String, metadata: [AnyHashable: Any]?, destinationGeofenceTag: String?, destinationGeofenceExternalId: String?, destinationLocation: RadarCoordinate?, mode: RadarRouteMode, etaDistance: Float, etaDuration: Float, status: RadarTripStatus) {
        self.id = id
        self.externalId = externalId
        self.metadata = metadata
        self.destinationGeofenceTag = destinationGeofenceTag
        self.destinationGeofenceExternalId = destinationGeofenceExternalId
        self.destinationLocation = destinationLocation
        self.mode = mode
        self.etaDistance = etaDistance
        self.etaDuration = etaDuration
        self.status = status
    }
    
    convenience init?(_ dict:[AnyHashable : Any]) {
        let id = dict["_id"] as? String ?? "" //TODO: CONVERT _id to id
        let externalId = dict["externalId"] as? String
        let metadata = dict["metadata"] as? [AnyHashable : Any]
        let destinationGeofenceTag = dict["destinationGeofenceTag"] as? String
        let destinationGeofenceExternalId = dict["destinationGeofenceExternalId"] as? String
        var destinationLocation: RadarCoordinate? = nil
        var mode = RadarRouteMode.car
        var etaDistance: Float = 0
        var etaDuration: Float = 0
        var status = RadarTripStatus.unknown
        
        if let destinationLocationDict = dict["destinationLocation"] as? [AnyHashable: Any] {
            if let coordinatesArr = destinationLocationDict["coordinates"] as? [AnyHashable], coordinatesArr.count == 2 {
                if let longitudeNumber = coordinatesArr[0] as? NSNumber, let latitudeNumber = coordinatesArr[1] as? NSNumber {
                    destinationLocation = RadarCoordinate(coordinate: CLLocationCoordinate2DMake(CLLocationDegrees(latitudeNumber.floatValue), CLLocationDegrees(longitudeNumber.floatValue)))
                } else {
                    return nil
                }
            } else {
                return nil
            }
        }
        
        if let modeStr = dict["mode"] as? String {
            if modeStr.caseInsensitiveCompare("foot") == .orderedSame  {
                mode = .foot
            } else if modeStr.caseInsensitiveCompare("bike") == .orderedSame  {
                mode = .bike
            } else if modeStr.caseInsensitiveCompare("truck") == .orderedSame  {
                mode = .truck
            } else if modeStr.caseInsensitiveCompare("motorbike") == .orderedSame  {
                mode = .motorbike
            }
        }
        
        if let etaDict = dict["eta"] as? [AnyHashable: Any] {
            if let etaDistanceNum = etaDict["distance"] as? NSNumber {
                etaDistance = etaDistanceNum.floatValue
            }
            if let etaDurationNum = etaDict["duration"] as? NSNumber {
                etaDuration = etaDurationNum.floatValue
            }
        }
        
        if let statusStr = dict["status"] as? String {
            if statusStr.caseInsensitiveCompare("started") == .orderedSame  {
                status = .started
            } else if statusStr.caseInsensitiveCompare("approaching") == .orderedSame  {
                status = .approaching
            } else if statusStr.caseInsensitiveCompare("arrived") == .orderedSame  {
                status = .arrived
            } else if statusStr.caseInsensitiveCompare("expired") == .orderedSame  {
                status = .expired
            } else if statusStr.caseInsensitiveCompare("completed") == .orderedSame  {
                status = .completed
            } else if statusStr.caseInsensitiveCompare("canceled") == .orderedSame  {
                status = .canceled
            }
        }
        
        if let externalId = externalId {
            self.init(id: id, externalId: externalId, metadata: metadata, destinationGeofenceTag: destinationGeofenceTag, destinationGeofenceExternalId: destinationGeofenceExternalId, destinationLocation: destinationLocation, mode: mode, etaDistance: etaDistance, etaDuration: etaDuration, status: status)
        } else {
            return nil
        }
    }
    
    func dictionaryValue() -> [AnyHashable: Any] {
        var dict: [AnyHashable: Any] = [:]
        dict["_id"] = id  //TODO: CONVERT _id to id
        dict["externalId"] = externalId
        dict["metadata"] = metadata
        dict["destinationGeofenceTag"] = destinationGeofenceTag
        dict["destinationGeofenceExternalId"] = destinationGeofenceExternalId
        var destinationLocationDict: [AnyHashable: Any] = [:]
        destinationLocationDict["type"] = "Point"
        if let destinationLocation = destinationLocation {
            destinationLocationDict["coordinates"] = [
                NSNumber(value: destinationLocation.coordinate.longitude),
                NSNumber(value: destinationLocation.coordinate.latitude)
            ]
        }
        dict["destinationLocation"] = destinationLocationDict
        dict["mode"] = Radar.stringForMode(mode)
        dict["eta"] = [
            "distance": NSNumber(value: etaDistance),
            "duration": NSNumber(value: etaDuration)
        ]
        dict["status"] = Radar.stringForTripStatus(status)
        return dict
    }
}
