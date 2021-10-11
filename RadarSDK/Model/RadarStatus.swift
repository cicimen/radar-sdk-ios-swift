//
//  RadarStatus.swift
//  RadarSDK
//
//  Created by Egemen Gulkilik on 11.10.2021.
//

import Foundation

/// The status types for a request.
///
/// See the [Foreground tracking documentation](https://radar.io/documentation/sdk/ios#foreground-tracking) .
public enum RadarStatus: Int {
    /// Success
    case success
    /// SDK not initialized
    case errorPublishableKey
    /// Location permissions not granted
    case errorPermissions
    /// Location services error or timeout (20 seconds)
    case errorLocation
    /// Beacon ranging error or timeout (5 seconds)
    case errorBluetooth
    /// Network error or timeout (10 seconds)
    case errorNetwork
    /// Bad request (missing or invalid params)
    case errorBadRequest
    /// Unauthorized (invalid API key)
    case errorUnauthorized
    /// Payment required (organization disabled or usage exceeded)
    case errorPaymentRequired
    /// Forbidden (insufficient permissions or no beta access)
    case errorForbidden
    /// Not found
    case errorNotFound
    /// Too many requests (rate limit exceeded)
    case errorRateLimit
    /// Internal server error
    case errorServer
    /// Unknown error
    case errorUnknown
}
