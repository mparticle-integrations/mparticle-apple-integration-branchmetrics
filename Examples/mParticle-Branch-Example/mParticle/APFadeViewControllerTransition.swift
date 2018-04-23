//
//  APFadeViewControllerTransition.swift
//  Fortune
//
//  Created by Edward Smith on 2/14/18.
//  Copyright © 2018 Branch. All rights reserved.
//

import UIKit

class APFadeViewControllerTransition: NSObject, UIViewControllerAnimatedTransitioning {

    private let originFrame: CGRect
    let animationTime: TimeInterval = 0.75

    init(originFrame: CGRect) {
        self.originFrame = originFrame
    }

    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return self.animationTime
    }

    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {

        guard
            let toVC = transitionContext.viewController(forKey: .to),
            let fromVC = transitionContext.viewController(forKey: .from),
            let snapshot = toVC.view.snapshotView(afterScreenUpdates: true)
            else { return }

        let duration = transitionDuration(using: transitionContext)
        let finalFrame = transitionContext.finalFrame(for: toVC)

        let containerView = transitionContext.containerView
        containerView.backgroundColor = .white
        containerView.addSubview(toVC.view)
        toVC.view.frame = finalFrame
        toVC.view.isHidden = true;

        containerView.addSubview(snapshot)
        var fromFrame = containerView.convert(self.originFrame, from: nil)
        fromFrame = finalFrame.rectAspectFitIn(rect: fromFrame)
        snapshot.frame = fromFrame
        snapshot.clipsToBounds = true
        snapshot.contentMode = .scaleAspectFit
        snapshot.backgroundColor = .white

        UIView.animate(
            withDuration: duration,
            delay: 0.0,
            options: .curveLinear,
            animations: {
                fromVC.view.alpha = 0.0
                snapshot.frame = finalFrame
            },
            completion: { _ in
                toVC.view.isHidden = false
                snapshot.removeFromSuperview()
                transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
                fromVC.view.alpha = 1.0
            }
        )
    }
}
