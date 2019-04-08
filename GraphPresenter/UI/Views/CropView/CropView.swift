//
//  PryntTrimmerView.swift
//  ChartPresenter
//
//  Created by Andre on 3/10/19.
//  Copyright © 2019 BB. All rights reserved.
//

import AVFoundation
import UIKit
import AVKit

final class HandlerView: UIView {
    
    var interactionExtraSpacing: UIEdgeInsets?
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        var hitBounds = self.bounds
        if let insets = self.interactionExtraSpacing {
            hitBounds = hitBounds.inset(by: insets)
        }
        
        return hitBounds.contains(point) ? self : nil
    }
    
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        var hitBounds = self.bounds
        if let insets = self.interactionExtraSpacing {
            hitBounds = hitBounds.inset(by: insets)
        }
        
        return hitBounds.contains(point)
    }
}


public protocol CropViewDelegate: class {
    func didChangePositionBar(leftValuePercent: CGFloat, rightValuePercent: CGFloat)
}

final public class CropView: UIView {
    
    enum ViewTypeTag: Int {
        case left
        case right
        case center
    }
    
    public var mainDayColor: UIColor = UIColor.init(red: 202.0 / 255.0, green: 212.0 / 255.0, blue: 222.0 / 255.0, alpha: 1.0)
    public var mainNightColor: UIColor = UIColor.init(red: 53.0 / 255.0, green: 70.0 / 255.0, blue: 89.0 / 255.0, alpha: 1.0)
    public var maskDayColor: UIColor = UserSettings.dayMainBackgroundColor
    public var maskNightColor: UIColor = UserSettings.nightMainBackgroundColor
    
    init() {
        super.init(frame: .zero)
        self.setupSubviews()
        self.resetHandleViewPosition()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.setupSubviews()
        self.resetHandleViewPosition()
    }

    public override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        if self.isHidden || self.alpha == 0 {
            return nil
        }
        
        let leftHandlerPoint = self.leftHandleView.convert(point, from: self)
        if let leftHandlerResult = self.leftHandleView.hitTest(leftHandlerPoint, with: event) {
            return leftHandlerResult
        }
        
