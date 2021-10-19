//
//  RadarTrackingOptions.swift
//  RadarSDK
//
//  Created by Egemen Gulkilik on 11.10.2021.
//

import Foundation
import CoreLocation


let kDesiredStoppedUpdateInterval = "desiredStoppedUpdateInterval"
let kDesiredMovingUpdateInterval = "desiredMovingUpdateInterval"
let kDesiredSyncInterval = "desiredSyncInterval"
let kDesiredAccuracy = "desiredAccuracy"
let kStopDuration = "stopDuration"
let kStopDistance = "stopDistance"
let kStartTrackingAfter = "startTrackingAfter"
let kStopTrackingAfter = "stopTrackingAfter"
let kSync = "sync"
let kReplay = "replay"
let kShowBlueBar = "showBlueBar"
let kUseStoppedGeofence = "useStoppedGeofence"
let kStoppedGeofenceRadius = "stoppedGeofenceRadius"
let kUseMovingGeofence = "useMovingGeofence"
let kMovingGeofenceRadius = "movingGeofenceRadius"
let kSyncGeofences = "syncGeofences"
let kUseVisits = "useVisits"
let kUseSignificantLocationChanges = "useSignificantLocationChanges"
let kBeacons = "beacons"

let kDesiredAccuracyHigh = "high"
let kDesiredAccuracyMedium = "medium"
let kDesiredAccuracyLow = "low"

let kReplayStops = "stops"
let kReplayNone = "none"

let kSyncAll = "all"
let kSyncStopsAndExits = "stopsAndExits"
let kSyncNone = "none"

/// The location accuracy options.
enum RadarTrackingOptionsDesiredAccuracy : Int {
    /// Uses `kCLLocationAccuracyBest`
    case high
    /// Uses `kCLLocationAccuracyHundredMeters`, the default
    case medium
    /// Uses `kCLLocationAccuracyKilometer`
    case low
}

/// The replay options for failed location updates.
enum RadarTrackingOptionsReplay : Int {
    /// Replays failed stops
    case stops
    /// Replays no failed location updates
    case none
}

/// The sync options for location updates.
enum RadarTrackingOptionsSyncLocations : Int {
    /// Syncs all location updates to the server
    case syncAll
    /// Syncs only stops and exits to the server
    case syncStopsAndExits
    /// Syncs no location updates to the server
    case syncNone
}


/// An options class used to configure background tracking.
///
/// See [Docs](https://radar.io/documentation/sdk/ios) .
class RadarTrackingOptions {
    
    /// Determines the desired location update interval in seconds when stopped. Use 0 to shut down when stopped.
    /// - Warning: Note that location updates may be delayed significantly by Low Power Mode, or if the device has connectivity issues, low battery, or wi-fi disabled.
    var desiredStoppedUpdateInterval = 0
    
    /// Determines the desired location update interval in seconds when moving.
    /// - Warning: Note that location updates may be delayed significantly by Low Power Mode, or if the device has connectivity issues, low battery, or wi-fi disabled.
    var desiredMovingUpdateInterval = 0
    
    /// Determines the desired sync interval in seconds.
    var desiredSyncInterval = 0
    
    /// Determines the desired accuracy of location updates.
    var desiredAccuracy: RadarTrackingOptionsDesiredAccuracy!
    
    /// With `stopDuration`, determines the distance in meters within which the device is considered stopped.
    var stopDuration = 0
    
    ///  With `stopDuration`, determines the distance in meters within which the device is considered stopped.
    var stopDistance = 0
    
    /// Determines when to start tracking. Use `nil` to start tracking when `startTracking` is called.
    var startTrackingAfter: Date?
    
    /// Determines when to stop tracking. Use `nil` to track until `stopTracking` is called.
    var stopTrackingAfter: Date?
    
    /// Determines which failed location updates to replay to the server.
    var replay: RadarTrackingOptionsReplay!
    
    /// Determines which location updates to sync to the server.
    var syncLocations: RadarTrackingOptionsSyncLocations!
    
    /// Determines whether the flashing blue status bar is shown when tracking.
    ///
    /// See [Apple Docs](https://developer.apple.com/documentation/corelocation/cllocationmanager/2923541-showsbackgroundlocationindicator) .
    var showBlueBar = false
    
    /// Determines whether to use the iOS region monitoring service (geofencing) to create a client geofence around the device's current location when stopped.
    ///
    /// See [Apple Docs](https://developer.apple.com/documentation/corelocation/monitoring_the_user_s_proximity_to_geographic_regions) .
    var useStoppedGeofence = false
    
