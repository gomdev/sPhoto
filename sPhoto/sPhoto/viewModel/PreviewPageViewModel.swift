//
//  PreviewPageViewModel.swift
//  sPhoto
//
//  Created by 곰 on 2020/11/04.
//

import UIKit

class PreviewPageViewModel {
    private var photos: [PhotoModel]!
    private var index: Int
    
    init(index: Int, photos: [PhotoModel]) {
        self.index = index
        self.photos = photos
    }
    
    deinit {
        print("PreviewPageViewModel deinit")
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
    
    public func originUrl(index: Int) -> URL {
        return self.photos[index].originUrl
    }
    
    public func thumbnailUrl(index: Int) -> URL {
        return self.photos[index].thumbnailUrl
    }
    
    public func thumbnail(index: Int) -> UIImage? {
        return self.photos[index].thumbnail
    }
}
