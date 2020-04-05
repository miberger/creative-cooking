//  creative Cooking Club
//

import UIKit

/// This will show/hide a loading view
class LoadingView {
    /// Static function to present a loading/spinner view when purchasing is in progress
    static func showLoadingView() {
        removeLoadingView()
        let mainView = UIView(frame: UIScreen.main.bounds)
        mainView.backgroundColor = .clear
        let darkView = UIView(frame: mainView.frame)
        darkView.backgroundColor = UIColor.black
        darkView.alpha = 0.2
        mainView.addSubview(darkView)
        let spinnerView = UIActivityIndicatorView(style: .white)
        spinnerView.translatesAutoresizingMaskIntoConstraints = false
        mainView.addSubview(spinnerView)
        spinnerView.centerXAnchor.constraint(equalTo: mainView.centerXAnchor).isActive = true
        spinnerView.centerYAnchor.constraint(equalTo: mainView.centerYAnchor).isActive = true
        spinnerView.startAnimating()
        mainView.tag = 1991
        DispatchQueue.main.async {
            (UIApplication.shared.delegate as? AppDelegate)?.window?.addSubview(mainView)
        }
    }
    
    /// Static function to remove the loading/spinner view
    static func removeLoadingView() {
        DispatchQueue.main.async {
            (UIApplication.shared.delegate as? AppDelegate)?.window?.viewWithTag(1991)?.removeFromSuperview()
        }
    }
}

/// This will take a screenshot of any view also add view as subview
extension UIView {
    func addModalSubview(_ subview: UIView) {
        subview.translatesAutoresizingMaskIntoConstraints = false
        addSubview(subview)
        NSLayoutConstraint.activate([
            subview.leftAnchor.constraint(equalTo: leftAnchor),
            subview.rightAnchor.constraint(equalTo: rightAnchor),
            subview.topAnchor.constraint(equalTo: topAnchor),
            subview.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
}

/// This is a gradient view class
class GradientView: UIView {
    var colors: [CGColor] = [] { didSet { (layer as! CAGradientLayer).colors = colors } }
    override open class var layerClass: AnyClass { return CAGradientLayer.classForCoder() }
    required init?(coder aDecoder: NSCoder) { super.init(coder: aDecoder) }
}

/// This is the shadow view used for recipe view and other views
class ShadowView: UIView {
    private var shadowLayer: CAShapeLayer!
    @IBInspectable var cornerRadius: CGFloat = 25
    override func layoutSubviews() {
        super.layoutSubviews()
        if shadowLayer == nil {
            shadowLayer = CAShapeLayer()
            shadowLayer.path = UIBezierPath(roundedRect: CGRect(x: 0, y: 0, width: bounds.width, height: bounds.height), cornerRadius: cornerRadius).cgPath
            shadowLayer.fillColor = UIColor.white.cgColor
            shadowLayer.shadowColor = UIColor(white: 0, alpha: 0.4).cgColor
            shadowLayer.shadowPath = shadowLayer.path
            shadowLayer.shadowOffset = .zero
            shadowLayer.shadowOpacity = 0.4
            shadowLayer.shadowRadius = 9
            layer.insertSublayer(shadowLayer, at: 0)
        }
    }
}

extension String {
    func index(from: Int) -> Index {
        return self.index(startIndex, offsetBy: from)
    }

    func substring(from: Int) -> String {
        let fromIndex = index(from: from)
        return String(self[fromIndex...])
    }

    func substring(to: Int) -> String {
        let toIndex = index(from: to)
        return String(self[..<toIndex])
    }

    func substring(with r: Range<Int>) -> String {
        let startIndex = index(from: r.lowerBound)
        let endIndex = index(from: r.upperBound)
        return String(self[startIndex..<endIndex])
    }
}

/// here is how substring works
//  let str = "Hello, playground"
//  print(str.substring(from: 7))         // playground
//  print(str.substring(to: 5))           // Hello
//  print(str.substring(with: 7..<11))    // play

extension Collection where Element: Equatable {
    func secondIndex(of element: Element) -> Index? {
        guard let index = firstIndex(of: element) else { return nil }
        return self[self.index(after: index)...].firstIndex(of: element)
    }
    func indexes(of element: Element) -> [Index] {
        var indexes: [Index] = []
        var startIndex = self.startIndex
        while let index = self[startIndex...].firstIndex(of: element) {
            indexes.append(index)
            startIndex = self.index(after: index)
        }
        return indexes
    }
}

