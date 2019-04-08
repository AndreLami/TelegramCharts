//
//  FadeControllersTransitionAnimator.swift
//  GraphPresenter
//
//  Created by Andre on 3/21/19.
//  Copyright © 2019 BB. All rights reserved.
//

import Foundation
import UIKit

class FadeControllersTransitionAnimator: NSObject, PresentationAnimator {
    
    var transitionType: TransitionType?
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.4
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        
        let fromViewController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from)
        
        let toViewController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to)!
        
        let containerView = transitionContext.containerView
        let toView = toViewController.view
        let fromView = fromViewController?.view
        containerView.addSubview(toView!)
        toView?.translatesAutoresizingMaskIntoConstraints = true
        toView?.autoresizingMask = [UIView.AutoresizingMask.flexibleWidth, UIView.AutoresizingMask.flexibleHeight]
        toView?.frame = containerView.bounds
        
        fromView?.alpha = 1.0
        toView?.alpha = 0.0
        UIView.animate(withDuration: self.transitionDuration(using: transitionContext), animations: {
            toView?.alpha = 1.0
            fromView?.alpha = 0.0
        }, completion: { (finished) in
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        }) 
        
    }
    
}

