import Foundation
import SwiftUI
import Flutter
import UIKit

public class KonnekFlutterPlugin: NSObject, FlutterPlugin {
    private static var CHANNEL_NAME = "konnek_flutter"
    static var clientId: String = ""
    static var access: String = ""
    
    var environmentConfig = EnvironmentConfig()
    
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: CHANNEL_NAME, binaryMessenger: registrar.messenger())
        let instance = KonnekFlutterPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        //        let konnekService = KonnekService()
        
        func initialize(call: FlutterMethodCall, result: @escaping FlutterResult) {
            guard let args = call.arguments as? Dictionary<String, Any>,
                  let flavor = args["flavor"] as? String else {
                result(FlutterError(code: "INVALID_ARGUMENTS", message: "Missing 'flavor'", details: nil))
                return
            }
            
            //        print("result flavor", flavor, "")
            
            switch flavor.lowercased() {
            case "development":
                EnvironmentConfig.flavor = .development
            case "staging":
                EnvironmentConfig.flavor = .staging
            case "production":
                EnvironmentConfig.flavor = .production
            default:
                EnvironmentConfig.flavor = .staging
            }
            
            result("success initialize \(flavor)")
        }
    }
}


////  ========================================================================================================================================
////  ========================================================================================================================================
class KonnekService {
    private let jsonEncoder = JSONEncoder()
    private let jsonDecoder = JSONDecoder()
    
    static var apiConfig = ApiConfig()
    
    func getConfig(
        clientIdValue: String,
        completion: @escaping (Result<String, Error>) -> Void
    ) {
        var clientId = clientIdValue
        var platformData = "ios"
        KonnekFlutterPlugin.clientId = clientIdValue
        
        Task {
            do {
                var apiService = try await ApiConfig().provideApiService()
                var data = try await apiService.getConfig(
                    clientId: clientIdValue,
                    platform: platformData,
                    completion: completion
                )
            } catch {
                print("error.localizedDescription: \(error.localizedDescription)")
            }
        }
    }
}

//
////  ========================================================================================================================================
////  ========================================================================================================================================
//
enum Flavor {
    case development
    case staging
    case production
}

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
//
////  ========================================================================================================================================
////  ========================================================================================================================================
//
class ApiService {
    private let session: URLSession
    private let baseUrl: String
    
    init(session: URLSession = .shared, baseUrl: String) {
        self.session = session
        self.baseUrl = baseUrl
    }
    
    // MARK: - GET: Config
    func getConfig(
        clientId: String,
        platform: String,
        completion: @escaping (Result<String, Error>) -> Void
    ) {
        let urlString = "\(baseUrl)channel/config/\(clientId)/\(platform)"
        // print("urlString: \(urlString)")
        guard let url = URL(string: urlString) else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        perform(request: request, completion: completion)
    }
    
    
    // MARK: - Perform Request and Return JSON String
    private func perform(request: URLRequest, completion: @escaping (Result<String, Error>) -> Void) {
        session.dataTask(with: request) { data, response, error in
            if let error = error {
                return completion(.failure(error))
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                return completion(.failure(NSError(domain: "Invalid response", code: -1, userInfo: nil)))
            }
            
            // print("[perform] httpResponse \(httpResponse)")
            // print("[perform] httpResponse.statusCode \(httpResponse.statusCode)")
            
            guard let data = data else {
                return completion(.failure(NSError(domain: "No data", code: -1, userInfo: nil)))
            }
            
            //                print("[perform] data \(data)")
            
            guard let jsonString = String(data: data, encoding: .utf8) else {
                return completion(.failure(NSError(domain: "Invalid UTF-8 encoding", code: -3, userInfo: nil)))
            }
            
            completion(.success(jsonString))
            
            
            //                if let jsonString = String(data: data, encoding: .utf8) {
            //                    print("[perform] jsonString \(jsonString)")
            //                    completion(.success(jsonString))
            //                } else {
            //                    completion(.failure(NSError(domain: "Invalid UTF-8 encoding", code: -2, userInfo: nil)))
            //                }
        }.resume()
    }
}
//
////  ========================================================================================================================================
////  ========================================================================================================================================
//
class ApiConfig {
    private var baseUrl = EnvironmentConfig.baseUrl()
    private let session: URLSession
    
    init() {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 120
        config.timeoutIntervalForResource = 120
        
        // Attach logging if needed
        // config.protocolClasses = [LoggingURLProtocol.self] + (config.protocolClasses ?? [])
        
        self.session = URLSession(configuration: config)
    }
    
    func provideApiService() -> ApiService {
        return ApiService(session: session, baseUrl: baseUrl)
    }
}
//
