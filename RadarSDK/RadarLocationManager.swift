//
//  RadarLocationManager.swift
//  RadarSDK
//
//  Created by Egemen Gulkilik on 19.10.2021.
//

import Foundation
import CoreLocation


let kIdentifierPrefix = "radar_"
let kBubbleGeofenceIdentifierPrefix = "radar_bubble_"
let kSyncGeofenceIdentifierPrefix = "radar_geofence_"
let kSyncBeaconIdentifierPrefix = "radar_beacon_"

class RadarLocationManager: NSObject  {
    
    static let sharedInstance = RadarLocationManager()
    
    var locationManager: CLLocationManager
    var lowPowerLocationManager: CLLocationManager
    var permissionsHelper: RadarPermissionsHelper
    
    private var started = false
    private var startedInterval = 0
    private var sending = false
    private var timer: Timer?
    private var completionHandlers: [RadarLocationCompletionHandler] = []
    private var nearbyBeaconIdentifers: Set<String> = []
    let lock: RadarReadWriteLock
    
    override init() {
        locationManager = CLLocationManager()
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        locationManager.distanceFilter = kCLDistanceFilterNone
        locationManager.allowsBackgroundLocationUpdates = RadarUtils.locationBackgroundMode() && CLLocationManager.authorizationStatus() == .authorizedAlways
        lowPowerLocationManager = CLLocationManager()
        lowPowerLocationManager.desiredAccuracy = kCLLocationAccuracyThreeKilometers
        lowPowerLocationManager.distanceFilter = CLLocationDistance(3000)
        lowPowerLocationManager.allowsBackgroundLocationUpdates = RadarUtils.locationBackgroundMode()
        permissionsHelper = RadarPermissionsHelper()
        nearbyBeaconIdentifers = []
        lock = RadarReadWriteLock(label: "RadarLocationManagerLock")
        super.init()
        locationManager.delegate = self
    }
    
    func callCompletionHandlers(status: RadarStatus, location: CLLocation?) {
        
        lock.read {
            if completionHandlers.count == 0 {
                return
            }
            RadarLogger.sharedInstance.log(level: .debug, message: String(format: "Calling completion handlers | self.completionHandlers.count = %lu", UInt(completionHandlers.count)))
            for completionHandler in completionHandlers {
                NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(timeoutWithCompletionHandler(completionHandler:)), object: completionHandler)
                completionHandler(status, location, RadarState.stopped())
            }
        }
        
