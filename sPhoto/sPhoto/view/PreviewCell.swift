//
//  PreviewCell.swift
//  sPhoto
//
//  Created by 곰 on 2020/11/04.
//

import UIKit

class PreviewCell: UICollectionViewCell {
    
    @IBOutlet weak var imageView: UIImageView!
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        self.imageView.image = nil
    }
}
