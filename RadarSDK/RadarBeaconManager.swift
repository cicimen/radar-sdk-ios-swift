//
//  RadarBeaconManager.swift
//  RadarSDK
//
//  Created by Egemen Gulkilik on 19.10.2021.
//

import Foundation
import CoreLocation
import UIKit

public class RadarBeaconManager: NSObject{
    
    static let sharedInstance = RadarBeaconManager()
    
    var locationManager: CLLocationManager
    var permissionsHelper: RadarPermissionsHelper
    
    private var started = false
    private var completionHandlers: [RadarBeaconCompletionHandler] = []
    private var nearbyBeaconIdentifers: Set<String> = []
    private var failedBeaconIdentifiers: Set<String> = []
    private var beacons: [RadarBeacon] = []
    private var queue = DispatchQueue(label: "io.radar.api.RadarBeaconManager")
    
    override init() {
        locationManager = CLLocationManager()
        completionHandlers = [RadarBeaconCompletionHandler]()
        beacons = []
        nearbyBeaconIdentifers = []
        failedBeaconIdentifiers = []
        permissionsHelper = RadarPermissionsHelper()
        super.init()
        locationManager.delegate = self
    }
    
    func rangeBeacons(_ beacons: [RadarBeacon], completionHandler: RadarBeaconCompletionHandler?) {
        
        let authorizationStatus = permissionsHelper.locationAuthorizationStatus()
        
        if !(authorizationStatus == .authorizedWhenInUse || authorizationStatus == .authorizedAlways) {
            RadarDelegateHolder.sharedInstance.didFail(status: .errorPermissions)
            if let completionHandler = completionHandler {
                completionHandler(.errorPermissions, nil)
                return
            }
        }
        
        if !CLLocationManager.isRangingAvailable() {
            RadarDelegateHolder.sharedInstance.didFail(status: .errorBluetooth)
            RadarLogger.sharedInstance.log(level: .debug, message: "Beacon ranging not available")
            completionHandler?(.errorBluetooth, nil)
            return
        }
        
        if let completionHandler = completionHandler {
            addCompletionHandler(completionHandler)
        }
        
        if started {
            RadarLogger.sharedInstance.log(level: .debug, message: "Already ranging beacons")
            return
        }
        
        if beacons.count == 0 {
            RadarLogger.sharedInstance.log(level: .debug, message: "No beacons to range")
            completionHandler?(.success, [])
            return
        }
        
        self.beacons = beacons
        started = true
        for beacon in beacons {
            if let region = regionForBeacon(beacon: beacon) {
                RadarLogger.sharedInstance.log(level: .debug, message: "Starting ranging beacon | _id = \(beacon.id); uuid = \(beacon.uuid); major = \(beacon.major); minor = \(beacon.minor)")
                locationManager.startRangingBeacons(in: region)
            } else {
                RadarLogger.sharedInstance.log(level: .debug, message: "Error starting ranging beacon | _id = \(beacon.id); uuid = \(beacon.uuid); major = \(beacon.major); minor = \(beacon.minor)")
            }
        }
    }
    
    func stopRanging() {
        RadarLogger.sharedInstance.log(level: .debug, message: "Stopping ranging")
        cancelTimeouts()
        for beacon in beacons {
            if let region = regionForBeacon(beacon: beacon) {
                locationManager.stopRangingBeacons(in: region)
            }
        }
        callCompletionHandlers(status: .success, nearbyBeacons: Array(nearbyBeaconIdentifers))
        beacons = []
        started = false
        nearbyBeaconIdentifers.removeAll()
        failedBeaconIdentifiers.removeAll()
    }
    
    func regionForBeacon(beacon: RadarBeacon) -> CLBeaconRegion? {
        if let uuid = UUID(uuidString: beacon.uuid), let majorValue = Int(beacon.major), let minorValue = Int(beacon.minor) {
            return CLBeaconRegion(proximityUUID: uuid, major: CLBeaconMajorValue(majorValue), minor: CLBeaconMinorValue(minorValue), identifier: beacon.id)
        } else {
            return nil
        }
    }
    
