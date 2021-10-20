//
//  Radar.swift
//  RadarSDK
//
//  Created by Egemen Gulkilik on 9.10.2021.
//

import Foundation
import UIKit
import CoreLocation

/// Called when a location request succeeds, fails, or times out. Receives the request status and, if successful, the location.
///
/// See [Get location](https://radar.io/documentation/sdk/ios#get-location).
public typealias RadarLocationCompletionHandler = (RadarStatus, CLLocation?, Bool) -> Void

/// Called when a beacon ranging request succeeds, fails, or times out. Receives the request status and, if successful, the nearby beacon identifiers.
///
/// See [Beacons](https://radar.io/documentation/beacons).
public typealias RadarBeaconCompletionHandler = (RadarStatus, [String]?) -> Void

/// Called when a track request succeeds, fails, or times out. Receives the request status and, if successful, the user's location, an array of the events generated, and the user.
///
/// See [Docs](https://radar.io/documentation/sdk/ios).
public typealias RadarTrackCompletionHandler = (RadarStatus, CLLocation?, [RadarEvent]?, RadarUser?) -> Void

/// Called when a trip update succeeds, fails, or times out. Receives the request status and, if successful, the trip and an array of the events generated.
///
/// See [Docs](https://radar.io/documentation/sdk/ios).
public typealias RadarTripCompletionHandler = (RadarStatus, RadarTrip?, [RadarEvent]?) -> Void

/// Called when a context request succeeds, fails, or times out. Receives the request status and, if successful, the location and the context.
///
/// See [Context](https://radar.io/documentation/api#context).
public typealias RadarContextCompletionHandler = (RadarStatus, CLLocation?, RadarContext?) -> Void

/// Called when a place search request succeeds, fails, or times out. Receives the request status and, if successful, the location and an array of places sorted by distance.
///
/// See [Search Places](https://radar.io/documentation/api#search-places).
public typealias RadarSearchPlacesCompletionHandler = (RadarStatus, CLLocation?, [RadarPlace]?) -> Void

/// Called when a geofence search request succeeds, fails, or times out. Receives the request status and, if successful, the location and an array of geofences sorted by distance.
///
/// See [Search Geofences](https://radar.io/documentation/api#search-geofences).
public typealias RadarSearchGeofencesCompletionHandler = (RadarStatus, CLLocation?, [RadarGeofence]?) -> Void

/// Called when a geocoding request succeeds, fails, or times out. Receives the request status and, if successful, the geocoding results (an array of addresses).
///
/// See [Forward Geocode](https://radar.io/documentation/api#forward-geocode).
public typealias RadarGeocodeCompletionHandler = (RadarStatus, [RadarAddress]?) -> Void

/// Called when an IP geocoding request succeeds, fails, or times out. Receives the request status and, if successful, the geocoding result (a partial address) and a boolean indicating whether the IP address is a known proxy.
///
/// See [IP Geocode](https://radar.io/documentation/api#ip-geocode).
public typealias RadarIPGeocodeCompletionHandler = (RadarStatus, RadarAddress?, Bool) -> Void

/// Called when a distance request succeeds, fails, or times out. Receives the request status and, if successful, the routes.
///
/// See [Distance](https://radar.io/documentation/api#distance).
public typealias RadarRouteCompletionHandler = (RadarStatus, RadarRoutes?) -> Void

/// Called when a matrix request succeeds, fails, or times out. Receives the request status and, if successful, the matrix.
///
/// See [Matrix](https://radar.io/documentation/api#matrix).
public typealias RadarRouteMatrixCompletionHandler = (RadarStatus, RadarRouteMatrix?) -> Void



/// The main class used to interact with the Radar SDK.
///
/// See [Docs](https://radar.io/documentation/sdk).
public class Radar {
    
    private static let sharedInstance = Radar()
    private weak var delegate: RadarDelegate?
    
