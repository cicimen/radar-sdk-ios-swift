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
    
}
