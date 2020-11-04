//
//  DetailCollectionViewController.swift
//  sPhoto
//
//  Created by 곰 on 2020/11/04.
//

import UIKit
import Toaster
import SDWebImage
import FSPagerView

protocol DetailCollectionViewControllerDelegate {
    func dragMove(indexPath: IndexPath)
    func dragEnd(indexPath: IndexPath)
    func changeIndex(before: IndexPath, after: IndexPath)
}

class DetailCollectionViewController: UIViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var bottomFrame: UIView!
    @IBOutlet weak var bottomSafeFrame: UIView!
    @IBOutlet weak var copyButton: UIButton! {
        didSet {
            self.copyButton.addTarget(self, action: #selector(self.copyButtonAction(_:)), for: .touchUpInside)
        }
    }
    
    public var backgroundColor: UIColor {
        get {
            return self.view.backgroundColor!
        }
        set {
            self.view.backgroundColor = newValue
        }
    }
    
    public var viewModel: DetailCollectionViewModel?
    public var currentIndex: IndexPath?
    public var currentImage: UIImage? {
        get {
            if let indexPath = self.currentIndex {
                if let cell = self.collectionView.cellForItem(at: indexPath) as? DetailCell {
                    return cell.imageView.image
                }
            }
            return nil
        }
    }
    public var currentImageView: UIImageView? {
        get {
            if let indexPath = self.currentIndex {
                if let cell = self.collectionView.cellForItem(at: indexPath) as? DetailCell {
                    return cell.imageView
                }
            }
            return nil
        }
    }
    public var currentCenter: CGPoint = .zero
    public var delegate: DetailCollectionViewControllerDelegate?
    
//    private let thumbnailCollectionView: FSPagerView = FSPagerView()
    private var thumbnailCurrentIndex: Int = 0
    private var hideStatusBar: Bool = false {
        didSet {
            setNeedsStatusBarAppearanceUpdate()
        }
    }
    
    override var prefersStatusBarHidden: Bool {
        return self.hideStatusBar
    }
    
    
    private var bottomView: ThumbnailCollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        self.configure()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        DispatchQueue.main.async {
            if let indexPath = self.currentIndex {
                self.collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: false)
//                self.thumbnailCollectionView.scrollToItem(at: indexPath.row, animated: false)
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.showBottomFrame()
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        print("DetailCollectionViewController viewWillTransition() size : \(size)")
        
        self.collectionView.collectionViewLayout.invalidateLayout()
    }
    
    deinit {
        print("DetailCollectionViewController deinit")
    }
    
    //MARK: -
    func configure() {
        if self.viewModel == nil {
            return
        }
        
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        
        let pan = PanDirectionGestureRecognizer(direction: .vertical, target: self, action: #selector(self.wasDragged(_:)))
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.tapGestureAction(_:)))
        self.collectionView.addGestureRecognizer(pan)
        self.collectionView.addGestureRecognizer(tap)
        
        self.currentIndex = IndexPath(row: self.viewModel!.startIndex, section: 0)
        self.bottomFrame.isHidden = true
        
        
        self.bottomView = ThumbnailCollectionView(frame: self.bottomSafeFrame.bounds)
        self.bottomView.delegate = self
        self.bottomSafeFrame.addSubview(self.bottomView)
        self.bottomView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            self.bottomView.leadingAnchor.constraint(equalTo: self.bottomSafeFrame.leadingAnchor),
            self.bottomView.trailingAnchor.constraint(equalTo: self.bottomSafeFrame.trailingAnchor),
            self.bottomView.topAnchor.constraint(equalTo: self.bottomSafeFrame.topAnchor),
            self.bottomView.bottomAnchor.constraint(equalTo: self.bottomSafeFrame.bottomAnchor)
        ])

        
        
