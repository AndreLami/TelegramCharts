//
//  ViewControllerPresenter.swift
//  GraphPresenter
//
//  Created by Andre on 3/21/19.
//  Copyright © 2019 BB. All rights reserved.
//

import UIKit

typealias CompletionBlock = (Bool?) -> Void

enum TransitionType {
    case present
    case dismiss
    case transition
}

protocol PresentationAnimator : UIViewControllerAnimatedTransitioning {
    var transitionType:TransitionType? { get set }
}

class PresenterPrivateTransitionContext: NSObject, UIViewControllerContextTransitioning {
    var privateViewControllers = [String : UIViewController]()
    var privateContentContainerRect: CGRect?
    let internalContainerView: UIView!

    var completionBlock: CompletionBlock?

    init(fromViewController: UIViewController?, toViewController: UIViewController?, containerView: UIView!) {
        self.internalContainerView = containerView
        
        super.init()
        
        self.privateViewControllers[UITransitionContextViewControllerKey.from.rawValue] = fromViewController
        self.privateViewControllers[UITransitionContextViewControllerKey.to.rawValue] = toViewController
        
        self.privateContentContainerRect = containerView.bounds
    }
    
    func initialFrame(for viewController: UIViewController) -> CGRect {
        return self.privateContentContainerRect!
    }
    
    func finalFrame(for viewController: UIViewController) -> CGRect {
        return privateContentContainerRect!
    }
    
    func viewController(forKey key: UITransitionContextViewControllerKey) -> UIViewController? {
        return privateViewControllers[key.rawValue]
    }
    
    func view(forKey key: UITransitionContextViewKey) -> UIView? {
        var view:UIView? = nil
        view = privateViewControllers[key.rawValue]?.view
        return view
    }
    
    func completeTransition(_ didComplete: Bool) {
        if completionBlock != nil {
            completionBlock!(didComplete)
        }
    }
    
    var containerView : UIView {
        return internalContainerView
    }

    var isAnimated : Bool {
        return false
    }

    var isInteractive : Bool {
        return false
    }

    var transitionWasCancelled : Bool {
        return false
    }

    var presentationStyle : UIModalPresentationStyle {
        return UIModalPresentationStyle.custom
    }

    func updateInteractiveTransition(_ percentComplete: CGFloat) {
    }

    func finishInteractiveTransition() {
    }

    func cancelInteractiveTransition() {
    }

    @available(iOS 8.0, *) var targetTransform : CGAffineTransform {
        return CGAffineTransform.identity
    }

    @available(iOS 10.0, *)
    func pauseInteractiveTransition() {}
    
}


class ViewControllerPresenter: NSObject {
    
    func transition(_ fromViewController: UIViewController?, toViewController: UIViewController, inParentViewController parentViewController: UIViewController, inContainer container: UIView, animator: PresentationAnimator?, completion: ((_ finished: Bool) -> ())?) {
        
        if animator != nil {
            animator!.transitionType = .present
        }
        
        parentViewController.addChild(toViewController)
        
        let transitionContext = PresenterPrivateTransitionContext.init(fromViewController: fromViewController, toViewController: toViewController, containerView: container)
        
        container.addSubview(toViewController.view)
        fromViewController?.willMove(toParent: nil)
        
        transitionContext.completionBlock = { (didComplete) in
            
            toViewController.didMove(toParent: parentViewController)
            animator?.animationEnded?(didComplete!)
            
            fromViewController?.view.removeFromSuperview()
            fromViewController?.removeFromParent()
            
            completion?(didComplete!)
            
        }
        
        if animator != nil {
            animator?.animateTransition(using: transitionContext)
        } else {
            transitionContext.completionBlock!(true)
        }
        
        
    }
    
    func presentViewController(_ viewController: UIViewController, parentViewController: UIViewController, container: UIView, animator: PresentationAnimator?) {

        if animator != nil {
            animator!.transitionType = .present
        }

        let toView = viewController.view
        
        toView?.translatesAutoresizingMaskIntoConstraints = false
        container.translatesAutoresizingMaskIntoConstraints = false
        parentViewController.addChild(viewController)

        let transitionContext = PresenterPrivateTransitionContext.init(fromViewController: nil, toViewController: viewController, containerView: container)

        container.addSubview(toView!)
        
        toView?.topAnchor.constraint(equalTo: container.topAnchor).isActive = true
        toView?.bottomAnchor.constraint(equalTo: container.bottomAnchor).isActive = true
        toView?.leadingAnchor.constraint(equalTo: container.leadingAnchor).isActive = true
        toView?.trailingAnchor.constraint(equalTo: container.trailingAnchor).isActive = true
        
        transitionContext.completionBlock = { (didComplete) in
            
            viewController.didMove(toParent: parentViewController)
            animator?.animationEnded?(didComplete!)
        }
        
        if animator != nil {
            animator?.animateTransition(using: transitionContext)
        } else {
            transitionContext.completionBlock!(true)
        }
        
        
    }
    
    func dismissViewController(_ viewController: UIViewController, container: UIView, animator: PresentationAnimator?) {

        if animator != nil {
            animator!.transitionType = .dismiss
        }
        
        viewController.willMove(toParent: nil)
        


        let transitionContext = PresenterPrivateTransitionContext.init(fromViewController: nil, toViewController: viewController, containerView: container)
    
        transitionContext.completionBlock = { (didComplete) in
            
            viewController.view.removeFromSuperview()
            viewController.removeFromParent()

            animator?.animationEnded?(didComplete!)
        }

        if animator != nil {
            animator?.animateTransition(using: transitionContext)
        } else {
            transitionContext.completionBlock!(true)
        }
        
    }

}
