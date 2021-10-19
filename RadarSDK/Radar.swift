//
//  Radar.swift
//  RadarSDK
//
//  Created by Egemen Gulkilik on 9.10.2021.
//

import Foundation
import CoreLocation


/// Called when a location request succeeds, fails, or times out. Receives the request status and, if successful, the location.
///
/// See [Get location](https://radar.io/documentation/sdk/ios#get-location).
typealias RadarLocationCompletionHandler = (RadarStatus, CLLocation?, Bool) -> Void

/// Called when a beacon ranging request succeeds, fails, or times out. Receives the request status and, if successful, the nearby beacon identifiers.
///
/// See [Beacons](https://radar.io/documentation/beacons).
typealias RadarBeaconCompletionHandler = (RadarStatus, [String]?) -> Void

/// Called when a track request succeeds, fails, or times out. Receives the request status and, if successful, the user's location, an array of the events generated, and the user.
///
/// See [Docs](https://radar.io/documentation/sdk/ios).
typealias RadarTrackCompletionHandler = (RadarStatus, CLLocation?, [RadarEvent]?, RadarUser?) -> Void

/// Called when a trip update succeeds, fails, or times out. Receives the request status and, if successful, the trip and an array of the events generated.
///
/// See [Docs](https://radar.io/documentation/sdk/ios).
typealias RadarTripCompletionHandler = (RadarStatus, RadarTrip?, [RadarEvent]?) -> Void

/// Called when a context request succeeds, fails, or times out. Receives the request status and, if successful, the location and the context.
///
/// See [Context](https://radar.io/documentation/api#context).
typealias RadarContextCompletionHandler = (RadarStatus, CLLocation?, RadarContext?) -> Void

/// Called when a place search request succeeds, fails, or times out. Receives the request status and, if successful, the location and an array of places sorted by distance.
///
/// See [Search Places](https://radar.io/documentation/api#search-places).
typealias RadarSearchPlacesCompletionHandler = (RadarStatus, CLLocation?, [RadarPlace]?) -> Void

/// Called when a geofence search request succeeds, fails, or times out. Receives the request status and, if successful, the location and an array of geofences sorted by distance.
///
/// See [Search Geofences](https://radar.io/documentation/api#search-geofences).
typealias RadarSearchGeofencesCompletionHandler = (RadarStatus, CLLocation?, [RadarGeofence]?) -> Void

/// Called when a geocoding request succeeds, fails, or times out. Receives the request status and, if successful, the geocoding results (an array of addresses).
///
/// See [Forward Geocode](https://radar.io/documentation/api#forward-geocode).
typealias RadarGeocodeCompletionHandler = (RadarStatus, [RadarAddress]?) -> Void

/// Called when an IP geocoding request succeeds, fails, or times out. Receives the request status and, if successful, the geocoding result (a partial address) and a boolean indicating whether the IP address is a known proxy.
///
/// See [IP Geocode](https://radar.io/documentation/api#ip-geocode).
typealias RadarIPGeocodeCompletionHandler = (RadarStatus, RadarAddress?, Bool) -> Void

/// Called when a distance request succeeds, fails, or times out. Receives the request status and, if successful, the routes.
///
/// See [Distance](https://radar.io/documentation/api#distance).
typealias RadarRouteCompletionHandler = (RadarStatus, RadarRoutes?) -> Void

/// Called when a matrix request succeeds, fails, or times out. Receives the request status and, if successful, the matrix.
///
/// See [Matrix](https://radar.io/documentation/api#matrix).
typealias RadarRouteMatrixCompletionHandler = (RadarStatus, RadarRouteMatrix?) -> Void



/// The main class used to interact with the Radar SDK.
///
/// See [Docs](https://radar.io/documentation/sdk).
public class Radar {
    
    
    //private weak var delegate: RadarDelegate?
    
    /*
     static let sharedInstanceVar: Radar = {
     var sharedInstance = Radar.init()
     return sharedInstance
     }()
     
     class func sharedInstance() -> Any? {
     // `dispatch_once()` call was converted to a static variable initializer
     return sharedInstanceVar
     }
     */
    
    class func initialize(withPublishableKey publishableKey: String?) {
        
        /*
         RadarLogger.sharedInstance().log(withLevel: RadarLogLevelDebug, message: "Initializing")
         if let shared = self.sharedInstance() {
         NotificationCenter.default.addObserver(shared, selector: #selector(WKExtensionDelegate.applicationWillEnterForeground), name: UIApplicationDelegate.willEnterForegroundNotification, object: nil)
         }
         if UIApplication.shared.applicationState != .background {
         RadarSettings.updateSessionId()
         }
         RadarSettings.publishableKey = publishableKey
         RadarLocationManager.sharedInstance().updateTracking()
         RadarAPIClient.sharedInstance().getConfig()
         */
    }
    
    
    
    
    /// Returns a display string for a location source value.
    ///
    /// - Parameters:
    ///     - source: A location source value.
    ///
    /// - Returns:A display string for the location source value.
    static func stringForLocationSource(_ source: RadarLocationSource) -> String {
        switch source {
        case .foregroundLocation:
            return "FOREGROUND_LOCATION"
        case .backgroundLocation:
            return "BACKGROUND_LOCATION"
        case .manualLocation:
            return "MANUAL_LOCATION"
        case .visitArrival:
            return "VISIT_ARRIVAL"
        case .visitDeparture:
            return "VISIT_DEPARTURE"
        case .geofenceEnter:
            return "GEOFENCE_ENTER"
        case .geofenceExit:
            return "GEOFENCE_EXIT"
        case .mockLocation:
            return "MOCK_LOCATION"
        case .beaconEnter:
            return "BEACON_ENTER"
        case .beaconExit:
            return "BEACON_EXIT"
        case .unknown:
            return "UNKNOWN"
        }
    }
    
    /// Returns a display string for a travel mode value.
    ///
    /// - Parameters:
    ///     - mode: A travel mode value.
    ///
    /// - Returns:A display string for the travel mode value.
    static func stringForMode(_ mode: RadarRouteMode) -> String? {
        switch mode {
        case .foot:
            return "foot"
        case .bike:
            return "bike"
        case .car:
            return "car"
        case .truck:
            return "truck"
        case .motorbike:
            return "motorbike"
        default:
            return nil
        }
    }
    
    /// Returns a display string for a trip status value.
    ///
    /// - Parameters:
    ///     - status: A trip status value.
    ///
    /// - Returns:A display string for the trip status value.
    static func stringForTripStatus(_ status: RadarTripStatus) -> String {
        switch status {
        case .started:
            return "started"
        case .approaching:
            return "approaching"
        case .arrived:
            return "arrived"
        case .expired:
            return "expired"
        case .completed:
            return "completed"
        case .canceled:
            return "canceled"
        default:
            return "unknown"
        }
    }
    
}
