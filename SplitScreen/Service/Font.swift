import UIKit

struct Font {
    enum Weight: String {
        case medium = "SFProText-Medium"
        case bold = "SFProText-Bold"
        case heavy = "SFProText-Heavy"
        case semibold = "SFProText-Semibold"
        case light = "SFProText-Light"
        case regular = "SFProText-Regular"
    }

    static func font(weight: Weight, size: CGFloat) -> UIFont {
        return UIFont(name: weight.rawValue, size: size) ?? UIFont.systemFont(ofSize: size, weight: weight.systemWeight)
    }
}

extension Font.Weight {
    var systemWeight: UIFont.Weight {
        switch self {
        case .light: return .light
        case .medium: return .medium
        case .semibold: return .semibold
        case .bold: return .bold
        case .heavy: return .heavy
        case .regular: return .regular
        }
    }
}

extension UIFont {
    static func font(weight: Font.Weight, size: CGFloat) -> UIFont {
        return Font.font(weight: weight, size: size)
    }
}
