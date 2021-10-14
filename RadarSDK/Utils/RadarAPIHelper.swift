//
//  RadarAPIHelper.swift
//  RadarSDK
//
//  Created by Egemen Gulkilik on 14.10.2021.
//

import Foundation

typealias RadarAPICompletionHandler = (RadarStatus, [AnyHashable : Any]?) -> Void

class RadarAPIHelper {
    
    private var queue = DispatchQueue(label: "io.radar.api")
    private var semaphore = DispatchSemaphore(value: 0)
    private var wait = false
    
    func request(method: String, url: String, headers: [AnyHashable : Any]?, params: [AnyHashable : Any]?, sleep: Bool, completionHandler: @escaping RadarAPICompletionHandler) {
        
        queue.async(execute: { [self] in
            if wait {
                _ = semaphore.wait(timeout: DispatchTime.distantFuture)
            }
            wait = true
            
            guard let urlObject = URL(string: url) else {
                wait = false
                semaphore.signal()
                return
            }
            
            var req = URLRequest(url: urlObject)
            req.httpMethod = method
            
            RadarLogger.sharedInstance.log(level: .debug, message: "📍 Radar API request | method = \(method); url = \(url); headers = \(String(describing: headers)); params = \(String(describing: params))")
            
            if let headers = headers {
                for key in headers {
                    if let keyString = key.key as? String {
                        req.addValue(key.value as? String ?? "" , forHTTPHeaderField: keyString)
                    }
                }
            }
            
            if let params = params {
                if let data = try? JSONSerialization.data(withJSONObject: params, options: []) {
                    req.httpBody = data
                } else {
                    wait = false
                    semaphore.signal()
                    return
                }
            }
            
            let configuration = URLSessionConfiguration.default
            configuration.timeoutIntervalForRequest = 10
            configuration.timeoutIntervalForResource = 10
            
            let dataTaskCompletionHandler: ((_ data: Data?, _ response: URLResponse?, _ error: Error?) -> Void) = { [self] data, response, error in
                if error != nil {
                    DispatchQueue.main.async(execute: {
                        completionHandler(.errorNetwork, nil)
                    })
                    wait = false
                    semaphore.signal()
                    return
                }
                
                guard let data = data, let jsonData = try? JSONSerialization.jsonObject(with: data, options: []), let res = jsonData as? [AnyHashable: Any]  else {
                    DispatchQueue.main.async(execute: {
                        completionHandler(.errorServer, nil)
                    })
                    wait = false
                    semaphore.signal()
                    return
                }
                
                var status = RadarStatus.errorUnknown
                
                if let httpURLResponse = response as? HTTPURLResponse {
                    let statusCode = httpURLResponse.statusCode
                    if statusCode >= 200 && statusCode < 400 {
                        status = .success
                    } else if statusCode == 400 {
                        status = .errorBadRequest
                    } else if statusCode == 401 {
                        status = .errorUnauthorized
                    } else if statusCode == 402 {
                        status = .errorPaymentRequired
                    } else if statusCode == 403 {
                        status = .errorForbidden
                    } else if statusCode == 404 {
                        status = .errorNotFound
                    } else if statusCode == 429 {
                        status = .errorRateLimit
                    } else if statusCode >= 500 && statusCode <= 599 {
                        status = .errorServer
                    }
                    RadarLogger.sharedInstance.log(level: .debug, message: String(format: "📍 Radar API response | method = %@; url = %@; statusCode = %ld; res = %@", method, url, statusCode, res))
                }

                if sleep {
                    Thread.sleep(forTimeInterval: 1)
                }
                wait = false
                DispatchQueue.main.async(execute: {
                    completionHandler(status, res)
                })
                semaphore.signal()
            }
            URLSession(configuration: configuration).dataTask(with: req, completionHandler: dataTaskCompletionHandler).resume()
            
        })
        
    }
    
}
