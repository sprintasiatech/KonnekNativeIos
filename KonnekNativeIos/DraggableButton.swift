import Foundation
import UIKit

@objc public class DraggableButton: UIButton {
    private let iconImageView = UIImageView()
    private let label = UILabel()
    
    private let buttonHeight: CGFloat = 70
    private let margin: CGFloat = 16
    let minWidth: CGFloat = 195
    let maxWidth: CGFloat = 300
    
    private var userDragged = false
    
    public override init(frame: CGRect) {
        super.init(frame: CGRect(origin: .zero, size: CGSize(width: 190, height: 70)))
        configure()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        configure()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: UIDevice.orientationDidChangeNotification, object: nil)
    }
    
    func hexStringToUIColor(hex: String, alpha: CGFloat = 1.0) -> UIColor? {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")
        
        var rgb: UInt64 = 0
        
        var r: CGFloat = 0.0
        var g: CGFloat = 0.0
        var b: CGFloat = 0.0
        
        let length = hexSanitized.count
        
        guard Scanner(string: hexSanitized).scanHexInt64(&rgb) else { return nil }
        
        if length == 6 {
            r = CGFloat((rgb & 0xFF0000) >> 16) / 255.0
            g = CGFloat((rgb & 0x00FF00) >> 8) / 255.0
            b = CGFloat(rgb & 0x0000FF) / 255.0
        } else if length == 8 {
            r = CGFloat((rgb & 0xFF000000) >> 24) / 255.0
            g = CGFloat((rgb & 0x00FF0000) >> 16) / 255.0
            b = CGFloat((rgb & 0x0000FF00) >> 8) / 255.0
            self.alpha = CGFloat(rgb & 0x000000FF) / 255.0
        } else if length == 3 {
            r = CGFloat((rgb & 0xF00) >> 8) / 15.0
            g = CGFloat((rgb & 0x0F0) >> 4) / 15.0
            b = CGFloat(rgb & 0x00F) / 15.0
        } else {
            return nil
        }
        
        return UIColor(red: r, green: g, blue: b, alpha: alpha)
    }
    
    private func resizeAndReposition() {
        guard let superview = self.superview else { return }
        
        let iconWidth: CGFloat = 45
        let spacing: CGFloat = 8
        let horizontalPadding: CGFloat = 24
        let textWidth = label.intrinsicContentSize.width
        
        let contentWidth = iconWidth + spacing + textWidth + horizontalPadding
        let finalWidth = min(max(contentWidth, minWidth), maxWidth)
        
        let safeInsets = superview.safeAreaInsets
        
        if !userDragged {
            let x = superview.bounds.width - finalWidth - margin - safeInsets.right
            let y = superview.bounds.height - buttonHeight - margin - safeInsets.bottom
            
            self.frame = CGRect(x: x, y: y, width: finalWidth, height: buttonHeight)
        } else {
            var frame = self.frame
            frame.size.width = finalWidth
            
            let maxX = superview.bounds.width - frame.width - margin - safeInsets.right
            let maxY = superview.bounds.height - frame.height - margin - safeInsets.bottom
            
            frame.origin.x = max(margin + safeInsets.left, min(frame.origin.x, maxX))
            frame.origin.y = max(margin + safeInsets.top, min(frame.origin.y, maxY))
            self.frame = frame
        }
    }
    
    func base64ToUIImage(_ base64String: String) -> UIImage? {
        var base64 = base64String
        if base64String.hasPrefix("data:image") {
            let parts = base64String.components(separatedBy: ",")
            guard parts.count == 2 else { return nil }
            base64 = parts[1]
        }
        
        guard let imageData = Data(base64Encoded: base64, options: .ignoreUnknownCharacters) else {
            return nil
        }
        
        guard let image = UIImage(data: imageData) else {
            return nil
        }
        
        return image
    }
    
    @objc private func handleOrientationChange() {
        DispatchQueue.main.async {
            self.resizeAndReposition()
        }
    }
    
    public override func didMoveToSuperview() {
        super.didMoveToSuperview()
        resizeAndReposition()
    }
    
    public func setTextButton(text: String) {
        label.text = text
        resizeAndReposition()
    }
    
    public func setTextButtonFontStyle(fontName: String) {
        if let customFont = UIFont(name: fontName, size: label.font.pointSize) {
            label.font = customFont
            resizeAndReposition()
        } else {
            print("Font '\(fontName)' not found. Check if it's added to Info.plist and installed correctly.")
        }
    }
    
    public func setTextColor(color: UIColor) {
        label.textColor = color
    }
    
    public func setImageButton(image: UIImage) {
        iconImageView.image = image
    }
    
    public func setButtonColor(color: UIColor) {
        self.backgroundColor = color
    }
    
    override public func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
    }
    
    public override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        KonnekNative.shared.floatingButtonTapped()
    }
    
    @objc private func handleDrag(_ gesture: UIPanGestureRecognizer) {
        guard let view = gesture.view, let superview = view.superview else { return }
        
        let translation = gesture.translation(in: superview)
        view.center = CGPoint(x: view.center.x + translation.x, y: view.center.y + translation.y)
        gesture.setTranslation(.zero, in: superview)
        
        if gesture.state == .began {
            userDragged = true
        }
        
        if gesture.state == .ended {
            let safeInsets = superview.safeAreaInsets
            var frame = view.frame
            let maxX = superview.bounds.width - frame.width - margin - safeInsets.right
            let maxY = superview.bounds.height - frame.height - margin - safeInsets.bottom
            
            frame.origin.x = max(margin + safeInsets.left, min(frame.origin.x, maxX))
            frame.origin.y = max(margin + safeInsets.top, min(frame.origin.y, maxY))
            
            UIView.animate(withDuration: 0.2) {
                view.frame = frame
            }
        }
    }
    
    private func configure() {
        self.backgroundColor = .white
        self.layer.cornerRadius = 16
        self.clipsToBounds = true
        
        iconImageView.tintColor = .white
        iconImageView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(iconImageView)
        
        label.text = "    "
        label.textColor = .white
        label.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        label.translatesAutoresizingMaskIntoConstraints = false
        addSubview(label)
        
        NSLayoutConstraint.activate([
            iconImageView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 12),
            iconImageView.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            iconImageView.widthAnchor.constraint(equalToConstant: 45),
            iconImageView.heightAnchor.constraint(equalToConstant: 45),
            
            label.leadingAnchor.constraint(equalTo: iconImageView.trailingAnchor, constant: 8),
            label.centerYAnchor.constraint(equalTo: self.centerYAnchor)
        ])
        
        let pan = UIPanGestureRecognizer(target: self, action: #selector(handleDrag(_:)))
        self.addGestureRecognizer(pan)
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleOrientationChange), name: UIDevice.orientationDidChangeNotification, object: nil)
    }
}
