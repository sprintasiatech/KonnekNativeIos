import Foundation
import Flutter
import UIKit
import FlutterPluginRegistrant
import SwiftUI

//@objcMembers
@objc(KonnekNative)
public class KonnekNative: NSObject {
    // public static let shared = KonnekNative()
    
    static private var flutterEngine: FlutterEngine?
    static private var flutterVC: FlutterViewController?
    static private var floatingButton: DraggableButton?
    
    static private(set) var clientId: String = ""
    static private(set) var clientSecret: String = ""
    static private(set) var flavor: String = ""
    
    static private var engineName = "sag_main_engine"
    static private var channelName = "konnek_native"
    static private var methodChannel: FlutterMethodChannel?
    
    static private var konnekService = KonnekService()
    
    static private let jsonEncode = JSONEncoder()
    
    static private var initConfigData = ""
    //    var configSetup: (() -> Void)?
    private var configSetup: ((String) -> Void)?
    
    public override init() {}
    
    static public func getFlutterEngine() -> FlutterEngine? {
        return flutterEngine
    }
    
    // ✅ Called first by the client
    @objc public func initFunction(clientId: String, clientSecret: String, flavor: String) {
        KonnekNative.clientId = clientId
        KonnekNative.clientSecret = clientSecret
        KonnekNative.flavor = flavor
        
        KonnekNative.flutterEngine = FlutterEngine(name: KonnekNative.engineName)
        KonnekNative.flutterEngine?.run()
        if let engine = KonnekNative.flutterEngine {
            GeneratedPluginRegistrant.register(with: engine)
        }
        // Setup method channel
        if let binaryMessenger = KonnekNative.flutterEngine?.binaryMessenger {
            KonnekNative.methodChannel = FlutterMethodChannel(
                name: KonnekNative.channelName,
                binaryMessenger: binaryMessenger,
            )
        }
        callConfig()
    }
    
    private func callConfig() {
        KonnekNative.konnekService.getConfig(clientIdValue: KonnekNative.clientId) { output in
            switch output {
            case .success(let data):
                // print("Success getConfig: \(data)")
                KonnekNative.initConfigData = data
                self.configSetup?(data)
            case .failure(let error):
                print("Error: \(error.localizedDescription)")
            }
        }
    }
    
    // ✅ Client uses this to get the floating button
    @objc public func getFloatingButton() -> UIView {
        let button = DraggableButton()
        button.addTarget(self, action: #selector(floatingButtonTapped), for: .touchUpInside)
        // button.translatesAutoresizingMaskIntoConstraints = false
        button.isUserInteractionEnabled = true
        // button.backgroundColor = .red  // Make sure it's visible
        
        KonnekNative.floatingButton = button
        self.configSetup = { resultData in
            DispatchQueue.main.async {
                if let datas1 = JSONHelper().jsonStringToDict(resultData) {
                    // print("datas1: \(datas1)")
                    if let dataMap = datas1["data"] as? [String: Any],
                       let textStatus = dataMap["text_status"] as? String {
//                        print("textStatus: \(textStatus)")
                    }
                    if let dataMap = datas1["data"] as? [String: Any],
                       let textButton = dataMap["text_button"] as? String {
//                        print("textButton: \(textButton)")
                        KonnekNative.floatingButton?.setTextButton(text: textButton)
                    }
                    if let dataMap = datas1["data"] as? [String: Any],
                       let textButtonColor = dataMap["text_button_color"] as? String {
//                        print("textButtonColor: \(textButtonColor)")
                        KonnekNative.floatingButton?.setTextColor(
                            color: (KonnekNative.floatingButton?.hexStringToUIColor(
                                hex: textButtonColor
                            ) ?? UIColor(.black)
                            )
                        )
                    }
                    if let dataMap = datas1["data"] as? [String: Any],
                       let buttonColor = dataMap["button_color"] as? String {
//                        print("button_color: \(buttonColor)")
                        KonnekNative.floatingButton?.setButtonColor(color: (KonnekNative.floatingButton?.hexStringToUIColor(
                            hex: buttonColor
                        ) ?? UIColor(.white)
                        )
                        )
                    }
                    if let dataMap = datas1["data"] as? [String: Any],
                       let iosIcon = dataMap["ios_icon"] as? String {
                        // print("ios_icon: \(iosIcon)")
//                        print("ios_icon: ")
                        KonnekNative.floatingButton?.setImageButton(image: (KonnekNative.floatingButton?.base64ToUIImage(
                            iosIcon
                        ) ?? UIImage()
                        )
                        )
                    }
                }
            }
        }
        return button
    }
    
    @objc public func floatingButtonTapped() {
//        print("floatingButtonTapped called")
        guard let topVC = Self.topViewController(),
              let engine = KonnekNative.flutterEngine else { return }
        
        KonnekNative.flutterVC = FlutterViewController(engine: engine, nibName: nil, bundle: nil)
        KonnekNative.flutterVC?.modalPresentationStyle = .fullScreen
        
        // Send data to Flutter before showing the screen
        invokeFlutter()
        
        topVC.present(KonnekNative.flutterVC!, animated: true)
    }
    
    /// ✅ Sends data to Flutter via MethodChannel
    public func invokeFlutter() {
        let args: [String: Any] = [
            "clientId": KonnekNative.clientId,
            "clientSecret": KonnekNative.clientSecret,
            "flavor": KonnekNative.flavor
        ]
        
        let newValue: String = JSONHelper().dictionaryToJsonString(args) ?? ""
        
//        print("🔵 Sending initData to Flutter: \(newValue)")
        KonnekNative.methodChannel?.invokeMethod("clientConfigChannel", arguments: newValue)
        if (KonnekNative.initConfigData != "") {
            KonnekNative.methodChannel?.invokeMethod("fetchConfigData", arguments: KonnekNative.initConfigData)
        }
    }
    
    /// ✅ Listen for messages from Flutter
    public func startFlutterMethodChannelListener(onEvent: @escaping (String, Any?) -> Void) {
        KonnekNative.methodChannel?.setMethodCallHandler { call, result in
            onEvent(call.method, call.arguments)
            result(nil) // respond to Flutter if needed
        }
    }
    
    private static func topViewController(base: UIViewController? = UIApplication.shared.windows.first?.rootViewController) -> UIViewController? {
        if let nav = base as? UINavigationController {
            return topViewController(base: nav.visibleViewController)
        } else if let tab = base as? UITabBarController {
            return topViewController(base: tab.selectedViewController)
        } else if let presented = base?.presentedViewController {
            return topViewController(base: presented)
        }
        return base
    }
    
    @objc public func showFloatingButton() {
        guard let window = UIApplication.shared.windows.first else {
//            print("No window found")
            return
        }
        
        let buttonTag = 12345
        
        if window.viewWithTag(buttonTag) == nil {
            let button = getFloatingButton()
            button.tag = buttonTag
            window.addSubview(button)
        } else {
//            print("Floating button already exists")
        }
    }
}