    /// Determines the radius in meters of the client geofence around the device's current location when stopped.
    var stoppedGeofenceRadius = 0
    
    /// Determines whether to use the iOS region monitoring service (geofencing) to create a client geofence around the device's current location when moving.
    ///
    /// See [Apple Docs](https://developer.apple.com/documentation/corelocation/monitoring_the_user_s_proximity_to_geographic_regions) .
    var useMovingGeofence = false
    
    /// Determines the radius in meters of the client geofence around the device's current location when moving.
    var movingGeofenceRadius = 0
    
    /// Determines whether to sync nearby geofences from the server to the client to improve responsiveness.
    var syncGeofences = false
    
    /// Determines whether to use the iOS visit monitoring service.
    ///
    /// See [Apple Docs](https://developer.apple.com/documentation/corelocation/getting_the_user_s_location/using_the_visits_location_service) .
    var useVisits = false
    
    /// Determines whether to use the iOS significant location change service.
    ///
    /// See [Apple Docs](https://developer.apple.com/documentation/corelocation/getting_the_user_s_location/using_the_significant-change_location_service) .
    var useSignificantLocationChanges = false
    
    /// Determines whether to monitor beacons.
    var beacons = false
    
    
    /// Updates about every 30 seconds while moving or stopped. Moderate battery usage. Shows the flashing blue status bar during tracking.
    ///
    ///
    ///
    private(set) static var presetContinuous: RadarTrackingOptions?
    
    
    /// Updates about every 2.5 minutes when moving and shuts down when stopped to save battery. Once stopped, the device will need to move more than 100 meters to wake up and start
    /// moving again. Low battery usage. Requires the `location` background mode.
    ///
    /// Note that location updates may be delayed significantly by Low Power Mode, or if the device has connectivity issues, low battery, or wi-fi disabled.
    private(set) static var presetResponsive: RadarTrackingOptions?
    
    /// Uses the iOS visit monitoring service to update only on stops and exits. Once stopped, the device will need to move several hundred meters and trigger a visit departure to wake up
    /// and start moving again. Lowest battery usage.
    ///
    /// Note that location updates may be delayed significantly by Low Power Mode, or if the device has connectivity issues, low battery, or wi-fi disabled.
    ///
    /// See [Apple Docs](https://developer.apple.com/documentation/corelocation/getting_the_user_s_location/using_the_visits_location_service) .
    private(set) static var presetEfficient: RadarTrackingOptions?
    
    static func string(for desiredAccuracy: RadarTrackingOptionsDesiredAccuracy) -> String {
        switch desiredAccuracy {
        case .high:
            return kDesiredAccuracyHigh
        case .medium:
            return kDesiredAccuracyMedium
        case .low:
            return kDesiredAccuracyLow
        }
    }
    
    static func desiredAccuracy(for str: String) -> RadarTrackingOptionsDesiredAccuracy {
        if str == kDesiredAccuracyHigh {
            return .high
        } else if str == kDesiredAccuracyLow {
            return .low
        }
        return .medium
    }
    
    static func string(for replay: RadarTrackingOptionsReplay) -> String {
        if replay == .stops {
            return kReplayStops
        }
        return kReplayNone
    }
    
    static func replay(for str: String) -> RadarTrackingOptionsReplay {
        if str.caseInsensitiveCompare(kReplayStops) == .orderedSame {
            return .stops
        }
        return .none
    }
    
    static func string(for sync: RadarTrackingOptionsSyncLocations) -> String {
        switch sync {
        case .syncNone:
            return kSyncNone
        case .syncStopsAndExits:
            return kSyncStopsAndExits
        default:
            return kSyncAll
        }
    }
    
    static func syncLocations(for str: String) -> RadarTrackingOptionsSyncLocations {
        if str.caseInsensitiveCompare(kSyncStopsAndExits) == .orderedSame {
            return .syncStopsAndExits
        } else if str.caseInsensitiveCompare(kSyncNone) == .orderedSame {
            return .syncNone
        }
        return .syncAll
    }
    
