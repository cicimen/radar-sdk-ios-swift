//
//  RadarAPIClient.swift
//  RadarSDK
//
//  Created by Egemen Gulkilik on 14.10.2021.
//

import Foundation
import CoreLocation

typealias RadarTrackAPICompletionHandler = (RadarStatus, [AnyHashable : Any]?, [RadarEvent]?, RadarUser?, [RadarGeofence]?) -> Void
typealias RadarTripAPICompletionHandler = (RadarStatus, RadarTrip?, [RadarEvent]?) -> Void
typealias RadarContextAPICompletionHandler = (RadarStatus, [AnyHashable : Any]?, RadarContext?) -> Void
typealias RadarSearchPlacesAPICompletionHandler = (RadarStatus, [AnyHashable : Any]?, [RadarPlace]?) -> Void
typealias RadarSearchGeofencesAPICompletionHandler = (RadarStatus, [AnyHashable : Any]?, [RadarGeofence]?) -> Void
typealias RadarSearchBeaconsAPICompletionHandler = (RadarStatus, [AnyHashable : Any]?, [RadarBeacon]?) -> Void
typealias RadarGeocodeAPICompletionHandler = (RadarStatus, [AnyHashable : Any]?, [RadarAddress]?) -> Void
typealias RadarIPGeocodeAPICompletionHandler = (RadarStatus, [AnyHashable : Any]?, RadarAddress?, Bool) -> Void
typealias RadarDistanceAPICompletionHandler = (RadarStatus, [AnyHashable : Any]?, RadarRoutes?) -> Void
typealias RadarMatrixAPICompletionHandler = (RadarStatus, [AnyHashable : Any]?, RadarRouteMatrix?) -> Void

class RadarAPIClient {
    
    static let sharedInstance = RadarAPIClient()
    
    var apiHelper: RadarAPIHelper
    
    init() {
        apiHelper = RadarAPIHelper()
    }
    
    static func headers(withPublishableKey publishableKey: String) -> [AnyHashable : Any] {
        return [
            "Authorization": publishableKey,
            "Content-Type": "application/json",
            "X-Radar-Config": "true",
            "X-Radar-Device-Make": RadarUtils.deviceMake(),
            "X-Radar-Device-Model": RadarUtils.deviceModel(),
            "X-Radar-Device-OS": RadarUtils.deviceOS(),
            "X-Radar-Device-Type": RadarUtils.deviceType(),
            "X-Radar-SDK-Version": RadarUtils.sdkVersion()
        ]
    }
    
