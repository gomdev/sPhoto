//
//  AlbumViewModel.swift
//  sPhoto
//
//  Created by 곰 on 2020/11/04.
//

import UIKit

class AlbumViewModel {
    
    private var albums: [AlbumModel] = []
    
    public var updateThumnail = Dynamic(0)
    public var insert = Dynamic(0)
    public var refresh = Dynamic(false)
    
    //MARK: -
    func configure() throws {
        Log("documentsUrl : \(Constants.documentsUrl)")
        
        self.albums.removeAll()
        let directoryContents = Constants.documentsUrl.contentsOfDirectory
        let root = Constants.documentsUrl.contentsOfDirectoryFile
        Log("directoryContents : \(directoryContents)")
        
        var album: AlbumModel? = nil
        for item in directoryContents {
            print("item url : \(item), item.isDirectory : \(item.isDirectory)")
            if item.isDirectory {
                let contents = item.contentsOfDirectoryFile
                if let first = contents.first {
                    let model = AlbumModel(url: item, main: PhotoModel(origin: first), count: contents.count)
                    self.albums.append(model)
                } else {
                    let model = AlbumModel(url: item, main: nil, count: 0)
                    self.albums.append(model)
                }
            } else {
                if album == nil {
                    album = AlbumModel(url: Constants.documentsUrl, main: PhotoModel(origin: item), name: "root", count: root.count)
                }
            }
        }
        
        if album != nil {
            self.albums.insert(album!, at: 0)
        }
        print("self.albums : \(self.albums)")
    }
    
    
    //MARK: - get
    public var count: Int {
        get {
            return self.albums.count
        }
    }
    
    public func albumMain(index: Int) -> UIImage? {
        if let photo = self.albums[index].mainPhoto {
            return photo.thumbnail(index: index, completion: { (index, url, image) in
                self.updateThumnail.value = index
            })
        } else {
            return nil
        }
    }
    
    public func albumDisplayName(index: Int) -> String {
        return self.albums[index].displayName
    }
    
    public func albumDisplayContents(index: Int) -> String {
        return "\(self.albums[index].displayName)\n\(self.albums[index].count)"
    }
    
    public func url(index: Int) -> URL {
        return self.albums[index].url
    }
    
    public func addAlbum(name: String) {
        let url = Constants.documentsUrl.appendingPathComponent(name)
        if !FileManager.default.fileExists(atPath: url.path) {
            try? FileManager.default.createDirectory(at: url, withIntermediateDirectories: true, attributes: nil)
            
            self.albums.insert(AlbumModel(url: url, count: 0), at: 1)
            self.insert.value = 1
        }
    }
}
