//
//  RadarDelegateHolder.swift
//  RadarSDK
//
//  Created by Egemen Gulkilik on 12.10.2021.
//

import Foundation
import CoreLocation

class RadarDelegateHolder: NSObject, RadarDelegate {
    
    static let sharedInstance = RadarDelegateHolder()
    
    weak var delegate: RadarDelegate?
    
    
    
    func didReceiveEvents(_ events: [RadarEvent], user: RadarUser?) {
        if events.isEmpty {
            return
        }
        delegate?.didReceiveEvents(events, user: user)
        
        //TODO:
        /*
        for event in events {
            RadarLogger.sharedInstance.log(
                level: .info,
                message: "📍 Radar event received | type = \(RadarEvent.string(for: event.type)); link = https://radar.io/dashboard/events/\(event.id)")
        }
         */
        
    }
    
    func didUpdateLocation(_ location: CLLocation, user: RadarUser?) {
        if let user = user {
            delegate?.didUpdateLocation(location, user: user)
            
            //TODO:
            /*
            if let latitude = user?.location.coordinate.latitude, let longitude = user?.location.coordinate.longitude, let id = user?.id {
                RadarLogger.sharedInstance().log(
                    withLevel: RadarLogLevelInfo,
                    message: "📍 Radar location updated | coordinates = (\(latitude), \(longitude)); accuracy = \(user?.location.horizontalAccuracy ?? 0); link = https://radar.io/dashboard/users/\(id)")
            }
            */
        }
        
    }
    
    func didUpdateClientLocation(_ location: CLLocation, stopped: Bool, source: RadarLocationSource) {
        delegate?.didUpdateClientLocation(location, stopped: stopped, source: source)
    }
    
    func didFail(status: RadarStatus) {
        delegate?.didFail(status: status)
        //TODO:
        //RadarLogger.sharedInstance().log(withLevel: RadarLogLevelInfo, message: "📍 Radar error received | status = \(Radar.string(for: status))")
    }
    
    func didLog(message: String) {
        delegate?.didLog(message: message)
    }
}
