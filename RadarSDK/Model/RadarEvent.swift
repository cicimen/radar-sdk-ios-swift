//
//  RadarEvent.swift
//  RadarSDK
//
//  Created by Egemen Gulkilik on 11.10.2021.
//

import Foundation
import CoreLocation

// The types for events.
enum RadarEventType : Int {
    /// Unknown
    case unknown
    /// `user.entered_geofence`
    case userEnteredGeofence
    /// `user.exited_geofence`
    case userExitedGeofence
    /// `user.entered_home`
    case userEnteredHome
    /// `user.exited_home`
    case userExitedHome
    /// `user.entered_office`
    case userEnteredOffice
    /// `user.exited_office`
    case userExitedOffice
    /// `user.started_traveling`
    case userStartedTraveling
    /// `user.stopped_traveling`
    case userStoppedTraveling
    /// `user.entered_place`
    case userEnteredPlace
    /// `user.exited_place`
    case userExitedPlace
    /// `user.nearby_place_chain`
    case userNearbyPlaceChain
    /// `user.entered_region_country`
    case userEnteredRegionCountry
    /// `user.exited_region_country`
    case userExitedRegionCountry
    /// `user.entered_region_state`
    case userEnteredRegionState
    /// `user.exited_region_state`
    case userExitedRegionState
    /// `user.entered_region_dma`
    case userEnteredRegionDMA
    /// `user.exited_region_dma`
    case userExitedRegionDMA
    /// `user.started_commuting`
    case userStartedCommuting
    // `user.stopped_commuting`
    case userStoppedCommuting
    /// `user.started_trip`
    case userStartedTrip
    /// `user.updated_trip`
    case userUpdatedTrip
    /// `user.approaching_trip_destination`
    case userApproachingTripDestination
    /// `user.arrived_at_trip_destination`
    case userArrivedAtTripDestination
    /// `user.stopped_trip`
    case userStoppedTrip
    /// `user.entered_beacon`
    case userEnteredBeacon
    /// `user.exited_beacon`
    case userExitedBeacon
    /// `user.entered_region_postal_code`
    case userEnteredRegionPostalCode
    /// `user.exited_region_postal_code`
    case userExitedRegionPostalCode
}

// The confidence levels for events.
enum RadarEventConfidence : Int {
    /// Unknown confidence
    case none = 0
    /// Low confidence
    case low = 1
    /// Medium confidence
    case medium = 2
    /// High confidence
    case high = 3
}

/// The verification types for events.
enum RadarEventVerification : Int {
    /// Accept event
    case accept = 1
    /// Unverify event
    case unverify = 0
    /// Reject event
    case reject = -1
}


/// Represents a change in user state.
class RadarEvent {
    
    // The Radar ID of the event.
    private(set) var id = ""
    
    // The datetime when the event occurred on the device.
    private(set) var createdAt: Date
    
    // The datetime when the event was created on the server.
    private(set) var actualCreatedAt: Date
    
    // A boolean indicating whether the event was generated with your live API key.
    private(set) var live = false
    
    // The type of the event.
    private(set) var type: RadarEventType
    
    // The geofence for which the event was generated. May be `nil` for non-geofence events.
    private(set) var geofence: RadarGeofence?
    
    // The place for which the event was generated. May be `nil` for non-place events.
    private(set) var place: RadarPlace?
    
    // The region for which the event was generated. May be `null` for non-region events.
    private(set) var region: RadarRegion?
    
    // The beacon for which the event was generated. May be `nil` for non-beacon events.
    private(set) var beacon: RadarBeacon?
    
    // The trip for which the event was generated. May be `nil` for non-trip events.
    private(set) var trip: RadarTrip?
    
    // For place entry events, alternate place candidates. May be `nil` for non-place events.
    private(set) var alternatePlaces: [RadarPlace]?
    
    // For accepted place entry events, the verified place. May be `nil` for non-place events or unverified events.
    private(set) var verifiedPlace: RadarPlace?
    
    // The verification of the event.
    private(set) var verification: RadarEventVerification
    
    // The confidence level of the event.
    private(set) var confidence: RadarEventConfidence
    
