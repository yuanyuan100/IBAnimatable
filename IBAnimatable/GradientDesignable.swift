//
//  Created by Jake Lin on 12/4/15.
//  Copyright © 2015 IBAnimatable. All rights reserved.
//

import UIKit

public protocol GradientDesignable {
  var startColor: UIColor? { get set }
  var endColor: UIColor? { get set }
  var predefinedGradient: GradientType? { get set }
  var startPoint: GradientStartPoint { get set }
}

public extension GradientDesignable where Self: UIView {
  public func configureGradient() {
    let predefinedGradient = configurePredefinedGradient()
    if let startColor = startColor, let endColor = endColor {
      configureGradient(startColor: startColor, endColor: endColor)
    } else if let startColor = predefinedGradient?.start, let endColor = predefinedGradient?.end {
      configureGradient(startColor: startColor, endColor: endColor)
    }
  }
}

fileprivate extension GradientDesignable where Self: UIView {
  func configureGradient(startColor: UIColor, endColor: UIColor) {

    let gradientLayer = makeGradientLayer()
    gradientLayer.colors = [startColor.cgColor, endColor.cgColor]
    gradientLayer.configurePoints(with: startPoint)

    subviews.filter { $0 is PrivateGradientView }.forEach {
      $0.removeFromSuperview()
    }

    let gradientView = PrivateGradientView(frame: bounds, layer: gradientLayer)
    insertSubview(gradientView, at: 0)
  }

  func makeGradientLayer() -> CAGradientLayer {
    let gradientLayer: CAGradientLayer = CAGradientLayer()
    gradientLayer.frame = bounds
    gradientLayer.cornerRadius = layer.cornerRadius
    return gradientLayer
  }

  func configurePredefinedGradient() -> GradientColor? {
    guard let gradientType = predefinedGradient else {
      return nil
    }
    return gradientType.colors
  }
}

public extension GradientDesignable where Self: UINavigationBar {
  public func configureGradient() {
    let predefinedGradient = configurePredefinedGradient()
    if let startColor = startColor, let endColor = endColor {
      configureGradient(startColor: startColor, endColor: endColor)
    } else if let startColor = predefinedGradient?.start, let endColor = predefinedGradient?.end {
      configureGradient(startColor: startColor, endColor: endColor)
    }
  }
}

fileprivate extension GradientDesignable where Self: UINavigationBar {

  func configureGradient(startColor: UIColor, endColor: UIColor) {
    let gradientLayer = makeGradientLayer()
    gradientLayer.colors = [startColor.cgColor, endColor.cgColor]
    gradientLayer.configurePoints(with: startPoint)
    let image = gradientLayer.image()

    self.setBackgroundImage(image, for: .default)
  }

  func makeGradientLayer() -> CAGradientLayer {
    let gradientLayer: CAGradientLayer = CAGradientLayer()

    let statusBarHeight: CGFloat = 64 // UIApplication.shared.statusBarFrame.height
    let navBarFrame = CGRect(x: 0, y: 0, width: bounds.width, height: statusBarHeight)
    gradientLayer.frame = navBarFrame

    gradientLayer.cornerRadius = layer.cornerRadius
    return gradientLayer
  }

}

private class PrivateGradientView: UIView {
  // MARK: - Life cycle

  init(frame: CGRect, layer: CAGradientLayer) {
    super.init(frame: frame)
    self.layer.insertSublayer(layer, at: 0)
    autoresizingMask = [.flexibleWidth, .flexibleHeight]
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override class var layerClass: AnyClass {
    return CAGradientLayer.self
  }

}

extension CAGradientLayer {
  fileprivate func configurePoints(with startPoint: GradientStartPoint) {
    switch startPoint {
    case .top:
      self.startPoint = CGPoint(x: 0.5, y: 0)
      self.endPoint = CGPoint(x: 0.5, y: 1)
    case .topRight:
      self.startPoint = CGPoint(x: 1, y: 0)
      self.endPoint = CGPoint(x: 0, y: 1)
    case .right:
      self.startPoint = CGPoint(x: 1, y: 0.5)
      self.endPoint = CGPoint(x: 0, y: 0.5)
    case .bottomRight:
      self.startPoint = CGPoint(x: 1, y: 1)
      self.endPoint = CGPoint(x: 0, y: 0)
    case .bottom:
      self.startPoint = CGPoint(x: 0.5, y: 1)
      self.endPoint = CGPoint(x: 0.5, y: 0)
    case .bottomLeft:
      self.startPoint = CGPoint(x: 0, y: 1)
      self.endPoint = CGPoint(x: 1, y: 0)
    case .left:
      self.startPoint = CGPoint(x: 0, y: 0.5)
      self.endPoint = CGPoint(x: 1, y: 0.5)
    case .topLeft:
      self.startPoint = CGPoint(x: 0, y: 0)
      self.endPoint = CGPoint(x: 1, y: 1)
    case let .custom(start, end):
      self.startPoint = CGPoint(x: start.x, y: start.y)
      self.endPoint = CGPoint(x: end.x, y: end.y)
    case .none:
      break
    }
  }

  func image() -> UIImage? {
    UIGraphicsBeginImageContext(self.frame.size)
    self.render(in: UIGraphicsGetCurrentContext()!)
    let outputImage = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    return outputImage
  }

}