        let rightHandlerPoint = self.rightHandleView.convert(point, from: self)
        if let rightHandlerResult = self.rightHandleView.hitTest(rightHandlerPoint, with: event) {
            return rightHandlerResult
        }
        
        
        return super.hitTest(point, with: event)
    }
    
    public override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        let inset = UIEdgeInsets.init(top: 0, left: -20, bottom: 0, right: 20)
        let hitFrame = bounds.inset(by: inset)
        let result =  hitFrame.contains(point)
        return result
    }
    
    public weak var delegate: CropViewDelegate?

    private let trimView = UIView()
    private let leftHandleView = HandlerView()
    private let rightHandleView = HandlerView()
    private let leftHandleKnob = UIImageView()
    private let rightHandleKnob = UIImageView()
    private let leftMaskView = UIView()
    private let rightMaskView = UIView()

    private var currentLeftConstraint: CGFloat = 0
    private var currentRightConstraint: CGFloat = 0
    private var leftConstraint: NSLayoutConstraint?
    private var rightConstraint: NSLayoutConstraint?
    private var positionConstraint: NSLayoutConstraint?

    private let handleWidth: CGFloat = 14

    private var minimumDistanceBetweenHandle: CGFloat = 50

    private func setupSubviews() {
        self.backgroundColor = UIColor.clear
        self.layer.zPosition = 1
        self.setupTrimmerView()
        self.setupHandleView()
        self.setupMaskView()
        self.setupGestures()
    }

    private func setupTrimmerView() {

        self.trimView.layer.borderWidth = 1.0
        self.trimView.layer.cornerRadius = 2.0
        self.trimView.translatesAutoresizingMaskIntoConstraints = false
        self.trimView.isUserInteractionEnabled = true
        self.trimView.tag = ViewTypeTag.center.rawValue
        self.addSubview(self.trimView)

        self.trimView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        self.trimView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        self.leftConstraint = self.trimView.leftAnchor.constraint(equalTo: leftAnchor)
        self.rightConstraint = self.trimView.rightAnchor.constraint(equalTo: rightAnchor)
        self.leftConstraint?.isActive = true
        self.rightConstraint?.isActive = true
    }

    private func setupHandleView() {

        self.leftHandleView.tag = ViewTypeTag.left.rawValue
        self.leftHandleView.isUserInteractionEnabled = true
        self.leftHandleView.layer.cornerRadius = 2.0
        self.leftHandleView.translatesAutoresizingMaskIntoConstraints = false
        self.leftHandleView.interactionExtraSpacing = UIEdgeInsets.init(top: 0, left: -40, bottom: 0, right: 0)
        
        self.addSubview(self.leftHandleView)

        self.leftHandleView.heightAnchor.constraint(equalTo: heightAnchor).isActive = true
        self.leftHandleView.widthAnchor.constraint(equalToConstant: self.handleWidth).isActive = true
        self.leftHandleView.leftAnchor.constraint(equalTo: self.trimView.leftAnchor).isActive = true
        self.leftHandleView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true

        self.leftHandleKnob.translatesAutoresizingMaskIntoConstraints = false
        self.leftHandleKnob.contentMode = .scaleAspectFit
        self.leftHandleKnob.image = UIImage.init(named: "ic_arrow_left")!.tintImageWith(tintColor: .white)
        self.leftHandleView.addSubview(leftHandleKnob)

        self.leftHandleKnob.heightAnchor.constraint(equalTo: heightAnchor, multiplier: 1).isActive = true
        self.leftHandleKnob.widthAnchor.constraint(equalToConstant: 10).isActive = true
        self.leftHandleKnob.centerYAnchor.constraint(equalTo: self.leftHandleView.centerYAnchor).isActive = true
        self.leftHandleKnob.centerXAnchor.constraint(equalTo: self.leftHandleView.centerXAnchor).isActive = true

        self.rightHandleView.tag = ViewTypeTag.right.rawValue
        self.rightHandleView.isUserInteractionEnabled = true
        self.rightHandleView.layer.cornerRadius = 2.0
        self.rightHandleView.translatesAutoresizingMaskIntoConstraints = false
        self.rightHandleView.interactionExtraSpacing = UIEdgeInsets.init(top: 0, left: 0, bottom: 0, right: -40)
        
        self.addSubview(self.rightHandleView)

        self.rightHandleView.heightAnchor.constraint(equalTo: heightAnchor).isActive = true
        self.rightHandleView.widthAnchor.constraint(equalToConstant: self.handleWidth).isActive = true
        self.rightHandleView.rightAnchor.constraint(equalTo: self.trimView.rightAnchor).isActive = true
        self.rightHandleView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true

        self.rightHandleKnob.translatesAutoresizingMaskIntoConstraints = false
        self.rightHandleKnob.contentMode = .scaleAspectFit
        self.rightHandleKnob.image = UIImage.init(named: "ic_arrow_right")!.tintImageWith(tintColor: .white)
        self.rightHandleView.addSubview(self.rightHandleKnob)

        self.rightHandleKnob.heightAnchor.constraint(equalTo: heightAnchor, multiplier: 1).isActive = true
        self.rightHandleKnob.widthAnchor.constraint(equalToConstant: 10).isActive = true
        self.rightHandleKnob.centerYAnchor.constraint(equalTo: self.rightHandleView.centerYAnchor).isActive = true
        self.rightHandleKnob.centerXAnchor.constraint(equalTo: self.rightHandleView.centerXAnchor).isActive = true
    }

    private func setupMaskView() {

        self.leftMaskView.isUserInteractionEnabled = false
        self.leftMaskView.backgroundColor = self.maskDayColor
        self.leftMaskView.alpha = 0.75
        self.leftMaskView.translatesAutoresizingMaskIntoConstraints = false
        self.insertSubview(self.leftMaskView, belowSubview: self.leftHandleView)

        self.leftMaskView.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        self.leftMaskView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        self.leftMaskView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        self.leftMaskView.rightAnchor.constraint(equalTo: self.leftHandleView.centerXAnchor).isActive = true

        self.rightMaskView.isUserInteractionEnabled = false
        self.rightMaskView.backgroundColor = self.maskDayColor
        self.rightMaskView.alpha = 0.75
        self.rightMaskView.translatesAutoresizingMaskIntoConstraints = false
        self.insertSubview(self.rightMaskView, belowSubview: self.rightHandleView)

        self.rightMaskView.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        self.rightMaskView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        self.rightMaskView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        self.rightMaskView.leftAnchor.constraint(equalTo: self.rightHandleView.centerXAnchor).isActive = true
    }

    private func setupGestures() {

        let leftPanGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(self.handlePanGesture))
        self.leftHandleView.addGestureRecognizer(leftPanGestureRecognizer)
        
        let rightPanGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(self.handlePanGesture))
        self.rightHandleView.addGestureRecognizer(rightPanGestureRecognizer)
        
        let centerPan = UIPanGestureRecognizer.init(target: self, action: #selector(self.handlePanGesture))
        self.trimView.addGestureRecognizer(centerPan)
        
    }

    private func updateLeftConstraint(with translation: CGPoint) {
        let maxConstraint = max(self.rightHandleView.frame.origin.x - self.handleWidth - self.minimumDistanceBetweenHandle, 0)
        let newConstraint = min(max(0, self.currentLeftConstraint + translation.x), maxConstraint)
        self.leftConstraint?.constant = newConstraint
    }

    private func updateRightConstraint(with translation: CGPoint) {
        let maxConstraint = min(2 * self.handleWidth - self.frame.width + self.leftHandleView.frame.origin.x + self.minimumDistanceBetweenHandle, 0)
        let newConstraint = max(min(0, self.currentRightConstraint + translation.x), maxConstraint)
        self.rightConstraint?.constant = newConstraint
    }
    
    private func updateCenter(with translation: CGPoint) {
        self.updateLeftConstraint(with: translation)
        self.updateRightConstraint(with: translation)
    }

    private func resetHandleViewPosition() {
        self.leftConstraint?.constant = 0
        self.rightConstraint?.constant = 0
        self.layoutIfNeeded()
    }

    private func updateSelectedRange() {
        
        guard let leftConstraint = self.leftConstraint, let rightConstraint = self.rightConstraint else {
            return
        }
        
        let leftValuePercent = leftConstraint.constant / self.bounds.width
        let rightValuePercent = 1 - (-rightConstraint.constant / self.bounds.width)
        
        self.delegate?.didChangePositionBar(leftValuePercent: leftValuePercent, rightValuePercent: rightValuePercent)
    }
}