//        self.thumbnailCollectionView.frame = self.bottomSafeFrame.frame
//        self.thumbnailCollectionView.delegate = self
//        self.thumbnailCollectionView.dataSource = self
//        self.thumbnailCollectionView.transformer = FSPagerViewTransformer(type: .linear)
//        self.thumbnailCollectionView.register(FSPagerViewCell.self, forCellWithReuseIdentifier: FSPagerViewCell.identifier)
//        self.thumbnailCollectionView.itemSize = CGSize(width: 68, height: self.bottomSafeFrame.frame.height - 24)
//        self.bottomSafeFrame.addSubview(self.thumbnailCollectionView)
//
//        self.thumbnailCollectionView.translatesAutoresizingMaskIntoConstraints = false
//        NSLayoutConstraint.activate([
//            self.thumbnailCollectionView.widthAnchor.constraint(equalTo: self.bottomSafeFrame.widthAnchor),
//            self.thumbnailCollectionView.heightAnchor.constraint(equalTo: self.bottomSafeFrame.heightAnchor),
//            self.thumbnailCollectionView.centerXAnchor.constraint(equalTo: self.bottomSafeFrame.centerXAnchor),
//            self.thumbnailCollectionView.centerYAnchor.constraint(equalTo: self.bottomSafeFrame.centerYAnchor)
//        ])
    }
    
    func showBottomFrame() {
        let isHidden = !self.bottomFrame.isHidden
        if !isHidden {
            self.bottomFrame.alpha = 0
            self.bottomFrame.isHidden = false
        } else {
            self.bottomFrame.alpha = 1
        }
        UIView.animate(withDuration: 0.15, animations: {
            if isHidden {
                self.bottomFrame.alpha = 0
            } else {
                self.bottomFrame.alpha = 1
            }
        }, completion: { (complte) in
            self.bottomFrame.isHidden = isHidden
            self.hideStatusBar = isHidden
        })
    }
    
    func scrollToItem(indexPath: IndexPath) {
        Log(" index : \(indexPath) !")
        if indexPath == self.currentIndex {
            return
        }
        
        self.collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
        if let current = self.currentIndex {
            self.delegate?.changeIndex(before: current, after: indexPath)
        }
        self.currentIndex = indexPath
        self.thumbnailCurrentIndex = indexPath.row
    }
    
    
    //MARK: - action
    @objc func copyButtonAction(_ sender: Any) {
        Log(" copy !")
        if let indexPath = self.currentIndex,
           let data = self.viewModel?.originData(index: indexPath.row),
           let type = self.viewModel?.typeString(index: indexPath.row) {
            
            Log("copy ! data : \(data.count), type : \(type)")
            UIPasteboard.general.setData(data, forPasteboardType: type)
            Toast(text: "copy!").show()
        }
    }
    
    @objc func tapGestureAction(_ gesture: UITapGestureRecognizer) {
        Log(" tap !")
        
        self.showBottomFrame()
    }
    
    @objc func wasDragged(_ gesture: PanDirectionGestureRecognizer) {
        guard let image = gesture.view else { return }
        
        let translation = gesture.translation(in: self.view)
        if translation.y < 0 {
            // reset everything
            UIView.animate(withDuration: 0.15) {
                self.view.backgroundColor = self.backgroundColor.withAlphaComponent(1.0)
                image.center = CGPoint(x: self.view.bounds.midX, y: self.view.bounds.midY)
            } completion: { (complete) in
                self.delegate?.dragEnd(indexPath: self.currentIndex!)
            }
            return
        }
        
        image.center = CGPoint(x: self.view.bounds.midX, y: self.view.bounds.midY + translation.y)
        self.currentCenter = image.center

        let yFromCenter = image.center.y - self.view.bounds.midY

        let alpha = 1 - abs(yFromCenter / self.view.bounds.midY)
        self.view.backgroundColor = self.backgroundColor.withAlphaComponent(alpha)
        
        if gesture.state == .changed {
            self.delegate?.dragMove(indexPath: self.currentIndex!)
        } else if gesture.state == .ended {
            var swipeDistance: CGFloat = 0
            let swipeBuffer: CGFloat = 50
            var animateImageAway = false

            if yFromCenter > -swipeBuffer && yFromCenter < swipeBuffer {
                // reset everything
                UIView.animate(withDuration: 0.15) {
                    self.view.backgroundColor = self.backgroundColor.withAlphaComponent(1.0)
                    image.center = CGPoint(x: self.view.bounds.midX, y: self.view.bounds.midY)
                } completion: { (complete) in
                    self.delegate?.dragEnd(indexPath: self.currentIndex!)
                }
            } else if yFromCenter < -swipeBuffer {
                swipeDistance = 0
                animateImageAway = true
            } else {
                swipeDistance = self.view.bounds.height
                animateImageAway = true
            }

            if animateImageAway {
                if self.modalPresentationStyle != .custom {
                    self.dismiss(animated: true, completion: nil)
                    return
                }

                UIView.animate(withDuration: 0.35, animations: {
                    self.view.alpha = 0
                    image.center = CGPoint(x: self.view.bounds.midX, y: swipeDistance)
                }, completion: { (complete) in
                    self.dismiss(animated: true, completion: nil)
                })
            }

        }
    }
}

