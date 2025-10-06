//
//  EnvironmentConfig.swift
//  KonnekNativeIos
//
//  Created by Fauzan Akmal Mahdi on 01/10/25.
//

import Foundation

class EnvironmentConfig {
    static var flavor: Flavor = .staging
    
    private static var _baseUrl: String = ""
    private static var _baseUrlSocket: String = ""
    
    static var customBaseUrl: String {
        get {
            if _baseUrl.isEmpty {
                switch flavor {
                case .development:
                    return "http://192.168.1.74:8080/"
                case .staging:
                    return "https://stg.wekonnek.id:9443/"
                case .production:
                    return "https://wekonnek.id:9443/"
                }
            } else {
                return _baseUrl
            }
        }
        set {
            _baseUrl = newValue
        }
    }
    
    static func baseUrl() -> String {
        return customBaseUrl
    }
    
    static var customBaseUrlSocket: String {
        get {
            if _baseUrlSocket.isEmpty {
                switch flavor {
                case .development:
                    return "http://192.168.1.74:3000/"
                case .staging:
                    return "https://stgsck.wekonnek.id:3001/"
                case .production:
                    return "https://sck.wekonnek.id:3001/"
                }
            } else {
                return _baseUrlSocket
            }
        }
        set {
            _baseUrlSocket = newValue
        }
    }
    
    static func baseUrlSocket() -> String {
        return customBaseUrlSocket
    }
}
