import Foundation
import Flutter
import UIKit

public class KonnekFlutterPlugin: NSObject, FlutterPlugin {
    private static let CHANNEL_NAME = "konnek_flutter"
    static var clientId: String = ""
    static var access: String = ""
    
    var environmentConfig = EnvironmentConfig()
    
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: CHANNEL_NAME, binaryMessenger: registrar.messenger())
        let instance = KonnekFlutterPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        let konnekService = KonnekService()
        
        switch call.method {
        case "initialize":
            initialize(call: call, result: result)
        case "getConfig":
            getConfig(call: call, result: result, service: konnekService)
        default:
            result(FlutterMethodNotImplemented)
        }
    }
    
    private func initialize(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any],
              let flavor = args["flavor"] as? String else {
            result(FlutterError(code: "INVALID_ARGUMENTS", message: "Missing 'flavor'", details: nil))
            return
        }
        
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
    
    private func getConfig(call: FlutterMethodCall, result: @escaping FlutterResult, service: KonnekService) {
        guard let args = call.arguments as? [String: Any],
              let clientIdValue = args["clientId"] as? String else {
            result(FlutterError(code: "INVALID_ARGUMENTS", message: "Missing 'clientId'", details: nil))
            return
        }
        
        service.getConfig(clientIdValue: clientIdValue) { res in
            switch res {
            case .success(let jsonString):
                result(jsonString)
            case .failure(let error):
                result(FlutterError(code: "API_ERROR", message: error.localizedDescription, details: nil))
            }
        }
    }
}
