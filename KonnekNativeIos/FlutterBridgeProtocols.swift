import UIKit

// @objc public protocol MethodChannelProvider: NSObjectProtocol {
@objc public protocol MethodChannelProvider: AnyObject {
    func invokeMethod(_ method: String, arguments: Any?)
    func setMethodCallHandler(_ handler: @escaping (_ method: String, _ arguments: Any?, _ result: @escaping (Any?) -> Void) -> Void)
}

@objc public protocol FlutterEngineProvider: AnyObject {
    var methodChannelProvider: MethodChannelProvider { get }
    func createViewController() -> UIViewController
}

@objc public protocol FlutterEngineFactory: AnyObject {
    func createEngineProvider() -> FlutterEngineProvider
}
