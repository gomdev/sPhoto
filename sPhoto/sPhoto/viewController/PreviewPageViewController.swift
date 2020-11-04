//
//  PreviewPageViewController.swift
//  sPhoto
//
//  Created by 곰 on 2020/11/04.
//

import UIKit

class PreviewPageViewController: UIViewController {
    
    @IBOutlet weak var fullFrame: UIView!
    public var viewModel: PreviewPageViewModel?
    
    private var pageViewController: UIPageViewController!
    private var currentIndex: Int = 0
    private var currentViewController: PreviewContentsViewController? {
        return self.pageViewController.viewControllers?.first as? PreviewContentsViewController
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        self.configure()
    }
    
    
    //MARK: -
    func configure() {
        if self.viewModel == nil {
            return
        }
        
        self.pageViewController = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal, options: [.interPageSpacing: 24])
        self.pageViewController.delegate = self
        self.pageViewController.dataSource = self
        self.addChild(self.pageViewController)
        self.view.addSubview(self.pageViewController.view)
        self.pageViewController.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            self.pageViewController.view.widthAnchor.constraint(equalTo: self.view.widthAnchor),
            self.pageViewController.view.heightAnchor.constraint(equalTo: self.view.heightAnchor),
            self.pageViewController.view.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            self.pageViewController.view.centerYAnchor.constraint(equalTo: self.view.centerYAnchor)
        ])
        self.pageViewController.didMove(toParent: self)
        
        let pan = PanDirectionGestureRecognizer(direction: .vertical, target: self, action: #selector(self.wasDragged(_:)))
        pan.delegate = self
        self.pageViewController.view.addGestureRecognizer(pan)
        
        
        self.currentIndex = self.viewModel!.startIndex
        if let contents = self.getContents(index: self.currentIndex) {
            self.pageViewController.setViewControllers([contents], direction: .forward, animated: true, completion: nil)
        }
    }
    
    @objc func wasDragged(_ gesture: PanDirectionGestureRecognizer) {
        guard let image = gesture.view else { return }
        
        let translation = gesture.translation(in: self.view)
        if translation.y < 0 {
            // reset everything
            UIView.animate(withDuration: 0.15) {
//                self.view.backgroundColor = self.backgroundColor.withAlphaComponent(1.0)
                image.center = CGPoint(x: self.view.bounds.midX, y: self.view.bounds.midY)
            } completion: { (complete) in
//                self.delegate?.dragEnd(indexPath: self.currentIndex!)
            }
            return
        }
        
        image.center = CGPoint(x: self.view.bounds.midX, y: self.view.bounds.midY + translation.y)
//        self.currentCenter = image.center

        let yFromCenter = image.center.y - self.view.bounds.midY

        let alpha = 1 - abs(yFromCenter / self.view.bounds.midY)
//        self.view.backgroundColor = self.backgroundColor.withAlphaComponent(alpha)
        
        if gesture.state == .changed {
//            self.delegate?.dragMove(indexPath: self.currentIndex!)
        } else if gesture.state == .ended {
            var swipeDistance: CGFloat = 0
            let swipeBuffer: CGFloat = 50
            var animateImageAway = false

            if yFromCenter > -swipeBuffer && yFromCenter < swipeBuffer {
                // reset everything
                UIView.animate(withDuration: 0.15) {
//                    self.view.backgroundColor = self.backgroundColor.withAlphaComponent(1.0)
                    image.center = CGPoint(x: self.view.bounds.midX, y: self.view.bounds.midY)
                } completion: { (complete) in
//                    self.delegate?.dragEnd(indexPath: self.currentIndex!)
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
    
    
    //MARK: -
    func getContents(index: Int) -> UIViewController? {
        if let contents = self.storyboard?.instantiateViewController(withIdentifier: PreviewContentsViewController.identifier) as? PreviewContentsViewController {
            contents.index = index
            contents.url = self.viewModel!.originUrl(index: index)
            contents.thumbnail = self.viewModel!.thumbnail(index: index)
            return contents
        }
        return nil
    }
}

//MARK: - UIPageViewControllerDelegate
extension PreviewPageViewController: UIPageViewControllerDelegate {
    func pageViewController(_ pageViewController: UIPageViewController, willTransitionTo pendingViewControllers: [UIViewController]) {
        if let contents = pendingViewControllers.first as? PreviewContentsViewController {
            Log("contents.index : \(contents.index)")
        }
    }
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        Log(" .viewControllers.count : \(pageViewController.viewControllers?.count)")
        if let contents = pageViewController.viewControllers?.first as? PreviewContentsViewController {
            self.currentIndex = contents.index
        }
    }
}

//MARK: - UIPageViewControllerDataSource
extension PreviewPageViewController: UIPageViewControllerDataSource {
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let contents = viewController as? PreviewContentsViewController else {
            return nil
        }
        
        var index = contents.index
        if index <= 0 {
            return nil
        }
        
        index -= 1
        return self.getContents(index: index)
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let contents = viewController as? PreviewContentsViewController else {
            return nil
        }
        var index = contents.index
        if index >= self.viewModel!.count - 1 {
            return nil
        }
        
        index += 1
        return self.getContents(index: index)
    }
}

extension PreviewPageViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        
        if let viewController = self.currentViewController {
            if otherGestureRecognizer == viewController.scrollView.panGestureRecognizer {
                print("viewController.scrollView.contentOffset : \(viewController.scrollView.contentOffset)")
                if viewController.scrollView.contentOffset.y <= 0 {
                    return true
                }
            }
        }
        
        return false
    }
}