    // The duration between entry and exit events, in minutes, for exit events. 0 for entry events.
    private(set) var duration: Float = 0.0
    
    // The location of the event.
    private(set) var location: CLLocation
    
    init(id : String, createdAt: Date, actualCreatedAt: Date, live: Bool, type: RadarEventType, geofence: RadarGeofence?, place: RadarPlace?, region: RadarRegion?, beacon: RadarBeacon?, trip: RadarTrip?, alternatePlaces: [RadarPlace]?, verifiedPlace: RadarPlace?, verification: RadarEventVerification, confidence: RadarEventConfidence, duration: Float, location: CLLocation) {
        self.id = id
        self.createdAt = createdAt
        self.actualCreatedAt = actualCreatedAt
        self.live = live
        self.type = type
        self.geofence = geofence
        self.place = place
        self.region = region
        self.beacon = beacon
        self.trip = trip
        self.alternatePlaces = alternatePlaces
        self.verifiedPlace = verifiedPlace
        self.verification = verification
        self.confidence = confidence
        self.duration = duration
        self.location = location
    }
    
    convenience init?(_ dict: [AnyHashable : Any]) {
        guard let id = dict["_id"] as? String else { //TODO: CONVERT _id to id
            return nil
        }
        var createdAt: Date? = nil
        var actualCreatedAt: Date? = nil
        var live = false
        var type = RadarEventType.unknown
        var geofence: RadarGeofence? = nil
        var place: RadarPlace? = nil
        var region: RadarRegion? = nil
        var beacon: RadarBeacon? = nil
        var trip: RadarTrip? = nil
        var alternatePlaces: [RadarPlace]? = nil
        var verifiedPlace: RadarPlace? = nil
        var verification = RadarEventVerification.unverify
        var confidence = RadarEventConfidence.none
        var duration: Float = 0
        var location: CLLocation? = nil
        
        if let createdAtStr = dict["createdAt"] as? String {
            let dateFormatter = DateFormatter()
            dateFormatter.locale = NSLocale(localeIdentifier: "en_US_POSIX") as Locale
            dateFormatter.timeZone = NSTimeZone(abbreviation: "UTC") as TimeZone?
            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
            createdAt = dateFormatter.date(from: createdAtStr)
        }
        
        if let actualCreatedAtStr = dict["actualCreatedAt"] as? String {
            let dateFormatter = DateFormatter()
            dateFormatter.locale = NSLocale(localeIdentifier: "en_US_POSIX") as Locale
            dateFormatter.timeZone = NSTimeZone(abbreviation: "UTC") as TimeZone?
            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
            actualCreatedAt = dateFormatter.date(from: actualCreatedAtStr)
        }
        
        if let typeStr = dict["type"] as? String {
            if typeStr == "user.entered_geofence" {
                type = .userEnteredGeofence
            } else if typeStr == "user.exited_geofence" {
                type = .userExitedGeofence
            } else if typeStr == "user.entered_home" {
                type = .userEnteredHome
            } else if typeStr == "user.exited_home" {
                type = .userExitedHome
            } else if typeStr == "user.entered_office" {
                type = .userEnteredOffice
            } else if typeStr == "user.exited_office" {
                type = .userExitedOffice
            } else if typeStr == "user.started_traveling" {
                type = .userStartedTraveling
            } else if typeStr == "user.stopped_traveling" {
                type = .userStoppedTraveling
            } else if typeStr == "user.started_commuting" {
                type = .userStartedCommuting
            } else if typeStr == "user.stopped_commuting" {
                type = .userStoppedCommuting
            } else if typeStr == "user.entered_place" {
                type = .userEnteredPlace
            } else if typeStr == "user.exited_place" {
                type = .userExitedPlace
            } else if typeStr == "user.nearby_place_chain" {
                type = .userNearbyPlaceChain
            } else if typeStr == "user.entered_region_country" {
                type = .userEnteredRegionCountry
            } else if typeStr == "user.exited_region_country" {
                type = .userExitedRegionCountry
            } else if typeStr == "user.entered_region_state" {
                type = .userEnteredRegionState
            } else if typeStr == "user.exited_region_state" {
                type = .userExitedRegionState
            } else if typeStr == "user.entered_region_dma" {
                type = .userEnteredRegionDMA
            } else if typeStr == "user.exited_region_dma" {
                type = .userExitedRegionDMA
            } else if typeStr == "user.started_trip" {
                type = .userStartedTrip
            } else if typeStr == "user.updated_trip" {
                type = .userUpdatedTrip
            } else if typeStr == "user.approaching_trip_destination" {
                type = .userApproachingTripDestination
            } else if typeStr == "user.arrived_at_trip_destination" {
                type = .userArrivedAtTripDestination
            } else if typeStr == "user.stopped_trip" {
                type = .userStoppedTrip
            } else if typeStr == "user.entered_beacon" {
                type = .userEnteredBeacon
            } else if typeStr == "user.exited_beacon" {
                type = .userExitedBeacon
            }
        }
        
        if let eventLiveNumber = dict["live"] as? NSNumber {
            live = eventLiveNumber.boolValue
        }
        
        if let verificationNumber = dict["verification"] as? NSNumber {
            if verificationNumber.intValue == 1 {
                verification = .accept
            } else if verificationNumber.intValue == -1 {
                verification = .reject
            } else if verificationNumber.intValue == 0 {
                verification = .unverify
            }
        }
        
        if let confidenceNumber = dict["confidence"] as? NSNumber {
            if confidenceNumber.intValue == 3 {
                confidence = .high
            } else if confidenceNumber.intValue == 2 {
                confidence = .medium
            } else if confidenceNumber.intValue == 1 {
                confidence = .low
            }
        }
        
        if let durationNumber = dict["duration"] as? NSNumber {
            duration = durationNumber.floatValue
        }
        
        if let geofenceDict = dict["geofence"] as? [AnyHashable : Any] {
            geofence = RadarGeofence(geofenceDict)
        }
        
        if let placeDict = dict["place"] as? [AnyHashable : Any] {
            place = RadarPlace(placeDict)
        }
        
        if let regionDict = dict["region"] as? [AnyHashable : Any] {
            region = RadarRegion(regionDict)
        }
        
        if let beaconDict = dict["beacon"] as? [AnyHashable : Any] {
            beacon = RadarBeacon(beaconDict)
        }
        
        if let tripDict = dict["trip"] as? [AnyHashable : Any] {
            trip = RadarTrip(tripDict)
        }
        
        if let alternatePlacesArr = dict["alternatePlaces"] as? [AnyHashable] {
            alternatePlaces = []
            for alternatePlaceObj in alternatePlacesArr {
                if let alternatePlaceDict = alternatePlaceObj as? [AnyHashable : Any], let alternatePlace = RadarPlace(alternatePlaceDict) {
                    alternatePlaces?.append(alternatePlace)
                } else {
                    return nil
                }
            }
        }
        
        if let verifiedPlaceDict = dict["verifiedPlace"] as? [AnyHashable : Any] {
            verifiedPlace = RadarPlace(verifiedPlaceDict)
        }
        
        if let locationDict = dict["location"] as? [AnyHashable : Any] {
            if let locationCoordinatesArr = locationDict["coordinates"] as? [AnyHashable], locationCoordinatesArr.count == 2  {
                if let longitudeNumber = locationCoordinatesArr[0] as? NSNumber, let latitudeNumber = locationCoordinatesArr[1] as? NSNumber, let locationAccuracyNumber =  dict["locationAccuracy"] as? NSNumber {
                    location =  CLLocation( coordinate: CLLocationCoordinate2DMake(CLLocationDegrees(latitudeNumber.floatValue), CLLocationDegrees(longitudeNumber.floatValue)), altitude: CLLocationDistance(-1), horizontalAccuracy: CLLocationAccuracy(locationAccuracyNumber.floatValue), verticalAccuracy: CLLocationAccuracy(-1), timestamp: createdAt ?? Date())
                } else {
                    return nil
                }
                
            } else {
                return nil
            }
        }
        
        //TODO: CHECK actualCreatedAt and location nil controls
        if let createdAt = createdAt, let location = location {
            self.init(id: id, createdAt: createdAt, actualCreatedAt: actualCreatedAt ?? createdAt, live: live,type: type, geofence: geofence, place: place, region: region, beacon: beacon, trip: trip, alternatePlaces: alternatePlaces, verifiedPlace: verifiedPlace, verification: verification, confidence: confidence, duration: duration, location: location)
        } else {
            return nil
        }
        
    }
    
