//
//  RadarState.swift
//  RadarSDK
//
//  Created by Egemen Gulkilik on 14.10.2021.
//

import Foundation
import CoreLocation

let kLastLocation = "radar-lastLocation"
let kLastMovedLocation = "radar-lastMovedLocation"
let kLastMovedAt = "radar-lastMovedAt"
let kStopped = "radar-stopped"
let kLastSentAt = "radar-lastSentAt"
let kCanExit = "radar-canExit"
let kLastFailedStoppedLocation = "radar-lastFailedStoppedLocation"

class RadarState {
    
    static func lastLocation() -> CLLocation? {
        if let dict = UserDefaults.standard.dictionary(forKey: kLastLocation), let lastLocation = RadarUtils.location(forDictionary: dict), RadarUtils.validLocation(lastLocation) {
            return lastLocation
        } else {
            return nil
        }
    }
    
    static func setLastLocation(_ lastLocation: CLLocation) {
        if RadarUtils.validLocation(lastLocation) {
            UserDefaults.standard.set(RadarUtils.dictionary(for: lastLocation), forKey: kLastLocation)
        }
    }
    
    static func lastMovedLocation() -> CLLocation? {
        if let dict = UserDefaults.standard.dictionary(forKey: kLastMovedLocation), let lastMovedLocation = RadarUtils.location(forDictionary: dict), RadarUtils.validLocation(lastMovedLocation) {
            return lastMovedLocation
        } else {
            return nil
        }
    }
    
    static func setLastMovedLocation(_ lastMovedLocation: CLLocation) {
        if RadarUtils.validLocation(lastMovedLocation) {
            UserDefaults.standard.set(RadarUtils.dictionary(for: lastMovedLocation), forKey: kLastMovedLocation)
        }
    }
    
    static func lastMovedAt() -> Date? {
        return UserDefaults.standard.object(forKey: kLastMovedAt) as? Date
    }

    static func setLastMovedAt(_ lastMovedAt: Date) {
        UserDefaults.standard.set(lastMovedAt, forKey: kLastMovedAt)
    }

    static func stopped() -> Bool {
        return UserDefaults.standard.bool(forKey: kStopped)
    }

    static func setStopped(_ stopped: Bool) {
        UserDefaults.standard.set(stopped, forKey: kStopped)
    }

    static func updateLastSentAt() {
        let now = Date()
        UserDefaults.standard.set(now, forKey: kLastSentAt)
    }

    static func lastSentAt() -> Date? {
        return UserDefaults.standard.value(forKey: kLastSentAt) as? Date
    }

    static func canExit() -> Bool {
        return UserDefaults.standard.bool(forKey: kCanExit)
    }

    static func setCanExit(_ canExit: Bool) {
        UserDefaults.standard.set(canExit, forKey: kCanExit)
    }

    static func lastFailedStoppedLocation() -> CLLocation? {
        if let dict = UserDefaults.standard.dictionary(forKey: kLastFailedStoppedLocation), let lastFailedStoppedLocation = RadarUtils.location(forDictionary: dict), RadarUtils.validLocation(lastFailedStoppedLocation) {
            return lastFailedStoppedLocation
        } else {
            return nil
        }
    }
    
    static func setLastFailedStoppedLocation(_ lastFailedStoppedLocation: CLLocation) {
        if RadarUtils.validLocation(lastFailedStoppedLocation) {
            UserDefaults.standard.set(RadarUtils.dictionary(for: lastFailedStoppedLocation), forKey: kLastFailedStoppedLocation)
        }
    }
    
}

