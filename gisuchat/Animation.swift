//
//  Animation1.swift
//  gisuchat
//
//  Created by GISU KIM on 2017-01-05.
//  Copyright © 2017 GISU KIM. All rights reserved.
//

import UIKit

class Animation: NSObject, UIViewControllerAnimatedTransitioning, UIViewControllerTransitioningDelegate {
    
    let duration = 0.5
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return self
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return self
    }
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return duration
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        
        guard let fromView = transitionContext.view(forKey: UITransitionContextViewKey.from) else {
            return
        }
        
        guard let toView = transitionContext.view(forKey: UITransitionContextViewKey.to) else {
            return
        }
        
        let containerView = transitionContext.containerView
        
        let screenOffup = CGAffineTransform(translationX: 0, y: -containerView.frame.height)
        let screenoffDown = CGAffineTransform(translationX: 0, y: containerView.frame.height)
        
        containerView.addSubview(fromView)
        containerView.addSubview(toView)
        
        toView.transform = screenOffup
        
        UIView.animate(withDuration: duration, delay: 0.0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.8, options: [], animations: { 
            fromView.transform = screenoffDown
            fromView.alpha = 0.5
            toView.transform = CGAffineTransform.identity
            toView.alpha = 1
            
        }, completion: {(success) in
            transitionContext.completeTransition(success)
        })
        
    }
    
    
}
