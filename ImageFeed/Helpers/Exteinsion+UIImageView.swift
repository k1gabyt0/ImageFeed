import UIKit

extension UIImageView {
    func setRounded() {
        layer.cornerRadius = frame.width / 2
        layer.masksToBounds = true
    }
}