    static func events(_ eventsArr: [AnyHashable]) -> [RadarEvent]? {
        var arr: [RadarEvent] = []
        for eventObj in eventsArr {
            if let eventDict = eventObj as? [AnyHashable : Any], let event = RadarEvent(eventDict) {
                arr.append(event)
            }else {
                return nil
            }
        }
        return arr
    }
    
    static func string(for type: RadarEventType) -> String {
        switch type {
        case .userEnteredGeofence:
            return "user.entered_geofence"
        case .userExitedGeofence:
            return "user.exited_geofence"
        case .userEnteredHome:
            return "user.entered_home"
        case .userExitedHome:
            return "user.exited_home"
        case .userEnteredOffice:
            return "user.entered_office"
        case .userExitedOffice:
            return "user.exited_office"
        case .userStartedTraveling:
            return "user.started_traveling"
        case .userStoppedTraveling:
            return "user.stopped_traveling"
        case .userEnteredPlace:
            return "user.entered_place"
        case .userExitedPlace:
            return "user.exited_place"
        case .userNearbyPlaceChain:
            return "user.nearby_place_chain"
        case .userEnteredRegionCountry:
            return "user.entered_region_country"
        case .userExitedRegionCountry:
            return "user.exited_region_country"
        case .userEnteredRegionState:
            return "user.entered_region_state"
        case .userExitedRegionState:
            return "user.exited_region_state"
        case .userEnteredRegionDMA:
            return "user.entered_region_dma"
        case .userExitedRegionDMA:
            return "user.exited_region_country"
        case .userStartedCommuting:
            return "user.started_commuting"
        case .userStoppedCommuting:
            return "user.stopped_commuting"
        case .userStartedTrip:
            return "user.started_trip"
        case .userUpdatedTrip:
            return "user.updated_trip"
        case .userApproachingTripDestination:
            return "user.approaching_trip_destination"
        case .userArrivedAtTripDestination:
            return "user.arrived_at_trip_destination"
        case .userStoppedTrip:
            return "user.stopped_trip"
        case .userEnteredBeacon:
            return "user.entered_beacon"
        case .userExitedBeacon:
            return "user.exited_beacon"
        case .userEnteredRegionPostalCode:
            return "user.entered_region_postal_code"
        case .userExitedRegionPostalCode:
            return "user.exited_region_postal_code"
        default:
            return "unknown"
        }
    }
    
