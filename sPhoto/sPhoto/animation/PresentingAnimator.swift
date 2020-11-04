//
//  PresentingAnimator.swift
//  Inspirato
//
//  Created by Justin Vallely on 6/9/17.
//  Copyright © 2017 Inspirato. All rights reserved.
//

import Foundation
import UIKit


class PresentingAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    
    private let parentView: UIView
    private let collectionView: UICollectionView
    private let indexPath: IndexPath
    private let originFrame: CGRect
    private let fromImage: UIImage?
    
    private let duration: TimeInterval = 0.25
    
    init(parentView: UIView, collectionView: UICollectionView, indexPath: IndexPath, image: UIImage?) {
        self.parentView = parentView
        self.collectionView = collectionView
        self.indexPath = indexPath
        
        let unconvertedFrame = collectionView.getFrameFromCollectionViewCell(for: indexPath)
        var originFrame = collectionView.convert(unconvertedFrame, to: parentView)
        if originFrame.minY < collectionView.contentInset.top {
            originFrame = CGRect(x: originFrame.minX, y: collectionView.contentInset.top, width: originFrame.width, height: originFrame.height - (collectionView.contentInset.top - originFrame.minY))
        }
        
        self.originFrame = originFrame
        self.fromImage = image
        super.init()
    }
    
    
    
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return self.duration
    }

    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {

        guard let toView = transitionContext.view(forKey: .to),
              let cell = self.collectionView.cellForItem(at: self.indexPath),
              let image = self.fromImage
            else {
                transitionContext.completeTransition(true)
                return
        }

        let finalFrame = toView.frame

        let viewToAnimate = UIImageView(frame: self.originFrame)
        viewToAnimate.image = image
        viewToAnimate.contentMode = .scaleAspectFill
        viewToAnimate.clipsToBounds = true
        
        let backView = UIView(frame: finalFrame)
        backView.backgroundColor = .clear

        let containerView = transitionContext.containerView
        containerView.addSubview(toView)
        containerView.addSubview(backView)
        containerView.addSubview(viewToAnimate)

        toView.isHidden = true
        cell.isHidden = true

        // Determine the final image height based on final frame width and image aspect ratio
        let imageAspectRatio = viewToAnimate.image!.size.width / viewToAnimate.image!.size.height
        let finalImageheight = finalFrame.width / imageAspectRatio

        // Animate size and position
        UIView.animate(withDuration: duration, animations: {
            viewToAnimate.frame.size.width = finalFrame.width
            viewToAnimate.frame.size.height = finalImageheight
            viewToAnimate.center = CGPoint(x: finalFrame.midX, y: finalFrame.midY)
            backView.backgroundColor = .black
        }, completion:{ _ in
            toView.isHidden = false
            cell.isHidden = false
            backView.removeFromSuperview()
            viewToAnimate.removeFromSuperview()
            transitionContext.completeTransition(true)
        })

    }
}
