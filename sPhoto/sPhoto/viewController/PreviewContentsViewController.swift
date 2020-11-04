//
//  PreviewContentsViewController.swift
//  sPhoto
//
//  Created by 곰 on 2020/11/04.
//

import UIKit
import SDWebImage

class PreviewContentsViewController: UIViewController {
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var imageTop: NSLayoutConstraint!
    @IBOutlet weak var imageBottom: NSLayoutConstraint!
    @IBOutlet weak var imageLeading: NSLayoutConstraint!
    @IBOutlet weak var imageTrailing: NSLayoutConstraint!
    
    public var index: Int = 0
    public var url: URL?
    public var thumbnail: UIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        self.configure()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        self.updateZoomScaleForSize(self.view.bounds.size)
        self.updateConstraintsForSize(self.view.bounds.size)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.updateZoomScaleForSize(self.view.bounds.size)
        self.updateConstraintsForSize(self.view.bounds.size)
    }
    
    func configure() {
        self.scrollView.delegate = self
        self.imageView.sd_setImage(with: self.url, placeholderImage: self.thumbnail, completed: nil)
    }
    
    fileprivate func updateZoomScaleForSize(_ size: CGSize) {
        if self.imageView.image == nil {
            return
        }
        
        let widthScale = size.width / self.imageView.image!.size.width
        let heightScale = size.height / self.imageView.image!.size.height
        let minScale = min(widthScale, heightScale)
        self.scrollView.minimumZoomScale = minScale
        
        self.scrollView.zoomScale = minScale
        self.scrollView.maximumZoomScale = minScale * 4
    }
    
    fileprivate func updateConstraintsForSize(_ size: CGSize) {
        let yOffset = max(0, (size.height - self.imageView.frame.height) / 2)
        self.imageTop.constant = yOffset
        self.imageBottom.constant = yOffset
        
        let xOffset = max(0, (size.width - self.imageView.frame.width) / 2)
        self.imageLeading.constant = xOffset
        self.imageTrailing.constant = xOffset

        let contentHeight = yOffset * 2 + self.imageView.frame.height
        self.view.layoutIfNeeded()
        self.scrollView.contentSize = CGSize(width: self.scrollView.contentSize.width, height: contentHeight)
    }
}

extension PreviewContentsViewController: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return self.imageView
    }
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        self.updateConstraintsForSize(self.view.bounds.size)
    }
}