    func handleBeacons() {
        if nearbyBeaconIdentifers.count + failedBeaconIdentifiers.count == beacons.count {
            RadarLogger.sharedInstance.log(level: .debug, message: "Finished ranging")
            stopRanging()
        }
    }
    
    func addCompletionHandler(_ completionHandler: @escaping RadarBeaconCompletionHandler) {
        queue.sync {
            completionHandlers.append(completionHandler)
            //TODO: CHECK PASSED PARAMETER completionHandler
            perform(#selector(timeoutWithCompletionHandler(completionHandler:)), with: completionHandler, afterDelay: 5)
        }
    }
    
    @objc public func timeoutWithCompletionHandler(completionHandler: @escaping RadarBeaconCompletionHandler) {
        RadarLogger.sharedInstance.log(level: .debug, message: "Beacon ranging timeout")
        stopRanging()
    }
    
    func callCompletionHandlers(status: RadarStatus, nearbyBeacons: [String]?) {
        queue.sync {
            if completionHandlers.count == 0 {
                return
            }
            RadarLogger.sharedInstance.log(level: .debug, message: String(format: "Calling completion handlers | self.completionHandlers.count = %lu", UInt(completionHandlers.count)))
            for completionHandler in completionHandlers {
                NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(timeoutWithCompletionHandler(completionHandler:)), object: completionHandler)
                completionHandler(status, nearbyBeacons)
            }
            completionHandlers.removeAll()
        }
    }
    
    func cancelTimeouts() {
        queue.sync {
            for completionHandler in completionHandlers {
                //TODO: WHY CAST RadarBeaconCompletionHandler TO RadarLocationCompletionHandler
                /*
                 guard let completionHandler = completionHandler as? RadarLocationCompletionHandler else {
                 continue
                 }
                 */
                NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(timeoutWithCompletionHandler(completionHandler:)), object: completionHandler)
            }
        }
    }
    
}

// MARK: - CLLocationManagerDelegate implementation

extension RadarBeaconManager : CLLocationManagerDelegate {
    
    public func locationManager(_ manager: CLLocationManager, monitoringDidFailFor region: CLRegion?, withError error: Error) {
        RadarLogger.sharedInstance.log(level: .debug, message: "Failed to monitor beacon | region.identifier = \(region?.identifier ?? "")")
        if let region = region {
            failedBeaconIdentifiers.insert(region.identifier)
        }
        handleBeacons()
    }
    
    public func locationManager(_ manager: CLLocationManager, rangingBeaconsDidFailFor region: CLBeaconRegion, withError error: Error) {
        RadarLogger.sharedInstance.log(level: .debug, message: "Failed to range beacon | region.identifier = \(region.identifier)")
        failedBeaconIdentifiers.insert(region.identifier)
        handleBeacons()
    }
    
    public func locationManager(_ manager: CLLocationManager, didRangeBeacons beacons: [CLBeacon], in region: CLBeaconRegion) {
        for beacon in beacons {
            RadarLogger.sharedInstance.log(level: .debug, message: String(format: "Ranged beacon | region.identifier =  %@; beacon.rssi = %ld; beacon.proximity = %ld", region.identifier, beacon.rssi, beacon.proximity.rawValue))
            nearbyBeaconIdentifers.insert(region.identifier)
        }
        handleBeacons()
    }
    
    //TODO: DO WE NEED IMPLEMENT THESE METHODS?
    /*
    @available(iOS 13.0, *)
    public func locationManager(_ manager: CLLocationManager, didRange beacons: [CLBeacon], satisfying beaconConstraint: CLBeaconIdentityConstraint) {
        
    }
    
    @available(iOS 13.0, *)
    public func locationManager(_ manager: CLLocationManager, didFailRangingFor beaconConstraint: CLBeaconIdentityConstraint, error: Error) {
        
    }
    */
    
    
}