        lock.write {
            completionHandlers.removeAll()
        }
    }
    
    func addCompletionHandler(_ completionHandler: @escaping RadarLocationCompletionHandler) {
        lock.write {
            completionHandlers.append(completionHandler)
        }
        //TODO: CHECK PASSED PARAMETER completionHandler
        DispatchQueue.main.asyncAfter(deadline: .now() + 20) { [weak self, completionHandler] in
            self?.timeoutWithCompletionHandler(completionHandler: completionHandler)
        }
        //TODO: CHECK PASSED PARAMETER completionHandler
        //perform(#selector(timeoutWithCompletionHandler(completionHandler:)), with: completionHandler, afterDelay: 20)
    }
    
    func cancelTimeouts() {
        lock.read {
            for completionHandler in completionHandlers {
                NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(timeoutWithCompletionHandler(completionHandler:)), object: completionHandler)
            }
        }
    }
    
    @objc public func timeoutWithCompletionHandler(completionHandler: @escaping RadarLocationCompletionHandler) {
        RadarLogger.sharedInstance.log(level: .debug, message: "Location timeout")
        callCompletionHandlers(status: .errorLocation, location: nil)
    }
    
    func getLocation(desiredAccuracy: RadarTrackingOptionsDesiredAccuracy = .medium, completionHandler: RadarLocationCompletionHandler?) {
        let authorizationStatus = permissionsHelper.locationAuthorizationStatus()
        if !(authorizationStatus == .authorizedWhenInUse || authorizationStatus == .authorizedAlways) {
            RadarDelegateHolder.sharedInstance.didFail(status: .errorPermissions)
            if let completionHandler = completionHandler {
                completionHandler(.errorPermissions, nil, false)
                return
            }
        }
        
        if let completionHandler = completionHandler {
            addCompletionHandler(completionHandler)
        }
        
        switch desiredAccuracy {
        case .high:
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
        case .medium:
            locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        case .low:
            locationManager.desiredAccuracy = kCLLocationAccuracyKilometer
        }
        
        requestLocation()
        
    }
    
    func startTracking(options: RadarTrackingOptions) {
        let authorizationStatus = permissionsHelper.locationAuthorizationStatus()
        if !(authorizationStatus == .authorizedWhenInUse || authorizationStatus == .authorizedAlways) {
            RadarDelegateHolder.sharedInstance.didFail(status: .errorPermissions)
            return
        }
        RadarSettings.setTracking(true)
        RadarSettings.setTrackingOptions(options)
        updateTracking()
    }
    
    func stopTracking() {
        RadarSettings.setTracking(false)
        updateTracking()
    }
    
    func startUpdates(_ interval: Int) {
        if !started || interval != startedInterval {
            RadarLogger.sharedInstance.log(level: .debug, message: "Starting timer | interval = \(interval)")
            NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(shutDown), object: nil)
            timer?.invalidate()
            timer = Timer.scheduledTimer(withTimeInterval: TimeInterval(interval), repeats: true) { [self] timer in
                RadarLogger.sharedInstance.log(level: .debug, message: "Timer fired")
                self.requestLocation()
            }
            lowPowerLocationManager.startUpdatingLocation()
            started = true
            startedInterval = interval
        } else {
            RadarLogger.sharedInstance.log(level: .debug, message: "Already started timer")
        }
    }
    
    func stopUpdates() {
        guard let timer = timer else {
            return
        }
        RadarLogger.sharedInstance.log(level: .debug, message: "Stopping timer")
        timer.invalidate()
        started = false
        startedInterval = 0
        if !sending {
            let delay: TimeInterval = RadarSettings.tracking() ? 10 : 0
            RadarLogger.sharedInstance.log(level: .debug, message: "Scheduling shutdown")
            
            //TODO: CHECK PASSED PARAMETER completionHandler
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) { [weak self] in
                self?.shutDown()
            }
            
            //perform(#selector(shutDown), with: nil, afterDelay: delay)
        }
    }
    
    @objc func shutDown() {
        RadarLogger.sharedInstance.log(level: .debug, message: "Shutting down")
        lowPowerLocationManager.stopUpdatingLocation()
    }
    
    func requestLocation() {
        RadarLogger.sharedInstance.log(level: .debug, message: "Requesting location")
        locationManager.requestLocation()
    }
    
    func updateTracking() {
        updateTracking(nil)
    }
    
    private func updateTracking(_ location: CLLocation?) {
        
        DispatchQueue.main.async {
            
            var tracking = RadarSettings.tracking()
            let options = RadarSettings.trackingOptions()
            RadarLogger.sharedInstance.log(level: .debug, message: "Updating tracking | options = \(options.dictionaryValue()); location = \(String(describing: location))")
            
            if !tracking, let startTrackingAfter = options.startTrackingAfter, startTrackingAfter.timeIntervalSinceNow < 0 {
                RadarLogger.sharedInstance.log(level: .debug, message: "Starting time-based tracking | startTrackingAfter = \(startTrackingAfter)")
                RadarSettings.setTracking(true)
                tracking = true
            } else if tracking, let stopTrackingAfter = options.stopTrackingAfter, stopTrackingAfter.timeIntervalSinceNow < 0 {
                RadarLogger.sharedInstance.log(level: .debug, message: "Stopping time-based tracking | stopTrackingAfter = \(stopTrackingAfter)")
                RadarSettings.setTracking(false)
                tracking = false
            }
            
            if tracking {
                self.locationManager.allowsBackgroundLocationUpdates = RadarUtils.locationBackgroundMode() && CLLocationManager.authorizationStatus() == .authorizedAlways
                self.locationManager.pausesLocationUpdatesAutomatically = false
                self.lowPowerLocationManager.allowsBackgroundLocationUpdates = RadarUtils.locationBackgroundMode()
                self.lowPowerLocationManager.pausesLocationUpdatesAutomatically = false
                switch options.desiredAccuracy {
                case .high:
                    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
                case .medium:
                    self.locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
                case .low:
                    self.locationManager.desiredAccuracy = kCLLocationAccuracyKilometer
                }
                
                if #available(iOS 11, *) {
                    self.lowPowerLocationManager.showsBackgroundLocationIndicator = options.showBlueBar
                }
                
                
                let startUpdates = options.showBlueBar || CLLocationManager.authorizationStatus() == .authorizedAlways
                let stopped = RadarState.stopped()
                if stopped {
                    if options.desiredStoppedUpdateInterval == 0 {
                        self.stopUpdates()
                    } else if startUpdates {
                        self.startUpdates(options.desiredStoppedUpdateInterval)
                    }
                    if options.useStoppedGeofence, let location = location {
                        self.replaceBubbleGeofence(location, radius: options.stoppedGeofenceRadius)
                    } else {
                        self.removeBubbleGeofence()
                    }
                } else {
                    if options.desiredMovingUpdateInterval == 0 {
                        self.stopUpdates()
                    } else if startUpdates {
                        self.startUpdates(options.desiredMovingUpdateInterval)
                    }
                    if options.useMovingGeofence, let location = location {
                        self.replaceBubbleGeofence(location, radius: options.movingGeofenceRadius)
                    } else {
                        self.removeBubbleGeofence()
                    }
                }
                if !options.syncGeofences {
                    self.removeSyncedGeofences()
                }
                if options.useVisits {
                    self.locationManager.startMonitoringVisits()
                }
                if options.useSignificantLocationChanges {
                    self.locationManager.startMonitoringSignificantLocationChanges()
                }
                if !options.beacons {
                    self.removeSyncedBeacons()
                }
            } else {
                self.stopUpdates()
                self.removeAllRegions()
                self.locationManager.stopMonitoringVisits()
                self.locationManager.stopMonitoringSignificantLocationChanges()
            }
            
        }
        
    }
    
    func replaceBubbleGeofence(_ location: CLLocation, radius: Int) {
        removeBubbleGeofence()
        if !RadarSettings.tracking() {
            return
        }
        locationManager.startMonitoring(for: CLCircularRegion(center: location.coordinate, radius: CLLocationDistance(radius), identifier: "\(kBubbleGeofenceIdentifierPrefix)\(UUID().uuidString)"))
    }
    
    func removeBubbleGeofence() {
        for region in locationManager.monitoredRegions {
            if region.identifier.hasPrefix(kBubbleGeofenceIdentifierPrefix) {
                locationManager.stopMonitoring(for: region)
            }
        }
    }
    
    func replaceSyncedGeofences(_ geofences: [RadarGeofence]?) {
        removeSyncedGeofences()
        if !RadarSettings.tracking() || !RadarSettings.trackingOptions().syncGeofences {
            return
        }
        if let geofences = geofences {
            for (index, geofence) in geofences.enumerated() {
                let identifier = "\(kSyncGeofenceIdentifierPrefix)\(index)"
                var center: RadarCoordinate?
                var radius: Double = 100
                if let geometry = geofence.geometry as? RadarCircleGeometry {
                    center = geometry.center
                    radius = geometry.radius
                } else if let geometry = geofence.geometry as? RadarPolygonGeometry  {
                    center = geometry.center
                    radius = geometry.radius
                }
                if let center = center {
                    let region = CLCircularRegion(center: center.coordinate, radius: CLLocationDistance(radius), identifier: identifier)
                    locationManager.startMonitoring(for: region)
                    RadarLogger.sharedInstance.log(level: .debug, message: "Synced geofence | latitude = \(center.coordinate.latitude); longitude = \(center.coordinate.longitude); radius = \(radius); identifier \(identifier)")
                }
            }
            
        }
    }
    
    func removeSyncedGeofences() {
        for region in locationManager.monitoredRegions {
            if region.identifier.hasPrefix(kSyncGeofenceIdentifierPrefix) {
                locationManager.stopMonitoring(for: region)
            }
        }
    }
    
    func replaceSyncedBeacons(_ beacons: [RadarBeacon]?) {
        removeSyncedBeacons()
        if !RadarSettings.tracking() || !RadarSettings.trackingOptions().beacons {
            return
        }
        if let beacons = beacons {
            for beacon in beacons {
                let identifier = "\(kSyncBeaconIdentifierPrefix)\(beacon.id)"
                var region: CLBeaconRegion? = nil
                if let uuid = UUID(uuidString: beacon.uuid) {
                    region = CLBeaconRegion(proximityUUID: uuid, major: CLBeaconMajorValue(Int(beacon.major) ?? 0), minor: CLBeaconMinorValue(Int(beacon.minor) ?? 0), identifier: identifier)
                }
                if let region = region {
                    region.notifyEntryStateOnDisplay = true
                    locationManager.startMonitoring(for: region)
                    locationManager.requestState(for: region)
                    RadarLogger.sharedInstance.log(level: .debug, message: "Synced beacon | identifier = \(identifier); uuid = \(beacon.uuid); major = \(beacon.major); minor = \(beacon.minor)")
                } else {
                    RadarLogger.sharedInstance.log(level: .debug, message: "Error syncing beacon | identifier = \(identifier ); uuid = \(beacon.uuid); major = \(beacon.major); minor = \(beacon.minor)")
                }
            }
        }
    }
    
    func removeSyncedBeacons() {
        for region in locationManager.monitoredRegions {
            if region.identifier.hasPrefix(kSyncBeaconIdentifierPrefix) {
                locationManager.stopMonitoring(for: region)
            }
        }
    }
    
    func removeAllRegions() {
        for region in locationManager.monitoredRegions {
            if region.identifier.hasPrefix(kIdentifierPrefix) {
                locationManager.stopMonitoring(for: region)
            }
        }
    }
    
}

