//
//  ThumbnailCollectionView.swift
//  sPhoto
//
//  Created by 곰 on 2020/11/04.
//

import UIKit

protocol ThumbnailCollectionViewDelegate {
    func thumbnailCollectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
    func thumbnailCollectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
    func thumbnailCollectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize
//    func thumbnailCollectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets
}

class ThumbnailCollectionView: UIView {
    
    private var collectionView: UICollectionView!
    private var collectionViewLayout: UICollectionViewFlowLayout!
    public var delegate: ThumbnailCollectionViewDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.configure()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.configure()
    }
    
    func configure() {
        
        self.collectionViewLayout = CityCollectionViewFlowLayout(itemSize: CGSize(width: 40, height: self.frame.height * 0.8))
        
        self.collectionView = UICollectionView(frame: .zero, collectionViewLayout: self.collectionViewLayout)
        self.collectionView.frame = self.bounds
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        self.collectionView.showsHorizontalScrollIndicator = false
        self.collectionView.register(ThumbnailCell.self, forCellWithReuseIdentifier: ThumbnailCell.identifier)
        self.addSubview(self.collectionView)
        self.collectionView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            self.collectionView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            self.collectionView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            self.collectionView.topAnchor.constraint(equalTo: self.topAnchor),
            self.collectionView.bottomAnchor.constraint(equalTo: self.bottomAnchor)
        ])
    }
}

extension ThumbnailCollectionView: UICollectionViewDelegate {
//    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//        let cell = collectionView.cellForItem(at: indexPath)
//        print("cell?.frame.width : \(cell?.frame.width)")
//    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        print("scrollViewDidEndDragging decelerate : \(decelerate) !")
        
//        if decelerate {
//            return
//        }
//
//        let point = self.convert(self.center, to: self.collectionView)
//        if let indexPath = self.collectionView.indexPathForItem(at: point) {
//            print("scrollViewDidEndDragging center indexPath : \(indexPath)")
//            if let cell = self.collectionView.cellForItem(at: indexPath) {
//                cell.isSelected = true
//            }
//            self.collectionView.performBatchUpdates {
//                self.collectionViewLayout.invalidateLayout()
//            } completion: { (complete) in
//                self.collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
//            }
//        }
        
//        var indexOfCellWithLargestWidth = 0
//        var largestWidth : CGFloat = 1
//
//        for cell in self.collectionView.visibleCells {
//            if cell.frame.size.width > largestWidth {
//                largestWidth = cell.frame.size.width
//                if let indexPath = self.collectionView.indexPath(for: cell) {
//                    indexOfCellWithLargestWidth = indexPath.item
//                }
//            }
//        }
//
//        let indexPath = IndexPath(item: indexOfCellWithLargestWidth, section: 0)
//        if let cell = self.collectionView.cellForItem(at: indexPath) {
//            cell.isSelected = true
//        }
//
//        self.collectionView.performBatchUpdates {
//            self.collectionViewLayout.invalidateLayout()
//        } completion: { (complete) in
//            self.collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
//        }
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        print("scrollViewWillBeginDragging !")
        
//        let point = self.convert(self.center, to: self.collectionView)
//        if let indexPath = self.collectionView.indexPathForItem(at: point) {
//            print("scrollViewWillBeginDragging center indexPath : \(indexPath)")
//            if let cell = self.collectionView.cellForItem(at: indexPath) {
//                cell.isSelected = false
//            }
//            self.collectionView.performBatchUpdates {
//                self.collectionViewLayout.invalidateLayout()
//            } completion: { (complete) in
//
//            }
//        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        print("scrollViewDidEndDecelerating !")
        
//        var indexOfCellWithLargestWidth = 0
//        var largestWidth : CGFloat = 1
//
//        for cell in self.collectionView.visibleCells {
//            if cell.frame.size.width > largestWidth {
//                largestWidth = cell.frame.size.width
//                if let indexPath = self.collectionView.indexPath(for: cell) {
//                    indexOfCellWithLargestWidth = indexPath.item
//                }
//            }
//        }
//
//        let indexPath = IndexPath(item: indexOfCellWithLargestWidth, section: 0)
//        if let cell = self.collectionView.cellForItem(at: indexPath) {
//            cell.isSelected = true
//        }
//
//        self.collectionView.performBatchUpdates {
//            self.collectionViewLayout.invalidateLayout()
//        } completion: { (complete) in
//            self.collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
//        }
        
//        let point = self.convert(self.center, to: self.collectionView)
//        if let indexPath = self.collectionView.indexPathForItem(at: point) {
//            print("scrollViewDidEndDecelerating center indexPath : \(indexPath)")
//
//            if let cell = self.collectionView.cellForItem(at: indexPath) {
//                cell.isSelected = true
//            }
//            self.collectionView.performBatchUpdates {
//                self.collectionViewLayout.invalidateLayout()
//            } completion: { (complete) in
//                self.collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
//            }
//        }
    }
    
//    func scrollViewDidScroll(_ scrollView: UIScrollView) {
//        print("scrollViewDidScroll isDragging : \(scrollView.isDragging), isDecelerating : \(scrollView.isDecelerating)")
//    }
    
//    func scrollViewDidScroll(_ scrollView: UIScrollView) {
//        // center X of collection View
//        let centerX = self.collectionView.center.x
//
//        // only perform the scaling on cells that are visible on screen
//        for cell in self.collectionView.visibleCells {
//
//            // coordinate of the cell in the viewcontroller's root view coordinate space
//            let basePosition = cell.convert(CGPoint.zero, to: self)
//            let cellCenterX = basePosition.x + self.collectionView.frame.size.height / 2.0
//
//            let distance = fabs(cellCenterX - centerX)
//
//            let tolerance : CGFloat = 0.02
//            var scale = 1.00 + tolerance - (( distance / centerX ) * 0.105)
//            if(scale > 1.0){
//                scale = 1.0
//            }
//
//            // set minimum scale so the previous and next album art will have the same size
//            // I got this value from trial and error
//            // I have no idea why the previous and next album art will not be same size when this is not set 😅
//            if(scale < 0.860091){
//                scale = 0.860091
//            }
//
//            // Transform the cell size based on the scale
//            cell.transform = CGAffineTransform(scaleX: scale, y: scale)
//        }
//    }
}

extension ThumbnailCollectionView: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.delegate!.thumbnailCollectionView(collectionView, numberOfItemsInSection: section)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        return self.delegate!.thumbnailCollectionView(collectionView, cellForItemAt: indexPath)
    }
}

extension ThumbnailCollectionView: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
//        return self.delegate!.thumbnailCollectionView(collectionView, layout: collectionViewLayout, sizeForItemAt: indexPath)
        if let cell = collectionView.cellForItem(at: indexPath) as? ThumbnailCell {
            if cell.isSelected {
                if let _ = cell.cellSize {
                    return CGSize(width: 80, height: self.frame.height * 0.8)
                }
                return CGSize(width: 60, height: self.frame.height * 0.8)
            }
        }
        
        let height = self.frame.height * 0.7
        return CGSize(width: height * 0.5, height: height)
    }
    
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
//        let inset = (self.frame.width * 0.5) - 20 // view width / 2 - cell width
//        return UIEdgeInsets(top: 0, left: inset, bottom: 0, right: inset)
//    }
}
