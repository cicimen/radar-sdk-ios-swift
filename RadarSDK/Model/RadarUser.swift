//
//  RadarUser.swift
//  RadarSDK
//
//  Created by Egemen Gulkilik on 11.10.2021.
//

import Foundation
import CoreLocation

/// Represents the current user state.
public class RadarUser {
    
    /// The Radar ID of the user.
    private(set) var id = ""
    
    /// The unique ID of the user, provided when you identified the user. May be `nil` if the user has not been identified.
    private(set) var userId: String?
    
    /// The device ID of the user.
    private(set) var deviceId: String?
    
    /// The optional description of the user. Not to be confused with the `NSObject` `description` property.
    private(set) var description: String?
    
    /// The optional set of custom key-value pairs for the user.
    private(set) var metadata: [AnyHashable : Any]?
    
    /// The user's current location.
    private(set) var location: CLLocation
    
    /// An array of the user's current geofences. May be `nil` or empty if the user is not in any geofences.
    ///
    /// See [Geofences](https://radar.io/documentation/geofences)
    private(set) var geofences: [RadarGeofence]?
    
    /// The user's current place. May be `nil` if the user is not at a place or if Places is not enabled.
    ///
    /// See [Places](https://radar.io/documentation/places)
    private(set) var place: RadarPlace?
    
    /// Learned insights for the user. May be `nil` if no insights are available or if Insights is not enabled.
    ///
    /// See [Insights](https://radar.io/documentation/insights)
    private(set) var insights: RadarUserInsights?
    
    /// An array of the user's nearby beacons. May be `nil` or empty if the user is not near any beacons or if Beacons is not enabled.
    ///
    /// See [Beacons]( https://radar.io/documentation/beacons)
    private(set) var beacons: [RadarBeacon]?
    
    /// A boolean indicating whether the user is stopped.
    private(set) var stopped = false
    
    /// A boolean indicating whether the user was last updated in the foreground.
    private(set) var foreground = false
    
    /// The user's current country. May be `nil` if country is not available or if Regions is not enabled.
    ///
    /// See [Regions](https://radar.io/documentation/regions)
    private(set) var country: RadarRegion?
    
    /// The user's current state. May be `nil` if state is not available or if Regions is not enabled.
    ///
    /// See [Regions](https://radar.io/documentation/regions)
    private(set) var state: RadarRegion?
    
    /// The user's current designated market area (DMA). May be `nil` if DMA is not available or if Regions is not enabled.
    ///
    /// See [Regions](https://radar.io/documentation/regions)
    private(set) var dma: RadarRegion?
    
    /// The user's current postal code. May be `nil` if postal code is not available or if Regions is not enabled.
    ///
    /// See [Regions](https://radar.io/documentation/regions)
    private(set) var postalCode: RadarRegion?
    
    /// The user's nearby chains. May be `nil` if no chains are nearby or if nearby chains are not enabled.
    private(set) var nearbyPlaceChains: [RadarChain]?
    
    /// The user's segments. May be `nil` if segments are not enabled.
    private(set) var segments: [RadarSegment]?
    
    /// The user's nearby chains. May be `nil` if segments are not enabled.
    private(set) var topChains: [RadarChain]?
    
    /// The source of the user's current location.
    private(set) var source: RadarLocationSource
    
    /// A boolean indicating whether the user's IP address is a known proxy. May be `false` if Fraud is not enabled.
    private(set) var proxy = false
    
    /// The user's current trip.
    ///
    /// See [Trip Tracking](https://radar.io/documentation/trip-tracking).
    private(set) var trip: RadarTrip?
    
    init(id: String, userId: String?, deviceId: String?, description: String?, metadata: [AnyHashable : Any]?, location: CLLocation, geofences: [RadarGeofence]?, place: RadarPlace?, insights: RadarUserInsights?, beacons: [RadarBeacon]?, stopped: Bool, foreground: Bool, country: RadarRegion?, state: RadarRegion?, dma: RadarRegion?, postalCode: RadarRegion?, nearbyPlaceChains: [RadarChain]?, segments: [RadarSegment]?, topChains: [RadarChain]?, source: RadarLocationSource, proxy: Bool, trip: RadarTrip?) {
        self.id = id
        self.userId = userId
        self.deviceId = deviceId
        self.description = description
        self.metadata = metadata
        self.location = location
        self.geofences = geofences
        self.place = place
        self.insights = insights
        self.beacons = beacons
        self.stopped = stopped
        self.foreground = foreground
        self.country = country
        self.state = state
        self.dma = dma
        self.postalCode = postalCode
        self.nearbyPlaceChains = nearbyPlaceChains
        self.segments = segments
        self.topChains = topChains
        self.source = source
        self.proxy = proxy
        self.trip = trip
    }
    