// MARK: - Handlers

extension RadarLocationManager {
    
    func handleLocation(_ location: CLLocation?, source: RadarLocationSource) {
        RadarLogger.sharedInstance.log(level: .debug, message: "Handling location | source = \(Radar.stringForLocationSource(source)); location = \(String(describing: location))")
        
        //TODO: GET RID OF CODE DUPLICATE LINES
        guard let location = location else {
            RadarLogger.sharedInstance.log(level: .debug, message: "Invalid location | source = \(Radar.stringForLocationSource(source)); location = \(String(describing: location))")
            callCompletionHandlers(status: .errorLocation, location: nil)
            return
        }
        if !RadarUtils.validLocation(location) {
            RadarLogger.sharedInstance.log(level: .debug, message: "Invalid location | source = \(Radar.stringForLocationSource(source)); location = \(String(describing: location))")
            callCompletionHandlers(status: .errorLocation, location: nil)
            return
        }
        
        let options = RadarSettings.trackingOptions()
        let wasStopped = RadarState.stopped()
        var stopped = false
        
        let force = (source == .foregroundLocation || source == .manualLocation || source == .beaconEnter || source == .beaconExit)
        
        
        if wasStopped && !force && location.horizontalAccuracy >= 1000 && options.desiredAccuracy != .low {
            RadarLogger.sharedInstance.log(level: .debug, message: "Skipping location: inaccurate | accuracy = \(location.horizontalAccuracy)")
            updateTracking(location)
            return
        }
        
        if !force && !RadarSettings.tracking() {
            RadarLogger.sharedInstance.log(level: .debug, message: "Skipping location: not tracking")
            return
        }
        
        cancelTimeouts()
        var distance = CLLocationDistanceMax
        var duration: TimeInterval = 0
        if options.stopDistance > 0, options.stopDuration > 0 {
            
            var lastMovedLocation: CLLocation? = nil
            var lastMovedAt: Date? = nil
            
            if RadarState.lastMovedLocation() == nil {
                lastMovedLocation = location
                RadarState.setLastMovedLocation(location)
            }
            
            if RadarState.lastMovedAt() == nil {
                lastMovedAt = location.timestamp
                RadarState.setLastMovedAt(location.timestamp)
            }
            
            if !force, let lastMovedAt = lastMovedAt, lastMovedAt.timeIntervalSince(location.timestamp) > 0 {
                RadarLogger.sharedInstance.log(level: .debug, message: "Skipping location: old | lastMovedAt = \(lastMovedAt); location.timestamp = \(location.timestamp)")
                return
            }
            
            if let lastMovedLocation = lastMovedLocation, let lastMovedAt = lastMovedAt {
                distance = location.distance(from: lastMovedLocation)
                duration = location.timestamp.timeIntervalSince(lastMovedAt)
                if duration == 0 {
                    duration = -location.timestamp.timeIntervalSinceNow
                }
                stopped = Int(distance) <= options.stopDistance && Int(duration) >= options.stopDuration
                RadarLogger.sharedInstance.log(level: .debug, message: "Calculating stopped | stopped = \(stopped); distance = \(distance); duration = \(duration); location.timestamp = \(location.timestamp); lastMovedAt = \(lastMovedAt)")
                
                if Int(distance) > options.stopDistance {
                    RadarState.setLastMovedLocation(location)
                    if !stopped {
                        RadarState.setLastMovedAt(location.timestamp)
                    }
                }
            }
        } else {
            stopped = force || source == .visitArrival
        }
        
        let justStopped = stopped && !wasStopped
        RadarState.setStopped(stopped)
        RadarState.setLastLocation(location)
        RadarDelegateHolder.sharedInstance.didUpdateClientLocation(location, stopped: stopped, source: source)
        if source != .manualLocation {
            updateTracking(location)
        }
        callCompletionHandlers(status: .success, location: location)
        var sendLocation = location
        let lastFailedStoppedLocation = RadarState.lastFailedStoppedLocation()
        var replayed = false
        if options.replay == .stops, let lastFailedStoppedLocation = lastFailedStoppedLocation, !justStopped {
            sendLocation = lastFailedStoppedLocation
            stopped = true
            replayed = true
            RadarState.setLastFailedStoppedLocation(nil)
            RadarLogger.sharedInstance.log(level: .debug, message: "Replaying location | location = \(sendLocation); stopped = \(stopped)")
        }
        let lastSentAt = RadarState.lastSentAt()
        let ignoreSync = lastSentAt == nil || completionHandlers.count != 0 || justStopped || replayed || source == .beaconEnter || source == .beaconExit
        let now = Date()
        var lastSyncInterval: TimeInterval? = nil
        if let lastSentAt = lastSentAt {
            lastSyncInterval = now.timeIntervalSince(lastSentAt)
        }
        
        
        if !ignoreSync {
            if !force && stopped && wasStopped && Int(distance) <= options.stopDistance && (options.desiredStoppedUpdateInterval == 0 || options.syncLocations != .syncAll) {
                RadarLogger.sharedInstance.log(level: .debug, message: "Skipping sync: already stopped | stopped = \(stopped); wasStopped = \(wasStopped)")
                return
            }
            if Int(lastSyncInterval ?? 0) < options.desiredSyncInterval {
                RadarLogger.sharedInstance.log(level: .debug, message: "Skipping sync: desired sync interval | desiredSyncInterval = \(options.desiredSyncInterval); lastSyncInterval = \(lastSyncInterval ?? 0)")
            }
            if !force && !justStopped && Int(lastSyncInterval ?? 0) < 1 {
                RadarLogger.sharedInstance.log(level: .debug, message: "Skipping sync: rate limit | justStopped = \(justStopped); lastSyncInterval = \(String(describing: lastSyncInterval))")
                return
            }
            if options.syncLocations == .syncNone {
                RadarLogger.sharedInstance.log(level: .debug, message: "Skipping sync: sync mode | sync = \(RadarTrackingOptions.string(for: options.syncLocations))")
                return
            }
            let canExit = RadarState.canExit()
            if !canExit && options.syncLocations == .syncStopsAndExits {
                RadarLogger.sharedInstance.log(level: .debug, message: "Skipping sync: can't exit | sync = \(RadarTrackingOptions.string(for: options.syncLocations)); canExit = \(canExit)")
                return
            }
        }
        RadarState.updateLastSentAt()
        if source == .foregroundLocation {
            return
        }
        self.sendLocation(sendLocation, stopped: stopped, source: source, replayed: replayed)
    }
    
