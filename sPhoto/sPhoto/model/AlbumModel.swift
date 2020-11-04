//
//  AlbumModel.swift
//  sPhoto
//
//  Created by 곰 on 2020/11/04.
//

import Foundation

class AlbumModel {
    var url: URL
    var mainPhoto: PhotoModel? = nil
    var displayName: String
    var count: Int
    
    init(url: URL, main: PhotoModel? = nil, name: String? = nil, count: Int) {
        self.url = url
        self.mainPhoto = main
        if let name = name {
            self.displayName = name
        } else {
            self.displayName = FileManager.default.displayName(atPath: url.path)
        }
        self.count = count
    }
}
