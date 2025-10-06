import Flutter
import FlutterPluginRegistrant

final class FlutterEngineHelper {
    private static let engineName = "sag_main_engine"
    private static let channelName = "konnek_native"
    
    private var flutterEngine: FlutterEngine?
    private var methodChannel: FlutterMethodChannel?
    
    init() {}
    
    func setupFlutterEngine() {
        flutterEngine = FlutterEngine(name: Self.engineName)
        flutterEngine?.run()
        GeneratedPluginRegistrant.register(with: flutterEngine!)
    }
    
    func setupMethodChannel() {
        guard let binaryMessenger = flutterEngine?.binaryMessenger else { return }
        methodChannel = FlutterMethodChannel(name: Self.channelName, binaryMessenger: binaryMessenger)
    }
    
    func createFlutterViewController() -> FlutterViewController? {
        guard let engine = flutterEngine else { return nil }
        return FlutterViewController(engine: engine, nibName: nil, bundle: nil)
    }
    
    func invokeMethod(_ method: String, arguments: Any?) {
        methodChannel?.invokeMethod(method, arguments: arguments)
    }
    
    func setMethodCallHandler(_ handler: @escaping (FlutterMethodCall, FlutterResult) -> Void) {
        methodChannel?.setMethodCallHandler(handler)
    }
}