    convenience init(fromDictionary dict: [String : Any]) {
        self.init()
        desiredStoppedUpdateInterval = (dict[kDesiredStoppedUpdateInterval] as? NSNumber)?.intValue ?? 0
        desiredMovingUpdateInterval = (dict[kDesiredMovingUpdateInterval] as? NSNumber)?.intValue ?? 0
        desiredSyncInterval = (dict[kDesiredSyncInterval] as? NSNumber)?.intValue ?? 0
        desiredAccuracy = RadarTrackingOptions.desiredAccuracy(for: dict[kDesiredAccuracy] as? String ?? "")
        stopDuration = (dict[kStopDuration] as? NSNumber)?.intValue ?? 0
        stopDistance = (dict[kStopDistance] as? NSNumber)?.intValue ?? 0
        startTrackingAfter = dict[kStartTrackingAfter] as? Date
        stopTrackingAfter = dict[kStopTrackingAfter] as? Date
        syncLocations = RadarTrackingOptions.syncLocations(for: dict[kSync] as? String ?? "")
        replay = RadarTrackingOptions.replay(for: dict[kReplay] as? String ?? "")
        showBlueBar = (dict[kShowBlueBar] as? NSNumber)?.boolValue ?? false
        useStoppedGeofence = (dict[kUseStoppedGeofence] as? NSNumber)?.boolValue ?? false
        stoppedGeofenceRadius = (dict[kStoppedGeofenceRadius] as? NSNumber)?.intValue ?? 0
        useMovingGeofence = (dict[kUseMovingGeofence] as? NSNumber)?.boolValue ?? false
        movingGeofenceRadius = (dict[kMovingGeofenceRadius] as? NSNumber)?.intValue ?? 0
        syncGeofences = (dict[kSyncGeofences] as? NSNumber)?.boolValue ?? false
        useVisits = (dict[kUseVisits] as? NSNumber)?.boolValue ?? false
        useSignificantLocationChanges = (dict[kUseSignificantLocationChanges] as? NSNumber)?.boolValue ?? false
        beacons = (dict[kBeacons] as? NSNumber)?.boolValue ?? false
    }
    
    func dictionaryValue() -> [String : Any] {
        var dict: [String : Any] = [:]
        dict[kDesiredStoppedUpdateInterval] = NSNumber(value: desiredStoppedUpdateInterval)
        dict[kDesiredMovingUpdateInterval] = NSNumber(value: desiredMovingUpdateInterval)
        dict[kDesiredSyncInterval] = NSNumber(value: desiredSyncInterval)
        dict[kDesiredAccuracy] = RadarTrackingOptions.string(for: desiredAccuracy)
        dict[kStopDuration] = NSNumber(value: stopDuration)
        dict[kStopDistance] = NSNumber(value: stopDistance)
        dict[kStartTrackingAfter] = startTrackingAfter
        dict[kStopTrackingAfter] = stopTrackingAfter
        dict[kSync] = RadarTrackingOptions.string(for: syncLocations)
        dict[kReplay] = RadarTrackingOptions.string(for: replay)
        dict[kShowBlueBar] = NSNumber(value: showBlueBar)
        dict[kUseStoppedGeofence] = NSNumber(value: useStoppedGeofence)
        dict[kStoppedGeofenceRadius] = NSNumber(value: stoppedGeofenceRadius)
        dict[kUseMovingGeofence] = NSNumber(value: useMovingGeofence)
        dict[kMovingGeofenceRadius] = NSNumber(value: movingGeofenceRadius)
        dict[kSyncGeofences] = NSNumber(value: syncGeofences)
        dict[kUseVisits] = NSNumber(value: useVisits)
        dict[kUseSignificantLocationChanges] = NSNumber(value: useSignificantLocationChanges)
        dict[kBeacons] = NSNumber(value: beacons)
        return dict
    }
    
    func isEqual(_ options: RadarTrackingOptions) -> Bool {
        return desiredStoppedUpdateInterval == options.desiredStoppedUpdateInterval && desiredMovingUpdateInterval == options.desiredMovingUpdateInterval && desiredSyncInterval == options.desiredSyncInterval && desiredAccuracy == options.desiredAccuracy && stopDuration == options.stopDuration && stopDistance == options.stopDistance && (startTrackingAfter == nil ? options.startTrackingAfter == nil : (startTrackingAfter == options.startTrackingAfter)) && (stopTrackingAfter == nil ? options.stopTrackingAfter == nil : (stopTrackingAfter == options.stopTrackingAfter)) && syncLocations == options.syncLocations && replay == options.replay && showBlueBar == options.showBlueBar && useStoppedGeofence == options.useStoppedGeofence && stoppedGeofenceRadius == options.stoppedGeofenceRadius && useMovingGeofence == options.useMovingGeofence && movingGeofenceRadius == options.movingGeofenceRadius && syncGeofences == options.syncGeofences && useVisits == options.useVisits && useSignificantLocationChanges == options.useSignificantLocationChanges && beacons == options.beacons
    }
}
