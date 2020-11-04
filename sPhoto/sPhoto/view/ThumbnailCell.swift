//
//  ThumbnailCell.swift
//  sPhoto
//
//  Created by 곰 on 2020/11/04.
//

import UIKit

class ThumbnailCell: UICollectionViewCell {
    
    fileprivate weak var _imageView: UIImageView?
    private var imageViewWidth: NSLayoutConstraint!
    public var imageView: UIImageView? {
        if let _ = self._imageView {
            return self._imageView
        }
        let imageView = UIImageView(frame: .zero)
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        self.contentView.addSubview(imageView)
        self._imageView = imageView
        self._imageView?.translatesAutoresizingMaskIntoConstraints = false
        self.imageViewWidth = self._imageView!.widthAnchor.constraint(equalTo: self.contentView.widthAnchor)
        NSLayoutConstraint.activate([
            self.imageViewWidth,
            self._imageView!.heightAnchor.constraint(equalTo: self.contentView.heightAnchor),
            self._imageView!.centerXAnchor.constraint(equalTo: self.contentView.centerXAnchor),
            self._imageView!.centerYAnchor.constraint(equalTo: self.contentView.centerYAnchor)
        ])
        return imageView
    }
    
    override var isSelected: Bool {
        didSet {
            if self.isSelected {
                NSLayoutConstraint.setMultiplier(0.8, of: &self.imageViewWidth)
            } else {
                NSLayoutConstraint.setMultiplier(1, of: &self.imageViewWidth)
            }
        }
    }
    
    public var cellSize: CGSize? {
        get {
            if let size = self._imageView?.image?.size {
                if size.width > size.height {
                    return CGSize(width: self.frame.width * 2, height: self.frame.height)
                }
            }
            
            return nil
        }
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        self.configure()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.configure()
    }
    
    func configure() {
        
        
    }
}


extension NSLayoutConstraint {

    static func setMultiplier(_ multiplier: CGFloat, of constraint: inout NSLayoutConstraint) {
        NSLayoutConstraint.deactivate([constraint])

        let newConstraint = NSLayoutConstraint(item: constraint.firstItem, attribute: constraint.firstAttribute, relatedBy: constraint.relation, toItem: constraint.secondItem, attribute: constraint.secondAttribute, multiplier: multiplier, constant: constraint.constant)

        newConstraint.priority = constraint.priority
        newConstraint.shouldBeArchived = constraint.shouldBeArchived
        newConstraint.identifier = constraint.identifier

        NSLayoutConstraint.activate([newConstraint])
        constraint = newConstraint
    }

}
