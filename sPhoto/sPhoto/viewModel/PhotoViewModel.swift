//
//  PhotoViewModel.swift
//  sPhoto
//
//  Created by 곰 on 2020/11/04.
//

import UIKit
import MobileCoreServices

class PhotoViewModel {
    private var url: URL
    private var displayName: String
    private var photos: [PhotoModel] = []
    
    public var updateThumnail = Dynamic(0)
    public var insert = Dynamic(0)
    public var refresh = Dynamic(false)
    
    init(displayName: String, url: URL) {
        self.displayName = displayName
        self.url = url
    }
    
    deinit {
        print("PhotoViewModel deinit")
    }
    
    func configure() {
        Log("directory url : \(self.url)")
        
        let contents = self.url.contentsOfDirectoryFile
        for item in contents {
            let model = PhotoModel(origin: item)
            self.photos.append(model)
        }
    }
    
    
    //MARK: - get
    public var name: String {
        get {
            return self.displayName
        }
    }
    
    public var count: Int {
        get {
            return self.photos.count
        }
    }
    
    public var photosAll: [PhotoModel] {
        get {
            return self.photos.clone()
        }
    }
    
    public var paste: Bool {
        get {
            if let images = UIPasteboard.general.images, images.count > 0 {
                return true
            }
            return false
        }
    }
    
    public func origin(index: Int) -> UIImage? {
        return self.photos[index].origin
    }
    
    public func thumnail(index: Int) -> UIImage? {
        return self.photos[index].thumbnail(index: index, completion: { [weak self] (index, url, image) in
            if let index = self?.photos.firstIndex(where: { $0.originUrl == url }) {
                self?.updateThumnail.value = index
            }
        })
    }
    
    
    //MARK: -
    public func insertImage(image: UIImage, type: PhotoModel.extensionType = .png) {
        var extensionType = ""
        switch type {
        case .gif:
            extensionType = "gif"
        default:
            extensionType = "png"
            break
        }
        let name = "\(String(format: "%.0f", Date.timeIntervalSince1970NowDate))\(self.count).\(extensionType)"
        let path = self.url.appendingPathComponent(name)
        
        do {
            let data = image.pngData()
            try data?.write(to: path)
            
            let model = PhotoModel(origin: path)
            self.photos.insert(model, at: 0)
            DispatchQueue.main.async {
                self.insert.value = 0
            }
        } catch {
            Log("error : \(error)")
        }
    }
    
    public func insertData(data: Data, type: PhotoModel.extensionType = .png) {
        var extensionType = ""
        switch type {
        case .gif:
            extensionType = "gif"
        default:
            extensionType = "png"
            break
        }
        let name = "\(String(format: "%.0f", Date.timeIntervalSince1970NowDate))\(self.count).\(extensionType)"
        let path = self.url.appendingPathComponent(name)
        
        do {
            try data.write(to: path)
            
            let model = PhotoModel(origin: path)
            self.photos.insert(model, at: 0)
            DispatchQueue.main.async {
                self.insert.value = 0
            }
        } catch {
            Log("error : \(error)")
        }
    }
    
    
    //MARK: - action
    public func refreshButtonAction() {
        self.configure()
        self.refresh.value = true
    }
    
    public func pasteButtonAction() {
        Log(" UIPasteboard.general.items.count : \(UIPasteboard.general.items.count)")
        DispatchQueue.global().async {
            if let datas = UIPasteboard.general.data(forPasteboardType: kUTTypeGIF as String, inItemSet: nil) {
                print("gif datas.count : \(datas.count)")
                for i in 0 ..< datas.count {
                    self.insertData(data: datas[i], type: .gif)
                }
            }
            
            if let datas = UIPasteboard.general.data(forPasteboardType: kUTTypeJPEG as String, inItemSet: nil) {
                print("jpg datas.count : \(datas.count)")
                for i in 0 ..< datas.count {
                    self.insertData(data: datas[i], type: .jpg)
                }
            }
            
            if let datas = UIPasteboard.general.data(forPasteboardType: kUTTypePNG as String, inItemSet: nil) {
                print("png datas.count : \(datas.count)")
                for i in 0 ..< datas.count {
                    self.insertData(data: datas[i], type: .png)
                }
            }
        }
    }
}
