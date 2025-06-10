import Foundation
import UIKit

@objc public class DraggableButton: UIButton {
    private let iconImageView = UIImageView()
    private let label = UILabel()

    private let buttonWidth: CGFloat = 190
    private let buttonHeight: CGFloat = 70
    private let margin: CGFloat = 16 // margin from bottom and right edges

    public override init(frame: CGRect) {
        super.init(frame: CGRect(origin: .zero, size: CGSize(width: 190, height: 70)))
        configure()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        configure()
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
    
    func base64ToUIImage(_ base64String: String) -> UIImage? {
        // 1. Check if the string has a data prefix (common in web contexts)
        var base64 = base64String
        if base64String.hasPrefix("data:image") {
            // Split the string and get the base64 portion
            let parts = base64String.components(separatedBy: ",")
            guard parts.count == 2 else { return nil }
            base64 = parts[1]
        }
        
        // 2. Convert the base64 string to Data
        guard let imageData = Data(base64Encoded: base64, options: .ignoreUnknownCharacters) else {
//            print("Failed to create Data from base64 string")
            return nil
        }
        
        // 3. Create UIImage from Data
        guard let image = UIImage(data: imageData) else {
//            print("Failed to create UIImage from Data")
            return nil
        }
        
        return image
    }
    
    public func setTextButton(text: String) {
        label.text = text
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
        super.touchesBegan(touches, with: event)  // Make sure to call super!
        // Any custom drag logic
//        let manager = KonnekNative()
//        manager.floatingButtonTapped()
//        print("handler touchesBegan")
    }
    
    public override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        let manager = KonnekNative()
        manager.floatingButtonTapped()
//        print("handler touchesEnded")
    }

    private func configure() {
        self.backgroundColor = .systemBlue
        self.layer.cornerRadius = 16
        self.clipsToBounds = true

        iconImageView.image = UIImage(systemName: "bolt.fill")
        iconImageView.tintColor = .white
        iconImageView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(iconImageView)

        label.text = "Launch Chat"
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
    }

    public override func didMoveToSuperview() {
        super.didMoveToSuperview()

        guard let superview = self.superview else { return }

        // Set default position to bottom-right
        let x = superview.bounds.width - buttonWidth - margin
        let y = superview.bounds.height - buttonHeight - margin
        self.frame = CGRect(x: x, y: y, width: buttonWidth, height: buttonHeight)
    }

    @objc private func handleDrag(_ gesture: UIPanGestureRecognizer) {
        guard let view = gesture.view, let superview = view.superview else { return }

        let translation = gesture.translation(in: superview)
        view.center = CGPoint(x: view.center.x + translation.x, y: view.center.y + translation.y)
        gesture.setTranslation(.zero, in: superview)

        // Optional: Prevent dragging out of bounds
        if gesture.state == .ended {
            var frame = view.frame
            let maxX = superview.bounds.width - buttonWidth
            let maxY = superview.bounds.height - buttonHeight

            frame.origin.x = max(0, min(frame.origin.x, maxX))
            frame.origin.y = max(0, min(frame.origin.y, maxY))

            UIView.animate(withDuration: 0.2) {
                view.frame = frame
            }
        }
    }
}
