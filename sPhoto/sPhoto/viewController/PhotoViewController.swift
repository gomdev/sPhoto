//
//  PhotoViewController.swift
//  sPhoto
//
//  Created by 곰 on 2020/11/04.
//

import UIKit
import AVFoundation

class PhotoViewController: UIViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    private var selectedIndexPath: IndexPath!
    public var viewModel: PhotoViewModel?
    
    private var pasteButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        self.configure()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("PhotoViewController viewWillAppear")
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.enterForeground(_:)), name: UIApplication.willEnterForegroundNotification, object: nil)
        
        self.checkPaste()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        print("PhotoViewController viewWillDisappear")
        
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        print("PhotoViewController viewWillTransition")
        
        self.collectionView.collectionViewLayout.invalidateLayout()
    }
    
    
    //MARK: -
    func configure() {
        if self.viewModel == nil {
            return
        }
        
        self.title = self.viewModel?.name
        
        self.viewModel?.configure()
        
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        
        self.pasteButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(self.pasteButtonAction(_:)))
//        self.navigationItem.rightBarButtonItems = [self.pasteButton]
        
        let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(self.addButtonAction(_:)))
        self.navigationItem.rightBarButtonItem = addButton
        
        self.viewModel?.updateThumnail.bind({ [weak self] (index) in
            Log(" bind index : \(index) update !")
            self?.updateThumbnail(index: index)
        })
        
        self.viewModel?.insert.bind({ [weak self] (index) in
            Log(" bind index : \(index) insert !")
            self?.insertImage(index: index)
        })
    }
    
    func updateThumbnail(index: Int) {
        Log("index : \(index)")
        let indexPath = IndexPath(row: index, section: 0)
        self.collectionView.performBatchUpdates({
            self.collectionView.reloadItems(at: [indexPath])
        }, completion: nil)
    }
    
    func insertImage(index: Int) {
        Log("index : \(index)")
        self.collectionView.performBatchUpdates({
            self.collectionView.insertItems(at: [IndexPath(row: index, section: 0)])
        }, completion: { (complete) in
            self.collectionView.reloadData()
        })
    }
    
    func checkPaste() {
        self.pasteButton.isEnabled = self.viewModel!.paste
        Log(" paste enable : \(self.pasteButton.isEnabled)")
    }
    
    
    //MARK: - action
    @objc func enterForeground(_ sender: Any) {
        Log(" foreground !!")
        self.checkPaste()
    }
    
    @objc func pasteButtonAction(_ sender: Any) {
        Log(" paste !")
        self.viewModel?.pasteButtonAction()
    }
    
    @objc func addButtonAction(_ sender: Any) {
        Log(" add !")
        
        let pasteAction = UIAlertAction(title: "Paste", style: .default, handler: { (action) in
            self.viewModel?.pasteButtonAction()
        })
        pasteAction.isEnabled = self.viewModel!.paste
        let albumAction = UIAlertAction(title: "Album", style: .default, handler: { (action) in
            
        })
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: { (action) in
//            alertController.dismiss(animated: true, completion: nil)
        })
        
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        alertController.addAction(pasteAction)
        alertController.addAction(albumAction)
        alertController.addAction(cancelAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    
    //MARK: -
    func showDetail(indexPath: IndexPath) {
        self.selectedIndexPath = indexPath
        
        // DetailCollectionViewController
        if let detail = self.storyboard?.instantiateViewController(withIdentifier: DetailCollectionViewController.identifier) as? DetailCollectionViewController {
            detail.viewModel = DetailCollectionViewModel(index: indexPath.row, photos: self.viewModel!.photosAll)
            detail.backgroundColor = UIColor.black
            detail.modalPresentationStyle = .overCurrentContext
            detail.transitioningDelegate = self
            detail.delegate = self

            self.present(detail, animated: true, completion: nil)
        }
        
        
        // PreviewPageViewController
//        if let preview = self.storyboard?.instantiateViewController(withIdentifier: PreviewPageViewController.identifier) as? PreviewPageViewController {
//            preview.viewModel = PreviewPageViewModel(index: indexPath.row, photos: self.viewModel!.photosAll)
//            preview.modalPresentationStyle = .overCurrentContext
//            self.present(preview, animated: true, completion: nil)
//        }
    }
}

extension PhotoViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        
        Log(" indexPath : \(indexPath)")
        self.showDetail(indexPath: indexPath)
    }
}

extension PhotoViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.viewModel!.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PhotoCell.identifier, for: indexPath)
        if let photo = cell as? PhotoCell {
            photo.imageView.image = self.viewModel?.thumnail(index: indexPath.row)
        }
        
        return cell
    }
}

extension PhotoViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if UIApplication.shared.statusBarOrientation.isPortrait {
            let width = (collectionView.frame.width / 3) - 1
            return CGSize(width: width, height: width)
        }
        
        let width = (collectionView.frame.width / 6) - 1
        return CGSize(width: width, height: width)
    }
}

// MARK: UIViewControllerTransitioningDelegate Methods
extension PhotoViewController: UIViewControllerTransitioningDelegate {
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        print("UIViewControllerTransitioningDelegate presentationController")
        return DimmingPresentationController(presentedViewController: presented, presenting: presenting)
    }

    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        if let indexPath = self.selectedIndexPath,
           let cell = self.collectionView.cellForItem(at: indexPath) as? PhotoCell {
            return PresentingAnimator(parentView: self.view, collectionView: self.collectionView, indexPath: indexPath, image: cell.image)
        }
        
        return nil
    }

    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        if let detailCollectionViewController = dismissed as? DetailCollectionViewController {
            if let indexPath = detailCollectionViewController.currentIndex,
               let image = detailCollectionViewController.currentImage {
                
                // 현재 화면 센터값, 이미지 사이즈를 화면사이즈에 맞게 변경
                let fromFrame = CGRect(origin: detailCollectionViewController.currentCenter, size: AVMakeRect(aspectRatio: image.size, insideRect: UIScreen.main.bounds).size)
                
                return DismissingAnimator(parentView: self.view, collectionView: self.collectionView, indexPath: indexPath, fromFrame: fromFrame, image: image)
            }
        }
        return nil
    }
}

extension PhotoViewController: DetailCollectionViewControllerDelegate {
    func dragMove(indexPath: IndexPath) {
        if let cell = self.collectionView.cellForItem(at: indexPath) {
            if !cell.isHidden {
                cell.isHidden = true
            }
        }
    }
    
    func dragEnd(indexPath: IndexPath) {
        if let cell = self.collectionView.cellForItem(at: indexPath) {
            if cell.isHidden {
                cell.isHidden = false
            }
        }
    }
    
    func changeIndex(before: IndexPath, after: IndexPath) {
        Log(" indexPath : \(after)")
        guard let cell = self.collectionView.cellForItem(at: after)
        else {
            Log("not visible cell index : \(after)")
            let temp = before.row - after.row
            if temp > 0 {
                // up
                self.collectionView.scrollToItem(at: after, at: .top, animated: false)
            } else {
                // down
                self.collectionView.scrollToItem(at: after, at: .bottom, animated: false)
            }
            return
        }
        
        let cellFrame = self.collectionView.convert(cell.frame, to: self.view)
        if cellFrame.minY < self.collectionView.contentInset.top {
            self.collectionView.scrollToItem(at: after, at: .top, animated: false)
        } else if cellFrame.maxY > self.safeRect.height - self.collectionView.contentInset.bottom {
            self.collectionView.scrollToItem(at: after, at: .bottom, animated: false)
        }
    }
}
