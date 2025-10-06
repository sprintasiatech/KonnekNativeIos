//
//  KonnekNative 2.swift
//  KonnekNativeIos
//
//  Created by Fauzan Akmal Mahdi on 01/10/25.
//

import UIKit

@objc(KonnekNative)
public final class KonnekNative: NSObject {
    public static let shared = KonnekNative()
    
    private var floatingButton: DraggableButton?
    private var clientId: String = ""
    private var clientSecret: String = ""
    private var flavor: String = ""
    private var initConfigData: String = ""
    
    private let konnekService = KonnekService()
    private let flutterHelper = FlutterEngineHelper()
    private var configSetup: ((String) -> Void)?
    
    private override init() {
        super.init()
    }
    
    @objc public func initialize(clientId: String, clientSecret: String, flavor: String = "production") {
        self.clientId = clientId
        self.clientSecret = clientSecret
        self.flavor = flavor
        EnvironmentConfig.flavor = flavor == "production" ? .production : .staging
        
        flutterHelper.setupFlutterEngine()
        flutterHelper.setupMethodChannel()
        fetchConfig()
    }
    
    @objc public func getFloatingButton(fontName: String? = nil) -> UIView {
        let button = DraggableButton()
        button.addTarget(self, action: #selector(floatingButtonTapped), for: .touchUpInside)
        button.isUserInteractionEnabled = true
        floatingButton = button
        
        configSetup = { [weak self] resultData in
            guard let self, let datas = JSONHelper().jsonStringToDict(resultData),
                  let dataMap = datas["data"] as? [String: Any] else { return }
            
            DispatchQueue.main.async {
                if let textButton = dataMap["text_button"] as? String {
                    self.floatingButton?.setTextButton(text: textButton)
                }
                if let textButtonColor = dataMap["text_button_color"] as? String {
                    self.floatingButton?.setTextColor(
                        color: self.floatingButton?.hexStringToUIColor(hex: textButtonColor) ?? .black
                    )
                }
                if let buttonColor = dataMap["button_color"] as? String {
                    self.floatingButton?.setButtonColor(
                        color: self.floatingButton?.hexStringToUIColor(hex: buttonColor) ?? .white
                    )
                }
                if let iosIcon = dataMap["ios_icon"] as? String {
                    self.floatingButton?.setImageButton(
                        image: self.floatingButton?.base64ToUIImage(iosIcon) ?? UIImage()
                    )
                }
                if let fontName {
                    self.floatingButton?.setTextButtonFontStyle(fontName: fontName)
                }
            }
        }
        
        return button
    }
    
    @objc public func showFloatingButton(fontName: String? = nil) {
        guard let window = UIApplication.shared.windows.first else { return }
        
        let buttonTag = 12345
        if window.viewWithTag(buttonTag) == nil {
            let button = getFloatingButton(fontName: fontName)
            button.tag = buttonTag
            window.addSubview(button)
        }
    }
    
    @objc public func floatingButtonTapped() {
        guard let topVC = Self.topViewController() else { return }
        
        if let flutterVC = flutterHelper.createFlutterViewController() {
            flutterVC.modalPresentationStyle = .fullScreen
            invokeFlutter()
            topVC.present(flutterVC, animated: true)
        }
    }
    
    public func invokeFlutter() {
        let args: [String: Any] = [
            "clientId": clientId,
            "clientSecret": clientSecret,
            "flavor": flavor
        ]
        
        if let jsonString = JSONHelper().dictionaryToJsonString(args) {
            flutterHelper.invokeMethod("clientConfigChannel", arguments: jsonString)
        }
        
        if !initConfigData.isEmpty {
            flutterHelper.invokeMethod("fetchConfigData", arguments: initConfigData)
        }
    }
    
    public func startFlutterMethodChannelListener(onEvent: @escaping (String, Any?) -> Void) {
        flutterHelper.setMethodCallHandler { call, result in
            onEvent(call.method, call.arguments)
            result(nil)
        }
    }
    
    private func fetchConfig() {
        konnekService.getConfig(clientIdValue: clientId) { [weak self] result in
            switch result {
            case .success(let data):
                self?.initConfigData = data
                self?.configSetup?(data)
            case .failure(let error):
                print("Error fetching config: \(error.localizedDescription)")
            }
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
}
