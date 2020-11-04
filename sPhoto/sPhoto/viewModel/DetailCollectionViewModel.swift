//
//  DetailCollectionViewModel.swift
//  sPhoto
//
//  Created by 곰 on 2020/11/04.
//

import UIKit

class DetailCollectionViewModel {
    private var photos: [PhotoModel]!
    private var index: Int
    
    init(index: Int, photos: [PhotoModel]) {
        self.index = index
        self.photos = photos
    }
    
    deinit {
        print("DetailCollectionViewModel deinit")
    }
    
    
    //MARK: - get
    public var startIndex: Int {
        get {
            return self.index
        }
    }
    
    public var count: Int {
        get {
            return self.photos.count
        }
    }
    
    public func origin(index: Int) -> UIImage? {
        return self.photos[index].origin
    }
    
    public func originUrl(index: Int) -> URL {
        return self.photos[index].originUrl
    }
    
    public func originData(index: Int) -> Data? {
        if let data = try? Data(contentsOf: self.photos[index].originUrl) {
            return data
        }
        
        return nil
    }
    
    public func thumbnailUrl(index: Int) -> URL {
        return self.photos[index].thumbnailUrl
    }
    
    public func type(index: Int) -> PhotoModel.extensionType {
        return self.photos[index].type
    }
    
    public func typeString(index: Int) -> String {
        return self.photos[index].typeString
    }
}
