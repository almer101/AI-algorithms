//
//  TileView.swift
//  Slagalica
//
//  Created by Ivan Almer on 08/08/2019.
//  Copyright © 2019 ialmer. All rights reserved.
//

import UIKit

protocol TileViewDelegate: class {
    
    func panGestureBegan(tileView: TileView, onPosition position: (Int, Int))
    func panGestureChanged(tileView: TileView, onPosition position: (Int, Int), translation: CGPoint)
    func panGestureEnded(tileView: TileView, onPosition position: (Int, Int))
}

@IBDesignable
class TileView: UIView {
    
    private var gradientLayer = CAGradientLayer()
//    private var startColor = UIColor(red: 99.0 / 255.0, green: 93.0 / 255.0, blue: 90.0 / 255.0, alpha: 1)
    private var startColor = UIColor(red: 90.0 / 255.0, green: 76.0 / 255.0, blue: 69.0 / 255.0, alpha: 1)
    private var endColor: UIColor {
        return startColor.withAlphaComponent(0.7)
    }
    private let numberLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = UIColor.white.withAlphaComponent(1)
        label.textAlignment = .center
        return label
    }()
    
    // Properties
    private var value: Int?
    private var position: (Int, Int)?
    private weak var delegate: TileViewDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        installGradient()
        installGestureRecognizer()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        installGradient()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        setupUI()
        updateGradient()
    }
    
    override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        
        installGradient()
        updateGradient()
    }
    
    private func setupUI() {
        numberLabel.removeFromSuperview()
        addSubview(numberLabel)
        
        numberLabel.font = UIFont.systemFont(ofSize: frame.size.height * 0.8)
        
        NSLayoutConstraint.activate([
            numberLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            numberLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
            numberLabel.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])
    }
    
    private func installGradient() {
        gradientLayer.removeFromSuperlayer()
        
        gradientLayer = CAGradientLayer()
        
        layer.addSublayer(gradientLayer)
        gradientLayer.frame = self.bounds
        
        layer.masksToBounds = true
        layer.cornerRadius = 8
    }
    
    private func updateGradient() {
        gradientLayer.colors = [startColor.cgColor, endColor.cgColor]
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 0)
        gradientLayer.endPoint = CGPoint(x: 0.5, y: 1)
        
        gradientLayer.frame = bounds
        gradientLayer.type = .axial
    }
    
    private func installGestureRecognizer() {
        let recognizer = InstantPanGestureRecognizer(target: self, action: #selector(panGestureOccurred))
        addGestureRecognizer(recognizer)
    }
    
    @objc private func panGestureOccurred(recognizer: UIPanGestureRecognizer) {
        guard let position = position else { return }
        
        switch recognizer.state {
        case .began:
            delegate?.panGestureBegan(tileView: self, onPosition: position)
        case .changed:
            let translation = recognizer.translation(in: self)
            delegate?.panGestureChanged(tileView: self, onPosition: position, translation: translation)
        case .ended, .cancelled:
            delegate?.panGestureEnded(tileView: self, onPosition: position)
        default:
            break
        }
    }

}

extension TileView {
    
    func setup(with value: Int, position: (Int, Int), delegate: TileViewDelegate) {
        numberLabel.text = "\(value)"
        self.value = value
        self.position = position
        self.delegate = delegate
    }
}

class InstantPanGestureRecognizer: UIPanGestureRecognizer {
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent) {
        super.touchesBegan(touches, with: event)
        self.state = .began
    }
}
