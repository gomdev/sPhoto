//
//  DismissingAnimator.swift
//  Inspirato
//
//  Created by Justin Vallely on 6/12/17.
//  Copyright © 2017 Inspirato. All rights reserved.
//

import Foundation
import UIKit

class DismissingAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    
    private let parentView: UIView
    private let collectionView: UICollectionView
    private let indexPath: IndexPath
    private let fromFrame: CGRect
    private let toFrame: CGRect
    private let fromImage: UIImage?
    
    private let duration: TimeInterval = 0.25
    
    init(parentView: UIView, collectionView: UICollectionView, indexPath: IndexPath, fromFrame: CGRect, image: UIImage?) {
        self.parentView = parentView
        self.collectionView = collectionView
        self.indexPath = indexPath
        self.fromFrame = fromFrame
        
        let unconvertedFrame = collectionView.getFrameFromCollectionViewCell(for: indexPath)
        var toFrame = collectionView.convert(unconvertedFrame, to: parentView)
        if toFrame.minY < collectionView.contentInset.top {
            toFrame = CGRect(x: toFrame.minX, y: collectionView.contentInset.top, width: toFrame.width, height: toFrame.height - (collectionView.contentInset.top - toFrame.minY))
        }
        
        self.toFrame = toFrame
        self.fromImage = image
        super.init()
    }
    
    private func transitionDidEnd() {
        guard let cell = self.collectionView.cellForItem(at: self.indexPath)
        else {
            return
        }
        
        let cellFrame = self.collectionView.convert(cell.frame, to: self.parentView)
        if cellFrame.minY < self.collectionView.contentInset.top {
            self.collectionView.scrollToItem(at: self.indexPath, at: .top, animated: false)
        } else if cellFrame.maxY > self.parentView.frame.height - self.collectionView.contentInset.bottom {
            self.collectionView.scrollToItem(at: self.indexPath, at: .bottom, animated: false)
        }
    }

    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return self.duration
    }

    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard let fromVC = transitionContext.viewController(forKey: .from),
              let cell = self.collectionView.cellForItem(at: self.indexPath),
              let image = self.fromImage
        else {
            transitionContext.completeTransition(true)
            return
        }
        
        let containerView = transitionContext.containerView

        // Determine our original and final frames
        let viewToAnimate = UIImageView(frame: CGRect(origin: .zero, size: self.fromFrame.size))
        viewToAnimate.image = image
        viewToAnimate.contentMode = .scaleAspectFill
        viewToAnimate.clipsToBounds = true

        containerView.addSubview(viewToAnimate)
        viewToAnimate.center = self.fromFrame.origin
        
        fromVC.view.isHidden = true
        cell.isHidden = true

        // Animate size and position
        UIView.animate(withDuration: duration, animations: {
            viewToAnimate.frame.size.width = self.toFrame.width
            viewToAnimate.frame.size.height = self.toFrame.height
            viewToAnimate.center = CGPoint(x: self.toFrame.midX, y: self.toFrame.midY)
        }, completion: { _ in
            cell.isHidden = false
            viewToAnimate.removeFromSuperview()
            transitionContext.completeTransition(true)
            self.transitionDidEnd()
        })

    }
}
