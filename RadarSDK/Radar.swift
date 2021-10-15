//
//  Radar.swift
//  RadarSDK
//
//  Created by Egemen Gulkilik on 9.10.2021.
//

import Foundation
import CoreLocation

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