    /// Initializes the Radar SDK.
    ///
    /// - Warning: Call this method from the main thread in your `AppDelegate` class before calling any other Radar methods.
    ///
    /// - Parameters:
    ///
    ///     - publishableKey: Your publishable API key.
    ///
    /// See [Initialize SDK](https://radar.io/documentation/sdk/ios#initialize-sdk).
    public static func initialize(publishableKey: String) {
        RadarLogger.sharedInstance.log(level: .debug, message: "Initializing")
        NotificationCenter.default.addObserver(Radar.sharedInstance, selector: #selector(applicationWillEnterForeground), name: UIApplication.willEnterForegroundNotification, object: nil)
        if UIApplication.shared.applicationState != .background {
            RadarSettings.updateSessionId()
        }
        RadarSettings.setPublishableKey(publishableKey)
        RadarLocationManager.sharedInstance.updateTracking()
        RadarAPIClient.sharedInstance.getConfig()
    }
    
    /// Identifies the user.
    ///
    /// - Note: Until you identify the user, Radar will automatically identify the user by `deviceId` (IDFV).
    ///
    /// - Parameters:
    ///
    ///     - userId: A stable unique ID for the user. If `nil`, the previous `userId` will be cleared.
    ///
    /// See [Identify user](https://radar.io/documentation/sdk/ios#identify-user).
    public static func setUserId(_ userId: String?) {
        RadarSettings.setUserId(userId)
    }
    
    /// Returns the current `userId`.
    ///
    /// - Returns: The current `userId`.
    ///
    /// See [Identify user](https://radar.io/documentation/sdk/ios#identify-user).
    public static func getUserId() -> String? {
        return RadarSettings.userId()
    }
    
    /// Sets an optional description for the user, displayed in the dashboard.
    ///
    /// - Parameters:
    ///
    ///     - description: A description for the user. If `nil`, the previous `description` will be cleared.
    ///
    /// See [Identify user](https://radar.io/documentation/sdk/ios#identify-user).
    public static func setDescription(_ description: String?) {
        RadarSettings.setDescription(description)
    }
    
    /// Returns the current `description`.
    ///
    /// - Returns: The current `description`.
    ///
    /// See [Identify user](https://radar.io/documentation/sdk/ios#identify-user).
    public static func getDescription() -> String? {
        return RadarSettings.description()
    }
    
    
    /// Sets an optional set of custom key-value pairs for the user.
    ///
    /// - Parameters:
    ///
    ///     - metadata: A set of custom key-value pairs for the user. Must have 16 or fewer keys and values of type string, boolean, or number. If `nil`, the previous `metadata` will be cleared.
    ///
    /// See [Identify user](https://radar.io/documentation/sdk/ios#identify-user).
    public static func setMetadata(_ metadata: [String : Any]?) {
        RadarSettings.setMetadata(metadata)
    }
    
    /// Returns the current `metadata`.
    ///
    /// - Returns: The current `metadata`.
    ///
    /// See [Identify user](https://radar.io/documentation/sdk/ios#identify-user).
    public static func getMetadata() -> [String : Any]? {
        return RadarSettings.metadata()
    }
    
    /// Enables `adId` (IDFA) collection. Disabled by default.
    ///
    /// - Parameters:
    ///
    ///     - enabled : A boolean indicating whether `adId` should be collected.
    ///
    /// See [Identify user](https://radar.io/documentation/sdk/ios#identify-user).
    public static func setAdIdEnabled(_ enabled: Bool) {
        RadarSettings.setAdIdEnabled(enabled)
    }
    
    /// Gets the device's current location with the desired accuracy.
    ///
    /// - Parameters:
    ///
    ///     - desiredAccuracy: The desired accuracy. `medium` by default.
    ///     - completionHandler: An optional completion handler.
    ///
    /// See [Get Location](https://radar.io/documentation/sdk/ios#get-location).
    public static func getLocation(desiredAccuracy: RadarTrackingOptionsDesiredAccuracy = .medium, completionHandler: RadarLocationCompletionHandler? = nil) {
        RadarLocationManager.sharedInstance.getLocation(desiredAccuracy: desiredAccuracy) { status, location, stopped in
            RadarUtils.run(onMainThread: {
                completionHandler?(status, location, stopped)
            })
        }
    }
    
    /// Tracks the user's location once with the desired accuracy and optionally ranges beacons in the foreground.
    ///
    /// - Warning: Note that these calls are subject to rate limits.
    ///
    /// - Parameters:
    ///
    ///     - desiredAccuracy: The desired accuracy. `medium` by default.
    ///     - beacons: A boolean indicating whether to range beacons. `false` by default.
    ///     - completionHandler: An optional completion handler.
    ///
    /// See [Foreground Tracking](https://radar.io/documentation/sdk/ios#foreground-tracking).
    public static func trackOnce(desiredAccuracy: RadarTrackingOptionsDesiredAccuracy = .medium, beacons: Bool = false, completionHandler: RadarTrackCompletionHandler? = nil) {
        RadarLocationManager.sharedInstance.getLocation(desiredAccuracy: desiredAccuracy) { status, location, stopped in
            if status != .success {
                if let completionHandler = completionHandler{
                    RadarUtils.run(onMainThread: {
                        completionHandler(status, nil, nil, nil)
                    })
                }
                return
            }
            
            //TODO: CHECK RETURN AGAIN
            guard let location = location else {
                return
            }
            
            let callTrackAPI: (([String]?) -> Void)? = { nearbyBeacons in
                RadarAPIClient.sharedInstance.track(location: location, stopped: stopped, foreground: true, source: .foregroundLocation, replayed: false, nearbyBeacons: nearbyBeacons) { status, res, events, user, nearbyGeofences in
                    if let completionHandler = completionHandler {
                        RadarUtils.run(onMainThread: {
                            completionHandler(status, location, events, user)
                        })
                    }
                }
            }
            
            if beacons {
                RadarAPIClient.sharedInstance.searchBeacons(near: location, radius: 1000, limit: 10) { status, res, beacons in
                    
                    //TODO: GET RID OF CODE DUPLICATE LINES
                    guard let beacons = beacons else {
                        callTrackAPI?(nil)
                        return
                    }
                    
                    if status != .success{
                        callTrackAPI?(nil)
                        return
                    }
                    
                    RadarLocationManager.sharedInstance.replaceSyncedBeacons(beacons)
                    
                    RadarUtils.run(onMainThread: {
                        RadarBeaconManager.sharedInstance.rangeBeacons(beacons) { status, nearbyBeacons in
                            if status != .success || nearbyBeacons == nil {
                                callTrackAPI?(nil)
                                return
                            }
                            callTrackAPI?(nearbyBeacons)
                        }
                    })
                }
            } else {
                callTrackAPI?(nil)
            }
        }
    }
    
    /// Manually updates the user's location.
    ///
    /// - Warning: Note that these calls are subject to rate limits.
    ///
    /// - Parameters:
    ///
    ///     - location: A location for the user.
    ///     - completionHandler: An optional completion handler.
    ///
    /// See [Foreground Tracking](https://radar.io/documentation/sdk/ios#foreground-tracking).
    public static func trackOnce(location: CLLocation, completionHandler: RadarTrackCompletionHandler? = nil) {
        RadarAPIClient.sharedInstance.track(location: location, stopped: false, foreground: true, source: .manualLocation, replayed: false, nearbyBeacons: nil) { status, res, events, user, nearbyGeofences in
            if let completionHandler = completionHandler {
                RadarUtils.run(onMainThread: {
                    completionHandler(status, location, events, user)
                })
            }
        }
    }
    
    /// Starts tracking the user's location in the background with configurable tracking options.
    ///
    /// - Parameters:
    ///
    ///     - options: Configurable tracking options.
    ///
    /// See [Background Tracking for Geofencing](https://radar.io/documentation/sdk/ios#background-tracking-for-geofencing).
    public static func startTracking(options: RadarTrackingOptions) {
        RadarLocationManager.sharedInstance.startTracking(options: options)
    }
    
    /// Mocks tracking the user's location from an origin to a destination.
    ///
    /// - Parameters:
    ///
    ///     - origin: The origin.
    ///     - destination: The destination.
    ///     - mode: The travel mode.
    ///     - steps: The number of mock location updates.
    ///     - interval: The interval in seconds between each mock location update. A number between 1 and 60.
    ///
    /// See [Mock Tracking for Testing](https://radar.io/documentation/sdk/ios#mock-tracking-for-testing).
    public static func mockTracking(origin: CLLocation, destination: CLLocation, mode: RadarRouteMode, steps: Int, interval: TimeInterval, completionHandler: RadarTrackCompletionHandler? = nil) {
        RadarAPIClient.sharedInstance.getDistance(origin: origin, destination: destination, modes: mode, units: .metric, geometryPoints: steps) { status, res, routes in
            var coordinates: [RadarCoordinate]?
            if let routes = routes {
                if mode == .foot {
                    coordinates = routes.foot?.geometry.coordinates
                } else if mode == .bike {
                    coordinates = routes.bike?.geometry.coordinates
                } else if mode == .car {
                    coordinates = routes.car?.geometry.coordinates
                } else if mode == .truck {
                    coordinates = routes.truck?.geometry.coordinates
                } else if mode == .motorbike {
                    coordinates = routes.motorbike?.geometry.coordinates
                }
            }
            
            guard let coordinates = coordinates else {
                if let completionHandler = completionHandler {
                    RadarUtils.run(onMainThread: {
                        completionHandler(status, nil, nil, nil)
                    })
                }
                return
            }
            
            var intervalLimit = interval
            if intervalLimit < 1 {
                intervalLimit = 1
            } else if intervalLimit > 60 {
                intervalLimit = 60
            }
            var i = 0
            
            //TODO: CHECK THESE CLOSURES AGAIN
            var track: (() -> Void)?
            var weakTrack: (() -> Void)?
            
            track = {
                weakTrack = track
                let coordinate = coordinates[i]
                let location = CLLocation(coordinate: coordinate.coordinate, altitude: CLLocationDistance(-1), horizontalAccuracy: CLLocationAccuracy(5), verticalAccuracy: CLLocationAccuracy(-1), timestamp: Date())
                
                let stopped = (i == 0) || (i == coordinates.count - 1)
                RadarAPIClient.sharedInstance.track(location: location, stopped: stopped, foreground: false, source: .mockLocation, replayed: false, nearbyBeacons: nil) { status, res, events, user, nearbyGeofences in
                    if let completionHandler = completionHandler {
                        RadarUtils.run(onMainThread: {
                            completionHandler(status, location, events, user)
                        })
                    }
                    if let weakTrack = weakTrack, i < coordinates.count - 1 {
                        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(Int64(intervalLimit * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC), execute: weakTrack)
                    }
                    i += 1
                }
            }
            track?()
        }
    }
    
    /// Stops tracking the user's location in the background.
    ///
    /// See [Background Tracking for Geofencing](https://radar.io/documentation/sdk/ios#background-tracking-for-geofencing).
    public static func stopTracking() {
        RadarLocationManager.sharedInstance.stopTracking()
    }
    
    /// Returns a boolean indicating whether tracking has been started.
    ///
    /// - Returns: A boolean indicating whether tracking has been started.
    ///
    /// See [Background Tracking for Geofencing](https://radar.io/documentation/sdk/ios#background-tracking-for-geofencing).
    public static func isTracking() -> Bool {
        return RadarSettings.tracking()
    }
    
    /// Returns the current tracking options.
    ///
    /// - Returns: The current tracking options.
    ///
    /// See [Tracking](https://radar.io/documentation/sdk/tracking).
    public static func getTrackingOptions() -> RadarTrackingOptions? {
        return RadarSettings.trackingOptions()
    }
    
    /// Sets a delegate for client-side delivery of events, location updates, and debug logs.
    ///
    /// - Parameters:
    ///
    ///     - delegate: A delegate for client-side delivery of events, location updates, and debug logs. If `nil`, the previous delegate will be cleared.
    ///
    /// See [Listening for Events with a Delegate](https://radar.io/documentation/sdk/ios#listening-for-events-with-a-delegate).
    public static func setDelegate(_ delegate: RadarDelegate?) {
        RadarDelegateHolder.sharedInstance.delegate = delegate
    }
    
    /// Accepts an event. Events can be accepted after user check-ins or other forms of verification. Event verifications will be used to improve the accuracy and confidence level of future events.
    ///
    /// - Parameters:
    ///
    ///     - eventId: The ID of the event to accept.
    ///     - verifiedPlaceId: For place entry events, the ID of the verified place. May be `nil`.
    ///
    /// See [Verify Events](https://radar.io/documentation/places#verify-events).
    public static func acceptEventId(_ eventId: String, verifiedPlaceId: String?) {
        RadarAPIClient.sharedInstance.verifyEventId(eventId: eventId, verification: .accept, verifiedPlaceId: verifiedPlaceId)
    }
    
    /// Rejects an event. Events can be accepted after user check-ins or other forms of verification. Event verifications will be used to improve the accuracy and confidence level of future events.
    ///
    /// - Parameters:
    ///
    ///     - eventId: The ID of the event to reject.
    ///
    /// See [Verify Events](https://radar.io/documentation/places#verify-events).
    public static func rejectEventId(_ eventId: String) {
        RadarAPIClient.sharedInstance.verifyEventId(eventId: eventId, verification: .reject, verifiedPlaceId: nil)
    }
    
    /// Returns the current trip options.
    ///
    /// - Returns: The current trip options.
    ///
    /// See [Trip Tracking](https://radar.io/documentation/trip-tracking).
    public static func getTripOptions() -> RadarTripOptions? {
        return RadarSettings.tripOptions()
    }
    
    /// Starts a trip.
    ///
    /// - Parameters:
    ///
    ///     - options: Configurable trip options.
    ///     - completionHandler: An optional completion handler.
    ///
    /// See [Trip Tracking](https://radar.io/documentation/trip-tracking).
    public static func startTrip(options: RadarTripOptions, completionHandler: RadarTripCompletionHandler? = nil) {
        RadarAPIClient.sharedInstance.updateTrip(options: options, status: .started) { status, trip, events in
            if status == .success {
                RadarSettings.setTripOptions(options)
                // flush location update to generate events
                RadarLocationManager.sharedInstance.getLocation(completionHandler: nil)
            }
            if let completionHandler = completionHandler {
                RadarUtils.run(onMainThread: {
                    completionHandler(status, trip, events)
                })
            }
        }
    }
    
    /// Manually updates a trip.
    ///
    /// - Parameters:
    ///
    ///     - options: Configurable trip options.
    ///     - status: The trip status. To avoid updating status, pass RadarTripStatus.unknown.
    ///     - completionHandler: An optional completion handler.
    ///
    /// See [Trip Tracking](https://radar.io/documentation/trip-tracking).
    public static func updateTrip(options: RadarTripOptions, status: RadarTripStatus, completionHandler: RadarTripCompletionHandler? = nil) {
        RadarAPIClient.sharedInstance.updateTrip(options: options, status: status) { status, trip, events in
            if status == .success {
                RadarSettings.setTripOptions(options)
                // flush location update to generate events
                RadarLocationManager.sharedInstance.getLocation(completionHandler: nil)
            }
            if let completionHandler = completionHandler {
                RadarUtils.run(onMainThread: {
                    completionHandler(status, trip, events)
                })
            }
        }
    }
    
    /// Completes a trip.
    ///
    /// - Parameters:
    ///
    ///     - completionHandler: An optional completion handler.
    ///
    /// See [Trip Tracking](https://radar.io/documentation/trip-tracking).
    public static func completeTrip(completionHandler: RadarTripCompletionHandler? = nil) {
        let options = RadarSettings.tripOptions()
        RadarAPIClient.sharedInstance.updateTrip(options: options, status: .completed) { status, trip, events in
            if status == .success || status == .errorNotFound {
                RadarSettings.setTripOptions(nil)
                // flush location update to generate events
                RadarLocationManager.sharedInstance.getLocation(completionHandler: nil)
            }
            if let completionHandler = completionHandler {
                RadarUtils.run(onMainThread: {
                    completionHandler(status, trip, events)
                })
            }
        }
    }
    
    /// Cancels a trip.
    ///
    /// - Parameters:
    ///
    ///     - completionHandler: An optional completion handler.
    ///
    /// See [Trip Tracking](https://radar.io/documentation/trip-tracking).
    public static func cancelTrip(completionHandler: RadarTripCompletionHandler? = nil) {
        let options = RadarSettings.tripOptions()
        RadarAPIClient.sharedInstance.updateTrip(options: options, status: .canceled) { status, trip, events in
            if status == .success || status == .errorNotFound {
                RadarSettings.setTripOptions(nil)
                // flush location update to generate events
                RadarLocationManager.sharedInstance.getLocation(completionHandler: nil)
            }
            if let completionHandler = completionHandler {
                RadarUtils.run(onMainThread: {
                    completionHandler(status, trip, events)
                })
            }
        }
    }
    
    /// Gets the device's current location, then gets context for that location without sending device or user identifiers to the server.
    ///
    /// - Parameters:
    ///
    ///     - completionHandler: A completion handler.
    ///
    /// See [Search Geofences](https://radar.io/documentation/api#search-geofences).
    public static func getContext(completionHandler: @escaping RadarContextCompletionHandler) {
        RadarLocationManager.sharedInstance.getLocation(desiredAccuracy: .medium) { status, location, stopped in
            if status != .success {
                RadarUtils.run(onMainThread: {
                    completionHandler(status, nil, nil)
                })
                return
            }
            
            //TODO: CHECK RETURN AGAIN
            guard let location = location else {
                return
            }
            
            RadarAPIClient.sharedInstance.getContext(location: location) { status, res, context in
                RadarUtils.run(onMainThread: {
                    completionHandler(status, location, context)
                })
            }
        }
    }
    
    /// Gets context for a location without sending device or user identifiers to the server.
    ///
    /// - Parameters:
    ///
    ///     - location: The location.
    ///     - completionHandler: A completion handler.
    ///
    /// See [Context](https://radar.io/documentation/api#context).
    public static func getContext(location: CLLocation, completionHandler: @escaping RadarContextCompletionHandler) {
        RadarAPIClient.sharedInstance.getContext(location:location) { status, res, context in
            RadarUtils.run(onMainThread: {
                completionHandler(status, location, context)
            })
        }
    }
    
    /// Gets the device's current location, then searches for places near that location, sorted by distance.
    ///
    /// - Warning: You may specify only one of chains, categories, or groups.
    ///
    /// - Parameters:
    ///
    ///     - radius: The radius to search, in meters. A number between 100 and 10000.
    ///     - chains: An array of chain slugs to filter. See [Chains](https://radar.io/documentation/places/chains).
    ///     - categories: An array of categories to filter. See [Categories](https://radar.io/documentation/places/categories).
    ///     - groups: An array of groups to filter. See [Groups](https://radar.io/documentation/places/groups).
    ///     - limit: The max number of places to return. A number between 1 and 100.
    ///     - completionHandler: A completion handler.
    ///
    ///
    /// See [Search Places](https://radar.io/documentation/api#search-places).
    public static func searchPlaces(radius: Int, chains: [String]?, categories: [String]?, groups: [String]?, limit: Int, completionHandler: RadarSearchPlacesCompletionHandler? = nil) {
        RadarLocationManager.sharedInstance.getLocation(desiredAccuracy: .medium) { status, location, stopped in
            if status != .success {
                if let completionHandler = completionHandler {
                    RadarUtils.run(onMainThread: {
                        completionHandler(status, nil, nil)
                    })
                }
                return
            }
            
            //TODO: CHECK RETURN AGAIN
            guard let location = location else {
                return
            }
            
            RadarAPIClient.sharedInstance.searchPlaces(near: location, radius: radius, chains: chains, categories: categories, groups: groups, limit: limit) { status, res, places in
                if let completionHandler = completionHandler {
                    RadarUtils.run(onMainThread: {
                        completionHandler(status, location, places)
                    })
                }
            }
        }
    }
    
    /// Searches for places near a location, sorted by distance.
    ///
    /// - Warning: You may specify only one of chains, categories, or groups.
    ///
    /// - Parameters:
    ///
    ///     - near: The location to search.
    ///     - radius: The radius to search, in meters. A number between 100 and 10000.
    ///     - chains: An array of chain slugs to filter. See [Chains](https://radar.io/documentation/places/chains).
    ///     - categories: An array of categories to filter. See [Categories](https://radar.io/documentation/places/categories).
    ///     - groups: An array of groups to filter. See [Groups](https://radar.io/documentation/places/groups).
    ///     - limit: The max number of places to return. A number between 1 and 100.
    ///     - completionHandler: A completion handler.
    ///
    ///
    /// See [Search Places](https://radar.io/documentation/api#search-places).
    public static func searchPlaces(near: CLLocation, radius: Int, chains: [String]?, categories: [String]?, groups: [String]?, limit: Int, completionHandler: @escaping RadarSearchPlacesCompletionHandler) {
        RadarAPIClient.sharedInstance.searchPlaces(near: near, radius: radius, chains: chains, categories: categories, groups: groups, limit: limit) { status, res, places in
            RadarUtils.run(onMainThread: {
                completionHandler(status, near, places)
            })
        }
    }
    
    /// Gets the device's current location, then searches for geofences near that location, sorted by distance.
    ///
    /// - Parameters:
    ///
    ///     - radius: The radius to search, in meters. A number between 100 and 10000.
    ///     - tags: An array of tags to filter. See [Geofences](https://radar.io/documentation/geofences).
    ///     - metadata: A dictionary of metadata to filter. See [Geofences](https://radar.io/documentation/geofences).
    ///     - limit: limit The max number of geofences to return. A number between 1 and 100.
    ///     - completionHandler: A completion handler.
    ///
    /// See [Search Geofences](https://radar.io/documentation/api#search-geofences).
    public static func searchGeofences(radius: Int, tags: [String]?, metadata: [String : Any]?, limit: Int, completionHandler: @escaping RadarSearchGeofencesCompletionHandler) {
        RadarLocationManager.sharedInstance.getLocation(){ status, location, stopped in
            if status != .success {
                RadarUtils.run(onMainThread: {
                    completionHandler(status, nil, nil)
                })
                return
            }
            
            //TODO: CHECK RETURN AGAIN
            guard let location = location else {
                return
            }
            
            RadarAPIClient.sharedInstance.searchGeofences(near: location, radius: radius, tags: tags, metadata: metadata, limit: limit) { status, res, geofences in
                RadarUtils.run(onMainThread: {
                    completionHandler(status, location, geofences)
                })
            }
        }
    }
    
    /// Searches for geofences near a location, sorted by distance.
    ///
    /// - Parameters:
    ///
    ///     - near: The location to search.
    ///     - radius: The radius to search, in meters. A number between 100 and 10000.
    ///     - tags: An array of tags to filter. See [Geofences](https://radar.io/documentation/geofences).
    ///     - metadata: A dictionary of metadata to filter. See [Geofences](https://radar.io/documentation/geofences).
    ///     - limit: limit The max number of geofences to return. A number between 1 and 100.
    ///     - completionHandler: A completion handler.
    ///
    /// See [Search Geofences](https://radar.io/documentation/api#search-geofences).
    public static func searchGeofencesNear(near: CLLocation, radius: Int, tags: [String]?, metadata: [String : Any]?, limit: Int, completionHandler: @escaping RadarSearchGeofencesCompletionHandler) {
        RadarAPIClient.sharedInstance.searchGeofences(near: near, radius: radius, tags: tags, metadata: metadata, limit: limit) { status, res, geofences in
            RadarUtils.run(onMainThread: {
                completionHandler(status, near, geofences)
            })
        }
    }
    
    /// Autocompletes partial addresses and place names, sorted by relevance.
    ///
    /// - Parameters:
    ///
    ///     - query: The partial address or place name to autocomplete.
    ///     - near: An optional location for the search.
    ///     - layers: Optional layer filters.
    ///     - limit: The max number of addresses to return. A number between 1 and 100.
    ///     - country: An optional country filter. A string, the unique 2-letter country code.
    ///     - completionHandler: A completion handler.
    ///
    /// See [Autocomplete](https://radar.io/documentation/api#autocomplete).
    public static func autocomplete(query: String, near: CLLocation? = nil, layers: [String]? = nil, limit: Int, country: String? = nil, completionHandler: @escaping RadarGeocodeCompletionHandler) {
        RadarAPIClient.sharedInstance.autocomplete(query: query, near: near, layers: layers, limit: limit, country: country) { status, res, addresses in
            RadarUtils.run(onMainThread: {
                completionHandler(status, addresses)
            })
        }
    }
    
    /// Geocodes an address, converting address to coordinates.
    ///
    /// - Parameters:
    ///
    ///     - query: The address to geocode.
    ///     - completionHandler: A completion handler.
    ///
    /// See [Forward Geocode](https://radar.io/documentation/api#forward-geocode).
    public static func geocodeAddress(query: String, completionHandler: @escaping RadarGeocodeCompletionHandler) {
        RadarAPIClient.sharedInstance.geocodeAddress(query:query) { status, res, addresses in
            RadarUtils.run(onMainThread: {
                completionHandler(status, addresses)
            })
        }
    }
    
    /// Reverse geocodes a location, converting coordinates to address. If location `nil`, the device's current location will be used.
    ///
    /// - Parameters:
    ///
    ///     - location: The location to reverse geocode. If location `nil`, the device's current location will be used.
    ///     - completionHandler: A completion handler.
    ///
    /// See [Reverse Geocode](https://radar.io/documentation/api#reverse-geocode).
    public static func reverseGeocode(location: CLLocation? = nil, completionHandler: @escaping RadarGeocodeCompletionHandler) {
        if let location = location {
            RadarAPIClient.sharedInstance.reverseGeocode(location: location) { status, res, addresses in
                RadarUtils.run(onMainThread: {
                    completionHandler(status, addresses)
                })
                return
            }
        } else {
            RadarLocationManager.sharedInstance.getLocation(){ status, location, stopped in
                if status != .success {
                    RadarUtils.run(onMainThread: {
                        completionHandler(status, nil)
                    })
                    return
                }
                //TODO: CHECK RETURN AGAIN
                guard let location = location else {
                    return
                }
                RadarAPIClient.sharedInstance.reverseGeocode(location: location) { status, res, addresses in
                    RadarUtils.run(onMainThread: {
                        completionHandler(status, addresses)
                    })
                }
            }
        }
    }
    
    /// Geocodes the device's current IP address, converting IP address to partial address.
    ///
    /// - Parameters:
    ///
    ///     - completionHandler: A completion handler.
    ///
    /// See [IP Geocode](https://radar.io/documentation/api#ip-geocode).
    public static func ipGeocode(completionHandler: @escaping RadarIPGeocodeCompletionHandler) {
        RadarAPIClient.sharedInstance.ipGeocode { status, res, address, proxy in
            RadarUtils.run(onMainThread: {
                completionHandler(status, address, proxy)
            })
        }
    }
    
    
    /// Calculates the travel distance and duration from an origin to a destination.. If origin `nil`, the device's current location will be used.
    ///
    /// - Parameters:
    ///
    ///     - origin: The origin. If origin `nil`, the device's current location will be used.
    ///     - destination: The destination.
    ///     - modes: The travel modes.
    ///     - units: The distance units.
    ///     - completionHandler: A completion handler.
    ///
    /// See [Distance](https://radar.io/documentation/api#distance).
    public static func getDistance(origin: CLLocation?, destination: CLLocation, modes: RadarRouteMode, units: RadarRouteUnits, completionHandler: @escaping RadarRouteCompletionHandler) {
        if let origin = origin {
            RadarAPIClient.sharedInstance.getDistance(origin: origin, destination: destination, modes: modes, units: units, geometryPoints: -1) { status, res, routes in
                RadarUtils.run(onMainThread: {
                    completionHandler(status, routes)
                })
            }
        } else {
            RadarLocationManager.sharedInstance.getLocation(){ status, location, stopped in
                if status != .success {
                    RadarUtils.run(onMainThread: {
                        completionHandler(status, nil)
                    })
                    return
                }
                //TODO: CHECK RETURN AGAIN
                guard let origin = location else {
                    return
                }
                RadarAPIClient.sharedInstance.getDistance(origin: origin, destination: destination, modes: modes, units: units, geometryPoints: -1) { status, res, routes in
                    RadarUtils.run(onMainThread: {
                        completionHandler(status, routes)
                    })
                }
            }
        }
    }
    
    /// Calculates the travel distances and durations between multiple origins and destinations for up to 25 routes.
    ///
    /// - Parameters:
    ///
    ///     - origins: The origins.
    ///     - destinations: The destinations.
    ///     - mode: The travel mode.
    ///     - units: The distance units.
    ///     - completionHandler: A completion handler.
    ///
    /// See [Matrix](https://radar.io/documentation/api#matrix).
    public static func getMatrix(origins: [CLLocation], destinations: [CLLocation], mode: RadarRouteMode, units: RadarRouteUnits, completionHandler: @escaping RadarRouteMatrixCompletionHandler) {
        RadarAPIClient.sharedInstance.getMatrix(origins: origins, destinations: destinations, mode: mode, units: units) { status, res, matrix in
            RadarUtils.run(onMainThread: {
                completionHandler(status, matrix)
            })
        }
    }
    
    /// Sets the log level for debug logs.
    ///
    /// - Parameters:
    ///
    ///     - level: The log level.
    public static func setLogLevel(_ level: RadarLogLevel) {
        RadarSettings.setLogLevel(level)
    }
    
    /// Returns a display string for a status value.
    ///
    /// - Parameters:
    ///
    ///     - status: A status value.
    ///
    /// - Returns: A display string for the status value.
    static func stringForStatus(_ status: RadarStatus) -> String {
        switch status {
        case .success:
            return"SUCCESS"
        case .errorPublishableKey:
            return "ERROR_PUBLISHABLE_KEY"
        case .errorPermissions:
            return "ERROR_PERMISSIONS"
        case .errorLocation:
            return "ERROR_LOCATION"
        case .errorBluetooth:
            return "ERROR_BLUETOOTH"
        case .errorNetwork:
            return "ERROR_NETWORK"
        case .errorBadRequest:
            return "ERROR_BAD_REQUEST"
        case .errorUnauthorized:
            return "ERROR_UNAUTHORIZED"
        case .errorPaymentRequired:
            return "ERROR_PAYMENT_REQUIRED"
        case .errorForbidden:
            return "ERROR_FORBIDDEN"
        case .errorRateLimit:
            return "ERROR_RATE_LIMIT"
        case .errorServer:
            return "ERROR_SERVER"
        default:
            return "ERROR_UNKNOWN"
        }
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
    
    @objc func applicationWillEnterForeground() {
        if RadarSettings.updateSessionId() {
            RadarAPIClient.sharedInstance.getConfig()
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
}