    convenience init?(_ dict: [AnyHashable : Any]) {
        guard let id = dict["_id"] as? String else { //TODO: CONVERT _id to id
            return nil
        }
        let userId = dict["userId"] as? String
        let deviceId = dict["deviceId"] as? String
        let description = dict["description"] as? String
        let metadata = dict["metadata"] as? [AnyHashable : Any]
        var geofences: [RadarGeofence]? = nil
        var place: RadarPlace? = nil
        var insights: RadarUserInsights? = nil
        var beacons: [RadarBeacon]? = nil
        let stopped = (dict["stopped"] as? NSNumber)?.boolValue ?? false
        let foreground = (dict["foregroundObj"] as? NSNumber)?.boolValue ?? false
        var country: RadarRegion? = nil
        var state: RadarRegion? = nil
        var dma: RadarRegion? = nil
        var postalCode: RadarRegion? = nil
        var nearbyPlaceChains: [RadarChain]? = nil
        var segments: [RadarSegment]? = nil
        var topChains: [RadarChain]? = nil
        var source = RadarLocationSource.unknown
        var proxy = false
        var trip: RadarTrip? = nil
        
        guard let locationDict = dict["location"] as? [AnyHashable : Any], let locationCoordinatesArr = locationDict["coordinates"] as? [AnyHashable], locationCoordinatesArr.count != 2, let locationCoordinatesLongitudeNumber = locationCoordinatesArr[0] as? NSNumber, let locationCoordinatesLatitudeNumber = locationCoordinatesArr[1] as? NSNumber, let locationAccuracyNumber = dict["locationAccuracy"] as? NSNumber  else {
            return nil
        }
        
        let location = CLLocation(coordinate: CLLocationCoordinate2DMake(CLLocationDegrees(locationCoordinatesLatitudeNumber.floatValue), CLLocationDegrees(locationCoordinatesLongitudeNumber.floatValue)), altitude: CLLocationDistance(-1), horizontalAccuracy: CLLocationAccuracy(locationAccuracyNumber.floatValue), verticalAccuracy: CLLocationAccuracy(-1), timestamp: Date())
        
        if let geofencesArr = dict["geofences"] as? [AnyHashable] {
            geofences = RadarGeofence.geofences(geofencesArr)
        }
        
        if let placeDict = dict["place"] as? [AnyHashable : Any] {
            place = RadarPlace(placeDict)
        }
        
        if let insightsDict = dict["insights"] as? [AnyHashable : Any] {
            insights = RadarUserInsights(insightsDict)
        }
        
        if let beaconsArr = dict["beacons"] as? [AnyHashable] {
            beacons = RadarBeacon.beacons(beaconsArr)
        }
        
        if let countryDict = dict["country"] as? [AnyHashable : Any] {
            country = RadarRegion(countryDict)
        }
        
        if let stateDict = dict["state"] as? [AnyHashable : Any] {
            state = RadarRegion(stateDict)
        }
        
        if let dmaDict = dict["dma"] as? [AnyHashable : Any] {
            dma = RadarRegion(dmaDict)
        }
        
        if let postalCodeDict = dict["postalCode"] as? [AnyHashable : Any] {
            postalCode = RadarRegion(postalCodeDict)
        }
        
        if let nearbyChainsArr = dict["nearbyPlaceChains"] as? [AnyHashable] {
            nearbyPlaceChains = [RadarChain]()
            for nearbyChainObj in nearbyChainsArr {
                if let nearbyChainDict = nearbyChainObj as? [AnyHashable: Any], let chain = RadarChain(nearbyChainDict) {
                    nearbyPlaceChains?.append(chain)
                }
            }
        }
        
        if let segmentsArr = dict["segments"] as? [AnyHashable] {
            segments = [RadarSegment]()
            for segmentObj in segmentsArr {
                if let segmentDict = segmentObj as? [AnyHashable: Any], let segment = RadarSegment(segmentDict) {
                    segments?.append(segment)
                }
            }
        }
        
        if let topChainsArr = dict["topChains"] as? [AnyHashable] {
            topChains = [RadarChain]()
            for topChainObj in topChainsArr {
                if let topChainDict = topChainObj as? [AnyHashable: Any], let chain = RadarChain(topChainDict) {
                    topChains?.append(chain)
                }
            }
        }
        
        if let sourceStr = dict["source"] as? String {
            if sourceStr == "FOREGROUND_LOCATION" {
                source = .foregroundLocation
            } else if sourceStr == "BACKGROUND_LOCATION" {
                source = .backgroundLocation
            } else if sourceStr == "MANUAL_LOCATION" {
                source = .manualLocation
            } else if sourceStr == "GEOFENCE_ENTER" {
                source = .geofenceEnter
            } else if sourceStr == "GEOFENCE_EXIT" {
                source = .geofenceExit
            } else if sourceStr == "VISIT_ARRIVAL" {
                source = .visitArrival
            } else if sourceStr == "VISIT_DEPARTURE" {
                source = .visitDeparture
            } else if sourceStr == "MOCK_LOCATION" {
                source = .mockLocation
            }
        }
        
        if let fraudDict = dict["fraud"] as? [AnyHashable : Any], let proxyNumber = fraudDict["proxy"] as? NSNumber {
            proxy = proxyNumber.boolValue
        }
        
        if let tripDict = dict["trip"] as? [AnyHashable : Any] {
            trip = RadarTrip(tripDict)
        }
        
        self.init(id: id, userId: userId, deviceId: deviceId, description: description, metadata: metadata, location: location, geofences: geofences, place: place, insights: insights, beacons: beacons, stopped: stopped, foreground: foreground, country: country, state: state, dma: dma, postalCode: postalCode, nearbyPlaceChains: nearbyPlaceChains, segments: segments, topChains: topChains, source: source, proxy: proxy, trip: trip )
        
    }
    
    
    func dictionaryValue() -> [AnyHashable : Any] {
        var dict: [AnyHashable : Any] = [:]
        dict["_id"] = id  //TODO: CONVERT _id to id
        dict["userId"] = userId
        dict["deviceId"] = deviceId
        dict["description"] = description
        dict["metadata"] = metadata
        var locationDict: [AnyHashable : Any] = [:]
        locationDict["type"] = "Point"
        let coordinates = [
            NSNumber(value: location.coordinate.longitude),
            NSNumber(value: location.coordinate.latitude)
        ]
        locationDict["coordinates"] = coordinates
        dict["location"] = locationDict
        if let geofences = geofences {
            dict["geofences"] = RadarGeofence.array(forGeofences: geofences)
        }
        dict["place"] = place?.dictionaryValue()
        dict["insights"] = insights?.dictionaryValue()
        if let beacons = beacons {
            dict["beacons"] = RadarBeacon.array(forBeacons: beacons)
        }
        dict["stopped"] = NSNumber(value: stopped)
        dict["foreground"] = NSNumber(value: foreground)
        dict["country"] = country?.dictionaryValue()
        dict["state"] = state?.dictionaryValue()
        dict["dma"] = dma?.dictionaryValue()
        dict["postalCode"] = postalCode?.dictionaryValue()
        if let nearbyPlaceChains = nearbyPlaceChains {
            dict["nearbyPlaceChains"] = RadarChain.array(forChains: nearbyPlaceChains)
        }
        if let segments = segments {
            dict["segments"] = RadarSegment.array(forSegments: segments)
        }
        if let topChains = topChains {
            dict["topChains"] = RadarChain.array(forChains: topChains)
        }
        dict["source"] = Radar.stringForLocationSource(source)
        dict["fraud"] = ["proxy": NSNumber(value: proxy)]
        dict["trip"] = trip?.dictionaryValue()
        return dict
    }
    
}