    func sendLocation(_ location: CLLocation, stopped: Bool, source: RadarLocationSource, replayed: Bool) {
        RadarLogger.sharedInstance.log(level: .debug, message: "Sending location | source = \(Radar.stringForLocationSource(source)); location = \(location); stopped = \(stopped); replayed = \(replayed)")
        sending = true
        var nearbyBeacons = [String]()
        let options = RadarSettings.trackingOptions()
        if options.beacons {
            nearbyBeacons = Array(nearbyBeaconIdentifers)
            RadarLogger.sharedInstance.log(level: .debug, message: "Sending nearby beacons | nearbyBeacons = \(nearbyBeacons.joined(separator: ","))")
            if source != .beaconEnter && source != .beaconExit && source != .mockLocation && source != .manualLocation {
                RadarAPIClient.sharedInstance.searchBeacons(near: location, radius: 1000, limit: 10) { [self] status, res, beacons in
                    if status != .success || beacons == nil {
                        return
                    }
                    replaceSyncedBeacons(beacons)
                }
            }
        }
        RadarAPIClient.sharedInstance.track(location: location, stopped: stopped, foreground: RadarUtils.foreground(), source: source, replayed: replayed, nearbyBeacons: nearbyBeacons) { [self] status, res, events, user, nearbyGeofences in
            if let user = user {
                let inGeofences = user.geofences?.count != 0
                let atPlace = user.place != nil
                let atHome = user.insights != nil && user.insights?.state != nil && user.insights?.state.home != nil
                let atOffice = user.insights != nil && user.insights?.state != nil && user.insights?.state.office != nil
                let canExit = inGeofences || atPlace || atHome || atOffice
                RadarState.setCanExit(canExit)
            }
            sending = false
            updateTracking()
            replaceSyncedGeofences(nearbyGeofences)
        }
    }
    
}


