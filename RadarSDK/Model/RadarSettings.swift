//
//  RadarSettings.swift
//  RadarSDK
//
//  Created by Egemen Gulkilik on 11.10.2021.
//

import Foundation
import CoreLocation

let kPublishableKey = "radar-publishableKey"
let kInstallId = "radar-installId"
let kSessionId = "radar-sessionId"
let kId = "radar-_id"
let kUserId = "radar-userId"
let kDescription = "radar-description"
let kMetadata = "radar-metadata"
let kAdIdEnabled = "radar-adIdEnabled"
let kTracking = "radar-tracking"
let kTrackingOptions = "radar-trackingOptions"
let kTripOptions = "radar-tripOptions"
let kLogLevel = "radar-logLevel"
let kConfig = "radar-config"
let kHost = "radar-host"
let kDefaultHost = "https://api.radar.io"

class RadarSettings {
    static func publishableKey() -> String? {
        return UserDefaults.standard.string(forKey: kPublishableKey)
    }
    
    static func setPublishableKey(_ publishableKey: String?) {
        UserDefaults.standard.set(publishableKey, forKey: kPublishableKey)
    }
    
    static func installId() -> String {
        if let installId = UserDefaults.standard.string(forKey: kInstallId) {
            return installId
        } else {
            let installId = UUID().uuidString
            UserDefaults.standard.set(installId, forKey: kInstallId)
            return installId
        }
    }
    
    static func sessionId() -> String {
        return String(format: "%.f", UserDefaults.standard.double(forKey: kSessionId))
    }
    
    static func updateSessionId() -> Bool {
        let timestampSeconds = Date().timeIntervalSince1970
        let sessionIdSeconds = UserDefaults.standard.double(forKey: kSessionId)
        if timestampSeconds - sessionIdSeconds > 300 {
            UserDefaults.standard.set(timestampSeconds, forKey: kSessionId)
            RadarLogger.sharedInstance.log(level: .debug, message: "New session | sessionId = \(RadarSettings.sessionId())")
            return true
        }
        return false
    }
    
    static func _id() -> String? {
        return UserDefaults.standard.string(forKey: kId) //TODO: CONVERT _id TO id
    }
    
    static func setId(_ _id: String?) {
        UserDefaults.standard.set(_id, forKey: kId)
    }
    
    static func userId() -> String? {
        return UserDefaults.standard.string(forKey: kUserId)
    }
    
    static func setUserId(_ userId: String?) {
        let oldUserId = UserDefaults.standard.string(forKey: kUserId)
        if oldUserId != nil && (oldUserId != userId) {
            RadarSettings.setId(nil)
        }
        UserDefaults.standard.set(userId, forKey: kUserId)
    }
    
    static func __description() -> String? {
        return UserDefaults.standard.string(forKey: kDescription)
    }
    
    static func setDescription(_ description: String?) {
        UserDefaults.standard.set(description, forKey: kDescription)
    }
    
    static func metadata() -> [AnyHashable : Any]? {
        return UserDefaults.standard.dictionary(forKey: kMetadata)
    }
    
    static func setMetadata(_ metadata: String?) {
        UserDefaults.standard.set(metadata, forKey: kMetadata)
    }
    
    static func adIdEnabled() -> Bool {
        return UserDefaults.standard.bool(forKey: kAdIdEnabled)
    }
    
    static func setAdIdEnabled(_ enabled: Bool) {
        UserDefaults.standard.set(enabled, forKey: kAdIdEnabled)
    }
    
    static func tracking() -> Bool {
        return UserDefaults.standard.bool(forKey: kTracking)
    }
    
    static func setTracking(_ tracking: Bool) {
        UserDefaults.standard.set(tracking, forKey: kTracking)
    }
    
    static func trackingOptions() -> RadarTrackingOptions {
        if let optionsDict = UserDefaults.standard.dictionary(forKey: kTrackingOptions) {
            return RadarTrackingOptions(fromDictionary: optionsDict)
        } else {
            return RadarTrackingOptions()
        }
    }
    
    static func setTrackingOptions(_ options: RadarTrackingOptions) {
        let optionsDict = options.dictionaryValue()
        UserDefaults.standard.set(optionsDict, forKey: kTrackingOptions)
    }
    
    static func tripOptions() -> RadarTripOptions? {
        if let optionsDict = UserDefaults.standard.dictionary(forKey: kTripOptions) {
            return RadarTripOptions(fromDictionary: optionsDict)
        }
        return nil
    }
    
    static func setTripOptions(_ options: RadarTripOptions?) {
        let optionsDict = options?.dictionaryValue()
        UserDefaults.standard.set(optionsDict, forKey: kTripOptions)
    }
    
    static func setConfig(_ config: [AnyHashable : Any]?) {
        UserDefaults.standard.set(config, forKey: kConfig)
    }
    
    static func logLevel() -> RadarLogLevel {
        var logLevel: RadarLogLevel = .info
        if let level = RadarLogLevel(rawValue: UserDefaults.standard.integer(forKey: kLogLevel)) {
            logLevel = level
        }
        return logLevel
    }
    
    static func setLogLevel(_ level: RadarLogLevel) {
        UserDefaults.standard.set(level.rawValue, forKey: kLogLevel)
    }
    
    static func host() -> String {
        return UserDefaults.standard.string(forKey: kHost) ?? kDefaultHost
    }
    
}