    func getConfig() {
        
        guard let publishableKey = RadarSettings.publishableKey(), publishableKey.isEmpty else {
            return
        }
        var queryString = ""
        queryString += "installId=\(RadarSettings.installId())"
        queryString += "&sessionId=\(RadarSettings.sessionId())"
        queryString += "&locationAuthorization=\(RadarUtils.locationAuthorization())"
        queryString += "&locationAccuracyAuthorization=\(RadarUtils.locationAccuracyAuthorization())"
        var url = "\(RadarSettings.host())/v1/config?\(queryString)"
        url = url.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed) ?? ""
        apiHelper.request(method: "GET", url: url, headers: RadarAPIClient.headers(withPublishableKey: publishableKey), params: nil, sleep: false) { status, res in
            guard let res = res, let metaDict = res["meta"] as? [AnyHashable : Any], let configDict = metaDict["meta"] as? [AnyHashable : Any] else {
                return
            }
            RadarSettings.setConfig(configDict)
        }
        
    }
    
    func track(location: CLLocation, stopped: Bool, foreground: Bool, source: RadarLocationSource, replayed: Bool, nearbyBeacons: [String]?, completionHandler: @escaping RadarTrackAPICompletionHandler) {
        
        guard let publishableKey = RadarSettings.publishableKey(), publishableKey.isEmpty else {
            return completionHandler(.errorPublishableKey, nil, nil, nil, nil)
        }
        
        var params: [AnyHashable : Any] = [:]
        params["id"] = RadarSettings._id()
        params["installId"] = RadarSettings.installId()
        params["userId"] = RadarSettings.userId()
        params["deviceId"] = RadarUtils.deviceId()
        params["description"] = RadarSettings.description()
        params["metadata"] = RadarSettings.metadata()
        if RadarSettings.adIdEnabled() {
            params["adId"] = RadarUtils.adId()
        }
        params["latitude"] = NSNumber(value: location.coordinate.latitude)
        params["longitude"] = NSNumber(value: location.coordinate.longitude)
        var accuracy = location.horizontalAccuracy
        if accuracy <= 0 {
            accuracy = CLLocationAccuracy(1)
        }
        params["accuracy"] = NSNumber(value: accuracy)
        params["altitude"] = NSNumber(value: location.altitude)
        params["verticalAccuracy"] = NSNumber(value: location.verticalAccuracy)
        params["speed"] = NSNumber(value: location.speed)
        params["speedAccuracy"] = NSNumber(value: location.speedAccuracy)
        params["course"] = NSNumber(value: location.course)
        if #available(iOS 13.4, *) {
            params["courseAccuracy"] = NSNumber(value: location.courseAccuracy)
        }
        if location.floor != nil {
            params["floorLevel"] = NSNumber(value: location.floor?.level ?? 0)
        }
        if !foreground {
            let timeInMs = Int(location.timestamp.timeIntervalSince1970 * 1000)
            let nowMs = Int(Date().timeIntervalSince1970 * 1000)
            params["updatedAtMsDiff"] = NSNumber(value: nowMs - timeInMs)
        }
        params["foreground"] = NSNumber(value: foreground)
        params["stopped"] = NSNumber(value: stopped)
        params["replayed"] = NSNumber(value: replayed)
        params["deviceType"] = RadarUtils.deviceType()
        params["deviceMake"] = RadarUtils.deviceMake()
        params["sdkVersion"] = RadarUtils.sdkVersion()
        params["deviceModel"] = RadarUtils.deviceModel()
        params["deviceOS"] = RadarUtils.deviceOS()
        params["country"] = RadarUtils.country()
        params["timeZoneOffset"] = RadarUtils.timeZoneOffset()
        params["source"] = Radar.stringForLocationSource(source)
        
        if let tripOptions = RadarSettings.tripOptions() {
            var tripOptionsDict: [String : Any] = [:]
            tripOptionsDict["externalId"] = tripOptions.externalId
            if let metadata = tripOptions.metadata {
                tripOptionsDict["metadata"] = metadata
            }
            if let destinationGeofenceTag = tripOptions.destinationGeofenceTag {
                tripOptionsDict["destinationGeofenceTag"] = destinationGeofenceTag
            }
            if let destinationGeofenceExternalId = tripOptions.destinationGeofenceExternalId {
                tripOptionsDict["destinationGeofenceExternalId"] = destinationGeofenceExternalId
            }
            tripOptionsDict["mode"] = Radar.stringForMode(tripOptions.mode)
            params["tripOptions"] = tripOptionsDict
        }
        
        let options = RadarSettings.trackingOptions()
        
        if options.syncGeofences {
            params["nearbyGeofences"] = NSNumber(value: true)
        }
        
        if let nearbyBeacons = nearbyBeacons {
            params["nearbyBeacons"] = nearbyBeacons
        }
        
        params["locationAuthorization"] = RadarUtils.locationAuthorization()
        params["locationAccuracyAuthorization"] = RadarUtils.locationAccuracyAuthorization()
        params["sessionId"] = RadarSettings.sessionId()
        
        guard let url = "\(RadarSettings.host())/v1/track".addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed) else {
            return
        }
        
        apiHelper.request(method: "POST", url: url, headers: RadarAPIClient.headers(withPublishableKey: publishableKey), params: params, sleep: true) { status, res in
            
            //TODO: GET RID OF CODE DUPLICATE LINES
            guard let res = res else {
                if options.replay == .stops && stopped && !(source == .foregroundLocation || source == .manualLocation) {
                    RadarState.setLastFailedStoppedLocation(location)
                }
                RadarDelegateHolder.sharedInstance.didFail(status: status)
                return completionHandler(status, nil, nil, nil, nil)
            }
            
            if status != .success {
                if options.replay == .stops && stopped && !(source == .foregroundLocation || source == .manualLocation) {
                    RadarState.setLastFailedStoppedLocation(location)
                }
                RadarDelegateHolder.sharedInstance.didFail(status: status)
                return completionHandler(status, nil, nil, nil, nil)
            }
            RadarState.setLastFailedStoppedLocation(nil)
            
            if let metaDict = res["meta"] as? [AnyHashable : Any], let configDict = metaDict["config"] as? [AnyHashable : Any] {
                RadarSettings.setConfig(configDict)
            }
            
            if let eventsArr = res["events"] as? [AnyHashable], let userDict = res["user"] as? [AnyHashable : Any], let events = RadarEvent.events(eventsArr), let user = RadarUser(userDict) {
                var nearbyGeofences: [RadarGeofence]? = nil
                if let nearbyGeofencesDict = res["nearbyGeofences"] as? [AnyHashable] {
                    nearbyGeofences = RadarGeofence.geofences(nearbyGeofencesDict)
                }
                RadarSettings.setId(user.id)
                
                if user.trip == nil {
                    RadarSettings.setTripOptions(nil)
                }
                RadarDelegateHolder.sharedInstance.didUpdateLocation(location, user: user)
                
                if !events.isEmpty {
                    RadarDelegateHolder.sharedInstance.didReceiveEvents(events, user: user)
                }
                
                return completionHandler(.success, res, events, user, nearbyGeofences)
                
            } else {
                RadarDelegateHolder.sharedInstance.didFail(status: status)
                return completionHandler(status, nil, nil, nil, nil)
            }
        }
        
    }
    
    func verifyEventId(eventId: String, verification: RadarEventVerification, verifiedPlaceId: String?) {
        guard let publishableKey = RadarSettings.publishableKey() else {
            return
        }
        var params: [AnyHashable : Any] = [:]
        params["verification"] = NSNumber(value: verification.rawValue)
        
        if let verifiedPlaceId = verifiedPlaceId {
            params["verifiedPlaceId"] = verifiedPlaceId
        }
        
        guard let urlString = "\(RadarSettings.host())/v1/events/\(eventId)/verification".addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed) else {
            return
        }
        
        apiHelper.request(method: "PUT", url: urlString, headers: RadarAPIClient.headers(withPublishableKey: publishableKey), params: params, sleep: false) { status, res in }
    }
    
    func updateTrip(options: RadarTripOptions?, status: RadarTripStatus, completionHandler: @escaping RadarTripAPICompletionHandler) {
        
        guard let publishableKey = RadarSettings.publishableKey() else {
            return completionHandler(.errorPublishableKey, nil, nil)
        }
        
        guard let options = options else {
            return completionHandler(.errorBadRequest, nil, nil)
        }
        
        var params: [AnyHashable : Any] = [:]
        params["status"] = Radar.stringForTripStatus(status)
        params["metadata"] = options.metadata
        params["destinationGeofenceTag"] = options.destinationGeofenceTag
        params["destinationGeofenceExternalId"] = options.destinationGeofenceExternalId
        params["mode"] = Radar.stringForMode(options.mode)
        
        guard let urlString  = "\(RadarSettings.host())/v1/trips/\(options.externalId)".addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed) else {
            return //TODO: DO WE NEED TO CALL completionHandler
        }
        
        apiHelper.request(method: "PATCH", url: urlString, headers: RadarAPIClient.headers(withPublishableKey: publishableKey), params: params, sleep: false) { status, res in
            
            //TODO: GET RID OF CODE DUPLICATE LINES
            guard let res = res else {
                return completionHandler(status, nil, nil)
            }
            
            if status != .success{
                return completionHandler(status, nil, nil)
            }
            
            
            var trip: RadarTrip? = nil
            if let tripDict = res["trip"] as? [AnyHashable: Any] {
                trip = RadarTrip(tripDict)
            }
            
            var events: [RadarEvent]? = nil
            if let eventsArr = res["events"] as? [AnyHashable] {
                events = RadarEvent.events(eventsArr)
            }
            
            if let events = events, events.count != 0 {
                RadarDelegateHolder.sharedInstance.didReceiveEvents(events, user: nil)
            }
            
            completionHandler(.success, trip, events)
            
        }
        
    }
    
    func getContext(location: CLLocation, completionHandler: @escaping RadarContextAPICompletionHandler) {
        
        guard let publishableKey = RadarSettings.publishableKey() else {
            return completionHandler(.errorPublishableKey, nil, nil)
        }
        
        let queryString = String(format: "coordinates=%.06f,%.06f", location.coordinate.latitude, location.coordinate.longitude)
        let url = "\(RadarSettings.host())/v1/context?\(queryString)"
        
        apiHelper.request(method: "GET", url: url, headers: RadarAPIClient.headers(withPublishableKey: publishableKey), params: nil, sleep: false) { status, res in
            
            guard let res = res else {
                return completionHandler(status, nil, nil)
            }
            
            if status != .success {
                return completionHandler(status, nil, nil)
            }
            
            if let contextDict = res["context"] as? [AnyHashable: Any] {
                let context = RadarContext(contextDict)
                return completionHandler(.success, res, context)
            } else {
                return completionHandler(.errorServer, nil, nil)
            }
        }
        
    }
    
    func searchPlaces(near: CLLocation, radius: Int, chains: [String]?, categories: [String]?, groups: [String]?, limit: Int, completionHandler: @escaping RadarSearchPlacesAPICompletionHandler) {
        
        guard let publishableKey = RadarSettings.publishableKey() else {
            return completionHandler(.errorPublishableKey, nil, nil)
        }
        
        let finalLimit = Int(min(limit, 100))
        var queryString = String(format: "near=%.06f,%.06f", near.coordinate.latitude, near.coordinate.longitude)
        queryString += "&radius=\(radius)&limit=\(finalLimit)"
        
        if let chains = chains, chains.count > 0  {
            queryString += "&chains=\(chains.joined(separator: ","))"
        }
        
        if let categories = categories, categories.count > 0  {
            queryString += "&categories=\(categories.joined(separator: ","))"
        }
        
        if let groups = groups, groups.count > 0  {
            queryString += "&groups=\(groups.joined(separator: ","))"
        }
        
        guard let urlString  = "\(RadarSettings.host())/v1/search/places?\(queryString)".addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed) else {
            return //TODO: DO WE NEED TO CALL completionHandler
        }
        
        apiHelper.request(method: "GET", url: urlString, headers: RadarAPIClient.headers(withPublishableKey: publishableKey), params: nil, sleep: false) { status, res in
            
            //TODO: GET RID OF CODE DUPLICATE LINES
            guard let res = res else {
                return completionHandler(status, nil, nil)
            }
            
            if status != .success {
                return completionHandler(status, nil, nil)
            }
            
            if let placesArr = res["places"] as? [AnyHashable], let places = RadarPlace.places(placesArr) {
                return completionHandler(.success, res, places)
            } else {
                completionHandler(.errorServer, nil, nil)
            }
            
        }
        
    }
    
    func searchGeofences(near: CLLocation, radius: Int, tags: [String]?, metadata: [AnyHashable : Any]?, limit: Int, completionHandler: @escaping RadarSearchGeofencesAPICompletionHandler) {
        
        guard let publishableKey = RadarSettings.publishableKey() else {
            return completionHandler(.errorPublishableKey, nil, nil)
        }
        
        
        let finalLimit = Int(min(limit, 100))
        var queryString = String(format: "near=%.06f,%.06f", near.coordinate.latitude, near.coordinate.longitude)
        queryString += "&radius=\(radius)&limit=\(finalLimit)"
        
        if let tags = tags, tags.count > 0 {
            queryString += "&tags=\(tags.joined(separator: ","))"
        }
        
        if let metadata = metadata {
            for key in metadata {
                if let keyString = key.key as? String, let valueString = key.value as? String {
                    queryString += "&metadata[\(keyString)]=\(valueString)"
                }
            }
        }
        
        guard let urlString  = "\(RadarSettings.host())/v1/search/geofences?\(queryString)".addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed) else {
            return //TODO: DO WE NEED TO CALL completionHandler
        }
        
        apiHelper.request(method: "GET", url: urlString, headers: RadarAPIClient.headers(withPublishableKey: publishableKey), params: nil, sleep: false) { status, res in
            
            //TODO: GET RID OF CODE DUPLICATE LINES
            guard let res = res else {
                return completionHandler(status, nil, nil)
            }
            
            if status != .success {
                return completionHandler(status, nil, nil)
            }
            
            if let geofencesArr = res["geofences"] as? [AnyHashable], let geofences = RadarGeofence.geofences(geofencesArr) {
                return completionHandler(.success, res, geofences)
            } else {
                completionHandler(.errorServer, nil, nil)
            }
            
            
        }
    }
    
    func searchBeacons(near: CLLocation, radius: Int, limit: Int, completionHandler: @escaping RadarSearchBeaconsAPICompletionHandler) {
        
        guard let publishableKey = RadarSettings.publishableKey() else {
            return completionHandler(.errorPublishableKey, nil, nil)
        }
        
        let finalLimit = Int(min(limit, 100))
        
        var queryString = String(format: "near=%.06f,%.06f", near.coordinate.latitude, near.coordinate.longitude)
        queryString += "&radius=\(radius)"
        queryString += "&limit=\(finalLimit)"
        
        guard let urlString  = "\(RadarSettings.host())/v1/search/beacons?\(queryString)".addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed) else {
            return //TODO: DO WE NEED TO CALL completionHandler
        }
        
        apiHelper.request(method: "GET", url: urlString, headers: RadarAPIClient.headers(withPublishableKey: publishableKey), params: nil, sleep: false) { status, res in
            
            //TODO: GET RID OF CODE DUPLICATE LINES
            guard let res = res else {
                return completionHandler(status, nil, nil)
            }
            
            if status != .success {
                return completionHandler(status, nil, nil)
            }
            
            if let beaconsArr = res["beacons"] as? [AnyHashable], let beacons = RadarBeacon.beacons(beaconsArr) {
                return completionHandler(.success, res, beacons)
            } else {
                completionHandler(.errorServer, nil, nil)
            }
            
        }
        
    }
    
    func autocomplete(query: String, near: CLLocation?, layers: [String]?, limit: Int, country: String?, completionHandler: @escaping RadarGeocodeAPICompletionHandler) {
        
        guard let publishableKey = RadarSettings.publishableKey() else {
            return completionHandler(.errorPublishableKey, nil, nil)
        }
        
        let finalLimit = Int(min(limit, 100))
        
        var queryString = "query=\(query)"
        
        if let near = near {
            queryString += String(format: "&near=%.06f,%.06f", near.coordinate.latitude, near.coordinate.longitude)
        }
        
        if let layers = layers, layers.count > 0 {
            queryString += "&layers=\(layers.joined(separator: ","))"
        }
        
        if limit != 0 {
            queryString += "&limit=\(finalLimit)"
        }
        
        if let country = country {
            queryString += "&country=\(country)"
        }
        
        guard let urlString  = "\(RadarSettings.host())/v1/search/autocomplete?\(queryString)".addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed) else {
            return //TODO: DO WE NEED TO CALL completionHandler
        }
        
        apiHelper.request(method: "GET", url: urlString, headers: RadarAPIClient.headers(withPublishableKey: publishableKey), params: nil, sleep: false) { status, res in
            
            //TODO: GET RID OF CODE DUPLICATE LINES
            guard let res = res else {
                return completionHandler(status, nil, nil)
            }
            
            if status != .success {
                return completionHandler(status, nil, nil)
            }
            
            if let addressesArr = res["addresses"] as? [AnyHashable], let addresses = RadarAddress.addresses(addressesArr) {
                return completionHandler(.success, res, addresses)
            } else {
                return completionHandler(.errorServer, nil, nil)
            }
            
        }
        
    }
    
    func geocodeAddress(query: String, completionHandler: @escaping RadarGeocodeAPICompletionHandler) {
        
        guard let publishableKey = RadarSettings.publishableKey() else {
            return completionHandler(.errorPublishableKey, nil, nil)
        }
        
        guard let urlString  = "\(RadarSettings.host())/v1/geocode/forward?query=\(query)".addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed) else {
            return //TODO: DO WE NEED TO CALL completionHandler
        }
        
        apiHelper.request(method: "GET", url: urlString, headers: RadarAPIClient.headers(withPublishableKey: publishableKey), params: nil, sleep: false) { status, res in
            
            //TODO: GET RID OF CODE DUPLICATE LINES
            guard let res = res else {
                return completionHandler(status, nil, nil)
            }
            
            if status != .success {
                return completionHandler(status, nil, nil)
            }
            
            if let addressesArr = res["addresses"] as? [AnyHashable], let addresses = RadarAddress.addresses(addressesArr) {
                return completionHandler(.success, res, addresses)
            } else {
                return completionHandler(.errorServer, nil, nil)
            }
            
        }
        
    }
    
    func reverseGeocode(location: CLLocation, completionHandler: @escaping RadarGeocodeAPICompletionHandler) {
        
        guard let publishableKey = RadarSettings.publishableKey() else {
            return completionHandler(.errorPublishableKey, nil, nil)
        }
        
        guard let urlString  = "\(RadarSettings.host())/v1/geocode/reverse?\(String(format: "coordinates=%.06f,%.06f", location.coordinate.latitude, location.coordinate.longitude))".addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed) else {
            return //TODO: DO WE NEED TO CALL completionHandler
        }
        
        apiHelper.request(method: "GET", url: urlString, headers: RadarAPIClient.headers(withPublishableKey: publishableKey), params: nil, sleep: false) { status, res in
            
            //TODO: GET RID OF CODE DUPLICATE LINES
            guard let res = res else {
                return completionHandler(status, nil, nil)
            }
            
            if status != .success {
                return completionHandler(status, nil, nil)
            }
            
            if let addressesArr = res["addresses"] as? [AnyHashable], let addresses = RadarAddress.addresses(addressesArr) {
                return completionHandler(.success, res, addresses)
            } else {
                return completionHandler(.errorServer, nil, nil)
            }
            
        }
        
    }
    
    func ipGeocode(completionHandler: @escaping RadarIPGeocodeAPICompletionHandler) {
        
        guard let publishableKey = RadarSettings.publishableKey() else {
            return completionHandler(.errorPublishableKey, nil, nil, false)
        }
        
        apiHelper.request(method: "GET", url: "\(RadarSettings.host())/v1/geocode/ip", headers: RadarAPIClient.headers(withPublishableKey: publishableKey), params: nil, sleep: false) { status, res in
            
            //TODO: GET RID OF CODE DUPLICATE LINES
            guard let res = res else {
                return completionHandler(status, nil, nil, false)
            }
            
            if status != .success {
                return completionHandler(status, nil, nil, false)
            }
            
            if let addressDict = res["address"] as? [AnyHashable: Any] {
                return completionHandler(.success, res, RadarAddress(addressDict), (res["proxy"] as? NSNumber)?.boolValue ?? false)
            } else {
                return completionHandler(.errorServer, nil, nil, false)
            }
            
        }
        
    }
    
    func getDistance(origin: CLLocation, destination: CLLocation, modes: RadarRouteMode, units: RadarRouteUnits, geometryPoints: Int, completionHandler: @escaping RadarDistanceAPICompletionHandler) {
        
        guard let publishableKey = RadarSettings.publishableKey() else {
            return completionHandler(.errorPublishableKey, nil, nil)
        }
        
        var queryString = String(format: "origin=%.06f,%.06f&destination=%.06f,%.06f", origin.coordinate.latitude, origin.coordinate.longitude, destination.coordinate.latitude, destination.coordinate.longitude)
        
        var modesArr = [String]()
        
        if modes == .foot {
            modesArr.append("foot")
        }
        
        if modes == .bike {
            modesArr.append("bike")
        }
        
        if modes == .car {
            modesArr.append("car")
        }
        
        if modes == .truck {
            modesArr.append("truck")
        }
        
        if modes == .motorbike {
            modesArr.append("motorbike")
        }
        
        queryString += "&modes=\(modesArr.joined(separator: ","))"
        
        queryString += "&units=\(units == .metric ? "metric" : "imperial")"
        
        if geometryPoints > 1 {
            queryString += "&geometryPoints=\(geometryPoints)"
        }
        
        queryString += "&geometry=linestring"
        
        guard let urlString = "\(RadarSettings.host())/v1/route/distance?\(queryString)".addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed) else {
            return //TODO: DO WE NEED TO CALL completionHandler
        }
        
        apiHelper.request(method: "GET", url: urlString, headers: RadarAPIClient.headers(withPublishableKey: publishableKey), params: nil, sleep: false) { status, res in
            
            //TODO: GET RID OF CODE DUPLICATE LINES
            guard let res = res else {
                return completionHandler(status, nil, nil)
            }
            
            if status != .success {
                return completionHandler(status, nil, nil)
            }
            
            if let routesDict = res["routes"] as? [AnyHashable: Any] {
                return completionHandler(.success, res, RadarRoutes(routesDict))
            } else {
                completionHandler(.errorServer, nil, nil)
            }
            
        }
        
    }
    
    func getMatrix(origins: [CLLocation], destinations: [CLLocation], mode: RadarRouteMode, units: RadarRouteUnits, completionHandler: @escaping RadarMatrixAPICompletionHandler) {
        
        guard let publishableKey = RadarSettings.publishableKey() else {
            return completionHandler(.errorPublishableKey, nil, nil)
        }
        
        var queryString = "origins=\(origins.map{String(format: "%.06f,%.06f", $0.coordinate.latitude, $0.coordinate.longitude)}.joined(separator: "|"))"
        queryString += "destinations=\(destinations.map{String(format: "%.06f,%.06f", $0.coordinate.latitude, $0.coordinate.longitude)}.joined(separator: "|"))"
        
        var modeStr = ""
        
        if mode == .foot {
            modeStr = "foot"
        } else if mode == .bike {
            modeStr = "bike"
        } else if mode == .car {
            modeStr = "car"
        } else if mode == .truck {
            modeStr = "truck"
        } else if mode == .motorbike {
            modeStr = "motorbike"
        }
        
        queryString += "&mode=\(modeStr)"
        
        queryString += "&units=\(units == .metric ? "metric" : "imperial")"
        
        RadarLogger.sharedInstance.log(level: .info, message: queryString)
        
        guard let urlString = "\(RadarSettings.host())/v1/route/matrix?\(queryString)".addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed) else {
            return  //TODO: DO WE NEED TO CALL completionHandler
        }
        
        apiHelper.request(method: "GET", url: urlString, headers: RadarAPIClient.headers(withPublishableKey: publishableKey), params: nil, sleep: false) { status, res in
            
            //TODO: GET RID OF CODE DUPLICATE LINES
            guard let res = res else {
                return completionHandler(status, nil, nil)
            }
            
            if status != .success {
                return completionHandler(status, nil, nil)
            }
            
            if let matrixArr = res["matrix"] as? [AnyHashable] {
                return completionHandler(.success, res, RadarRouteMatrix(matrixArr))
            } else {
                completionHandler(.errorServer, nil, nil)
            }
 
        }

    }
    
}