    static func array(forEvents events: [RadarEvent]) -> [[AnyHashable : Any]]? {
        var arr = [[AnyHashable : Any]]()
        for event in events {
            arr.append(event.dictionaryValue())
        }
        return arr
    }
    
    func dictionaryValue() -> [AnyHashable : Any] {
        var dict: [AnyHashable : Any] = [:]
        dict["_id"] = id  //TODO: CONVERT _id to id
        dict["live"] = NSNumber(value: live)
        dict["type"] = RadarEvent.string(for: self.type)
        if let geofence = geofence {
            dict["geofence"] = geofence.dictionaryValue()
        }
        if let place = place {
            dict["place"] = place.dictionaryValue()
        }
        dict["confidence"] = NSNumber(value: confidence.rawValue)
        dict["duration"] = NSNumber(value: duration)
        
        if let region = region {
            dict["region"] = region.dictionaryValue()
        }
        
        if let beacon = beacon {
            dict["beacon"] = beacon.dictionaryValue()
        }
        
        if let trip = trip {
            dict["trip"] = trip.dictionaryValue()
        }
        
        if let alternatePlaces = alternatePlaces {
            dict["alternatePlaces"] = RadarPlace.array(forPlaces: alternatePlaces)
        }
        var locationDict: [AnyHashable : Any] = [:]
        locationDict["type"] = "Point"
        locationDict["coordinates"] = [
            NSNumber(value: location.coordinate.longitude),
            NSNumber(value: location.coordinate.latitude)
        ]
        dict["location"] = locationDict
        return dict
    }
}