//MARK: - UIGestureRecognizerDelegate
extension DetailCollectionViewController: UIGestureRecognizerDelegate {
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        if let gestureRecognizer = gestureRecognizer as? UIPanGestureRecognizer {
            let velocity = gestureRecognizer.velocity(in: self.view)
            var velocityCheck : Bool = false
            if UIDevice.current.orientation.isLandscape {
                velocityCheck = velocity.x < 0
            }
            else {
                velocityCheck = velocity.y < 0
            }
            if velocityCheck {
                return false
            }
        }
        
        return true
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        
        if let indexPath = self.currentIndex {
            if let cell = self.collectionView.cellForItem(at: indexPath) {
                if let detail = cell as? DetailCell {
                    if otherGestureRecognizer == detail.scrollView.panGestureRecognizer {
                        if detail.scrollView.contentOffset.y == 0 {
                            print("offset y = 0")
                            return true
                        }
                    }
                }
            }
        }
        
        return false
    }
}

//MARK: - UICollectionViewDelegate
extension DetailCollectionViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        Log(" indexPath : \(indexPath)")
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        print("scrollViewDidEndDecelerating")
        var visibleRect = CGRect()

        visibleRect.origin = self.collectionView.contentOffset
        visibleRect.size = self.collectionView.bounds.size

        let visiblePoint = CGPoint(x: visibleRect.midX, y: visibleRect.midY)

        guard let indexPath = self.collectionView.indexPathForItem(at: visiblePoint) else { return }
        if let current = self.currentIndex {
            if current.row != indexPath.row {
                self.delegate?.changeIndex(before: current, after: indexPath)
            }
        }
        self.currentIndex = indexPath
        self.thumbnailCurrentIndex = indexPath.row
//        self.thumbnailCollectionView.scrollToItem(at: indexPath.row, animated: true)
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        print("scrollViewDidEndDragging")
    }
}

//MARK: - UICollectionViewDataSource
extension DetailCollectionViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.viewModel!.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
//        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: DetailCell.identifier, for: indexPath)
//        if let detail = cell as? DetailCell {
//            detail.index = indexPath.row
//            detail.imageView.sd_setImage(with: self.viewModel!.originUrl(index: indexPath.row), completed: { (image, error, type, url) in
//                DispatchQueue.main.async {
//                    detail.update()
//                }
//            })
//        }
        
        // cell 테스트용
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PreviewCell.identifier, for: indexPath)
        if let preview = cell as? PreviewCell {
            preview.imageView.sd_setImage(with: self.viewModel!.originUrl(index: indexPath.row), completed: nil)
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        Log(" indexPath : \(indexPath)")
        if let detail = cell as? DetailCell {
            detail.update()
        }
    }
}