extension CropView {
    
    func applyTheme(_ appTheme: AppTheme, animated: Bool) {
        
        let applyBlock = {
            self.rightMaskView.backgroundColor = appTheme.isDay ? self.maskDayColor : self.maskNightColor
            self.leftMaskView.backgroundColor = appTheme.isDay ? self.maskDayColor : self.maskNightColor
            
            self.trimView.layer.borderColor = appTheme.isDay ? self.mainDayColor.cgColor : self.mainNightColor.cgColor
            self.leftHandleView.backgroundColor = appTheme.isDay ? self.mainDayColor : self.mainNightColor
            self.rightHandleView.backgroundColor = appTheme.isDay ? self.mainDayColor : self.mainNightColor
        }
        
        if animated {
            UIView.animate(withDuration: 0.3, delay: 0, options: .beginFromCurrentState, animations: {
                applyBlock()
            }, completion: nil)
        } else {
            applyBlock()
        }
        
    }
    
}

private extension CropView {
    
    @objc func handlePanGesture(_ gestureRecognizer: UIPanGestureRecognizer) {
        guard let view = gestureRecognizer.view, let superView = gestureRecognizer.view?.superview else { return }
        let tag = view.tag
        switch gestureRecognizer.state {
        case .began:
            if tag == ViewTypeTag.left.rawValue {
                self.currentLeftConstraint = self.leftConstraint!.constant
            } else if tag == ViewTypeTag.right.rawValue {
                self.currentRightConstraint = self.rightConstraint!.constant
            } else {
                self.currentLeftConstraint = self.leftConstraint!.constant
                self.currentRightConstraint = self.rightConstraint!.constant
                self.minimumDistanceBetweenHandle = self.frame.width - self.leftConstraint!.constant + self.rightConstraint!.constant - self.handleWidth * 2
            }
            self.updateSelectedRange()
        case .changed:
            let translation = gestureRecognizer.translation(in: superView)
            if tag == ViewTypeTag.left.rawValue {
                self.updateLeftConstraint(with: translation)
            } else if tag == ViewTypeTag.right.rawValue {
                self.updateRightConstraint(with: translation)
            } else {
                self.updateCenter(with: translation)
            }
            layoutIfNeeded()
            
            self.updateSelectedRange()
            
        case .cancelled, .ended, .failed:
            self.minimumDistanceBetweenHandle = 50
            self.updateSelectedRange()
        default: break
        }
    }
}

extension CropView: UIScrollViewDelegate {
    
    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        self.updateSelectedRange()
    }
    
    public func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            self.updateSelectedRange()
        }
    }
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.updateSelectedRange()
    }
}
