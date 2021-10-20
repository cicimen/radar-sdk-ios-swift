//
//  RadarDelegate.swift
//  RadarSDK
//
//  Created by Egemen Gulkilik on 11.10.2021.
//

import Foundation
import CoreLocation



/// A delegate for client-side delivery of events, location updates, and debug logs
///
/// See [Docs](https://radar.io/documentation/sdk/ios) .
public protocol RadarDelegate: AnyObject {

    /// Tells the delegate that events were received.
    /// - Parameters:
    ///     - events: The events received.
    ///     - user: The user, if any.
    func didReceiveEvents(_ events: [RadarEvent], user: RadarUser?)
    
    /// Tells the delegate that the current user's location was updated and synced to the server.
    /// - Parameters:
    ///     - location: The location.
    ///     - user: The current user.
    func didUpdateLocation(_ location: CLLocation, user: RadarUser?)
    
    /// Tells the delegate that the client's location was updated but not necessarily synced to the server. To receive only server-synced location updates and user
    /// state, use `didUpdateLocation:user:` instead.
    /// - Parameters:
    ///     - location: The location.
    ///     - stopped: A boolean indicating whether the client is stopped.
    ///     - source: The source of the location.
    func didUpdateClientLocation(_ location: CLLocation, stopped: Bool, source: RadarLocationSource)
    
    /// Tells the delegate that a request failed.
    /// - Parameters:
    ///     - status: The status.
    func didFail(status: RadarStatus)
    
    /// Tells the delegate that a debug log message was received.
    /// - Parameters:
    ///     - message: The message.
    func didLog(message: String)
    
}