//MARK: - UICollectionViewDelegateFlowLayout
extension DetailCollectionViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, targetContentOffsetForProposedContentOffset proposedContentOffset: CGPoint) -> CGPoint {
        if let indexPath = self.currentIndex {
            // https://stackoverflow.com/questions/63171869/uicollectionview-horizontal-paging-not-centring-after-rotation
            let attributes =  collectionView.layoutAttributesForItem(at: indexPath)
            let newOriginForOldIndex = attributes?.frame.origin
            return newOriginForOldIndex ?? proposedContentOffset
        }
        
        return .zero
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let size = collectionView.bounds.size
//        print("collectionViewLayout sizeForItemAt indexPath : \(indexPath), size : \(size)")
        return size
    }
}

//MARK: - FSPagerViewDelegate
extension DetailCollectionViewController: FSPagerViewDelegate {
    func pagerViewDidScroll(_ pagerView: FSPagerView) {
        if self.thumbnailCurrentIndex != pagerView.currentIndex {
            self.thumbnailCurrentIndex = pagerView.currentIndex
        }
    }
    
    func pagerViewWillEndDragging(_ pagerView: FSPagerView, targetIndex: Int) {
        print("pagerViewWillEndDragging pagerView.currentIndex : \(pagerView.currentIndex)")
        if let index = self.currentIndex {
            if index.row != self.thumbnailCurrentIndex {
                self.currentIndex = IndexPath(row: self.thumbnailCurrentIndex, section: 0)
                self.collectionView.scrollToItem(at: self.currentIndex!, at: .centeredHorizontally, animated: true)
            }
        }
    }
}

//MARK: - FSPagerViewDataSource
extension DetailCollectionViewController: FSPagerViewDataSource {
    func numberOfItems(in pagerView: FSPagerView) -> Int {
        return self.viewModel!.count
    }
    
    func pagerView(_ pagerView: FSPagerView, cellForItemAt index: Int) -> FSPagerViewCell {
        let cell = pagerView.dequeueReusableCell(withReuseIdentifier: FSPagerViewCell.identifier, at: index)
        cell.imageView?.contentMode = .scaleAspectFill
        cell.imageView?.clipsToBounds = true
        cell.imageView?.sd_setImage(with: self.viewModel?.thumbnailUrl(index: index), completed: nil)
        return cell
    }
}

extension DetailCollectionViewController: ThumbnailCollectionViewDelegate {
    func thumbnailCollectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.viewModel!.count
    }
    
    func thumbnailCollectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ThumbnailCell.identifier, for: indexPath)
        if let thumbnail = cell as? ThumbnailCell {
            thumbnail.imageView?.sd_setImage(with: self.viewModel?.thumbnailUrl(index: indexPath.row), completed: nil)
        }
        
        return cell
    }
    
    func thumbnailCollectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 40, height: collectionView.frame.height * 0.8)
    }
    
//    func thumbnailCollectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
//        let flowLayout = collectionViewLayout as! UICollectionViewFlowLayout
//        let cellWidth: CGFloat = flowLayout.itemSize.width
//        let cellSpacing: CGFloat = flowLayout.minimumInteritemSpacing
//        let cellCount = CGFloat(collectionView.numberOfItems(inSection: section))
//        var collectionWidth = collectionView.frame.size.width
//        if #available(iOS 11.0, *) {
//            collectionWidth -= collectionView.safeAreaInsets.left + collectionView.safeAreaInsets.right
//        }
//        let totalWidth = cellWidth * cellCount + cellSpacing * (cellCount - 1)
//        if totalWidth <= collectionWidth {
//            let edgeInset = (collectionWidth - totalWidth) / 2
//            return UIEdgeInsets(top: flowLayout.sectionInset.top, left: edgeInset, bottom: flowLayout.sectionInset.bottom, right: edgeInset)
//        } else {
//            return flowLayout.sectionInset
//        }
//    }
}
