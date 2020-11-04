//
//  PhotoCell.swift
//  sPhoto
//
//  Created by 곰 on 2020/11/04.
//

import UIKit

class PhotoCell: UICollectionViewCell {
    
    @IBOutlet weak var imageView: UIImageView!
    
    public var image: UIImage? {
        get {
            return self.imageView.image
        }
    }
    
    override var isHighlighted: Bool {
        didSet {
            self.toggleIsHighlighted()
        }
    }
    
    func toggleIsHighlighted() {
        UIView.animate(withDuration: 0.1, delay: 0, options: [.curveEaseOut], animations: {
            self.alpha = self.isHighlighted ? 0.9 : 1.0
            self.transform = self.isHighlighted ?
                CGAffineTransform.identity.scaledBy(x: 0.97, y: 0.97) :
                CGAffineTransform.identity
        })
    }
}
