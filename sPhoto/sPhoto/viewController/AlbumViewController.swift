//
//  AlbumViewController.swift
//  sPhoto
//
//  Created by 곰 on 2020/11/04.
//

import UIKit

class AlbumViewController: UIViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    private var selectIndexPath: IndexPath?
    var viewModel: AlbumViewModel = AlbumViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        if #available(iOS 12.0, *) {
            if self.traitCollection.userInterfaceStyle == .dark {
                self.navigationController?.navigationBar.tintColor = .white
            } else {
                self.navigationController?.navigationBar.tintColor = .black
            }
        }
        
        self.configure()
        
        do {
            try self.viewModel.configure()
            self.collectionView.reloadData()
        } catch {
            print("error : \(error)")
        }
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        Log(" transition !")
        
        self.collectionView.collectionViewLayout.invalidateLayout()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == PhotoViewController.identifier,
           let photo = segue.destination as? PhotoViewController,
           let indexPath = self.selectIndexPath {
            photo.viewModel = PhotoViewModel(displayName: self.viewModel.albumDisplayName(index: indexPath.row), url: self.viewModel.url(index: indexPath.row))
        }
    }
    
    
    //MARK: -
    func configure() {
        // collectionView
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        
        
        let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(self.addButtonAction(_:)))
        self.navigationItem.rightBarButtonItem = addButton
        
        self.viewModel.updateThumnail.bind({ (index) in
            Log(" bind index : \(index) update !")
            self.updateThumbnail(index: index)
        })
        
        self.viewModel.refresh.bind({ (value) in
            Log(" bind : \(value) refresh !")
            do {
                try self.viewModel.configure()
                self.collectionView.reloadData()
            } catch {
                print("error : \(error)")
            }
        })
        
        self.viewModel.insert.bind({ (index) in
            Log(" bind index : \(index) insert !")
            self.insertAlbum(index: index)
        })
    }
    
    func updateThumbnail(index: Int) {
        Log("index : \(index)")
        let indexPath = IndexPath(row: index, section: 0)
        self.collectionView.performBatchUpdates({
            self.collectionView.reloadItems(at: [indexPath])
        }, completion: nil)
    }
    
    func insertAlbum(index: Int) {
        Log("index : \(index)")
        self.collectionView.performBatchUpdates({
            self.collectionView.insertItems(at: [IndexPath(row: index, section: 0)])
        }, completion: { (complete) in
            self.collectionView.reloadData()
        })
    }
    
    
    //MARK: - action
    @objc func addButtonAction(_ sender: Any) {
        Log(" add !")
        let alertController = UIAlertController(title: "New Album", message: "Please enter a name for the new album", preferredStyle: .alert)
        let saveAction = UIAlertAction(title: "Save", style: .default, handler: { (action) in
            if let textField = alertController.textFields?.first {
                let text = textField.text ?? ""
                Log("input text : \(text)")
                if !text.isEmpty {
                    self.viewModel.addAlbum(name: text)
                }
            }
        })
        saveAction.isEnabled = false
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .default, handler: nil)
        
        alertController.addTextField(configurationHandler: { (textField) in
            textField.addTarget(alertController, action: #selector(alertController.textDidChange), for: .editingChanged)
        })
        alertController.addAction(cancelAction)
        alertController.addAction(saveAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    //MARK: -
    func showPhotos(indexPath: IndexPath) {
        self.selectIndexPath = indexPath
        self.performSegue(withIdentifier: PhotoViewController.identifier, sender: self)
    }
}

extension AlbumViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        
        Log(" indexPath : \(indexPath)")
        self.showPhotos(indexPath: indexPath)
    }
}

extension AlbumViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.viewModel.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: AlbumCell.identifier, for: indexPath)
        if let album = cell as? AlbumCell {
            album.imageView.image = self.viewModel.albumMain(index: indexPath.row)
            album.contentsLabel.text = self.viewModel.albumDisplayContents(index: indexPath.row)
        }
        
        return cell
    }
}

extension AlbumViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if UIApplication.shared.statusBarOrientation.isPortrait {
            let width = (collectionView.frame.width / 2) - 1
            let size = CGSize(width: width, height: width + 40)
            return size
        }
        
        let width = (collectionView.frame.width / 4) - 1
        let size = CGSize(width: width, height: width + 40)
        return size
    }
}