// MARK: - CLLocationManagerDelegate

extension RadarLocationManager: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if locations.count == 0 {
            return
        }
        let location = locations.last
        if completionHandlers.count != 0 {
            handleLocation(location, source: .foregroundLocation)
        } else {
            handleLocation(location, source: .backgroundLocation)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        if !region.identifier.hasPrefix(kIdentifierPrefix) {
            return
        }
        if region.identifier.hasPrefix(kSyncBeaconIdentifierPrefix) {
            let identifier = String(region.identifier[kSyncBeaconIdentifierPrefix.endIndex..<region.identifier.endIndex])
            if nearbyBeaconIdentifers.contains(identifier) {
                RadarLogger.sharedInstance.log(level: .debug, message: "Already inside beacon region | identifier = \(identifier)")
            } else {
                RadarLogger.sharedInstance.log(level: .debug, message: "Entered beacon region | identifier = \(identifier)")
                nearbyBeaconIdentifers.insert(identifier)
                var location: CLLocation?
                if let managerLocation = manager.location, RadarUtils.validLocation(managerLocation) {
                    location = managerLocation
                } else {
                    location = RadarState.lastLocation()
                }
                handleLocation(location, source: .beaconEnter)
            }
        } else if manager.location != nil {
            handleLocation(manager.location, source: .geofenceEnter)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        if !region.identifier.hasPrefix(kIdentifierPrefix) {
            return
        }
        if region.identifier.hasPrefix(kSyncBeaconIdentifierPrefix) {
            let identifier = String(region.identifier[kSyncBeaconIdentifierPrefix.endIndex..<region.identifier.endIndex])
            if !nearbyBeaconIdentifers.contains(identifier) {
                RadarLogger.sharedInstance.log(level: .debug, message: "Already outside beacon region | identifier = \(identifier)")
            } else {
                RadarLogger.sharedInstance.log(level: .debug, message: "Exited beacon region | identifier = \(identifier)")
                nearbyBeaconIdentifers.remove(identifier)
                var location: CLLocation?
                if let managerLocation = manager.location, RadarUtils.validLocation(managerLocation) {
                    location = managerLocation
                } else {
                    location = RadarState.lastLocation()
                }
                handleLocation(location, source: .beaconExit)
            }
        } else if manager.location != nil {
            handleLocation(manager.location, source: .geofenceExit)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didDetermineState state: CLRegionState, for region: CLRegion) {
        if !region.identifier.hasPrefix(kSyncBeaconIdentifierPrefix) {
            return
        }
        let identifier = String(region.identifier[kSyncBeaconIdentifierPrefix.endIndex..<region.identifier.endIndex])
        if state == .inside {
            RadarLogger.sharedInstance.log(level: .debug, message: "Inside beacon region | identifier = \(identifier)")
            nearbyBeaconIdentifers.insert(identifier)
        } else {
            RadarLogger.sharedInstance.log(level: .debug, message: "Outside beacon region | identifier = \(identifier)")
            nearbyBeaconIdentifers.remove(identifier)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didVisit visit: CLVisit) {
        guard let location = manager.location else {
            return
        }
        if visit.departureDate == Date.distantFuture {
            handleLocation(location, source: .visitArrival)
        } else {
            handleLocation(location, source: .visitDeparture)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        RadarDelegateHolder.sharedInstance.didFail(status: .errorLocation)
        callCompletionHandlers(status: .errorLocation, location: nil)
    }
    
}
