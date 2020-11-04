//
//  PhotoModel.swift
//  sPhoto
//
//  Created by 곰 on 2020/11/04.
//

import UIKit
import MobileCoreServices
import SDWebImage

class PhotoModel: Copying {
    public enum extensionType {
        case none
        case jpg
        case png
        case gif
    }
    
    var originUrl: URL
    var thumbnailUrl: URL
    var isThumbnail: Bool = false
    var type: extensionType = .none
    var typeString: String = ""
    
    init(origin: URL) {
        self.originUrl = origin
        let pathExtension = self.originUrl.pathExtension
        switch pathExtension.lowercased() {
        case "jpeg", "jpg":
            self.type = .jpg
            self.typeString = kUTTypeJPEG as String
            break
        case "png":
            self.type = .png
            self.typeString = kUTTypePNG as String
            break
        case "gif":
            self.type = .gif
            self.typeString = kUTTypeGIF as String
            break
        default:
            break
        }
        print("PhotoModel url : \(self.originUrl), type : \(self.type)")
        let folder = origin.deletingLastPathComponent()
        let thumbnailUrl = folder.appendingPathComponent(".thumbnail")
        if !FileManager.default.fileExists(atPath: thumbnailUrl.path) {
            try? FileManager.default.createDirectory(at: thumbnailUrl, withIntermediateDirectories: true, attributes: nil)
        }
        
        self.thumbnailUrl = thumbnailUrl.appendingPathComponent(origin.lastPathComponent)
    }
    
    required init(original: PhotoModel) {
        self.originUrl = original.originUrl
        self.thumbnailUrl = original.thumbnailUrl
        self.isThumbnail = original.isThumbnail
        self.type = original.type
        self.typeString = original.typeString
    }
    
    public var origin: UIImage? {
        get {
            return UIImage(contentsOfFile: self.originUrl.path)
        }
    }
    
    public var thumbnail: UIImage? {
        get {
            if let image = UIImage(contentsOfFile: self.thumbnailUrl.path) {
                self.isThumbnail = true
                return image
            } else {
                return nil
            }
        }
    }
    
    public func thumbnail(index: Int, completion: ((Int, URL, UIImage?) -> Void)? = nil) -> UIImage? {
        if let image = self.thumbnail {
            return image
        } else {
            if self.isThumbnail {
                return nil
            }
            
            self.isThumbnail = true
            DispatchQueue.global(qos: .background).async {
                let thumnail = UIImage.downsample(imageAt: self.originUrl, to: CGSize(width: 256, height: 256), scale: 1)
                if thumnail == nil {
                    if let completion = completion {
                        DispatchQueue.main.async {
                            completion(index, self.originUrl, nil)
                        }
                    }
                    return
                }
                
                let data = thumnail?.jpegData(compressionQuality: 1)
                do {
                    try data?.write(to: self.thumbnailUrl)
                } catch {
                    print("error : \(error)")
                }
                DispatchQueue.main.async {
                    if let completion = completion {
                        completion(index, self.originUrl, thumnail)
                    }
                }
            }
            return nil
        }
    }
}

//Protocal that copyable class should conform
protocol Copying {
    init(original: Self)
}

//Concrete class extension
extension Copying {
    func copy() -> Self {
        return Self.init(original: self)
    }
}

//Array extension for elements conforms the Copying protocol
extension Array where Element: Copying {
    func clone() -> Array {
        var copiedArray = Array<Element>()
        for element in self {
            copiedArray.append(element.copy())
        }
        return copiedArray
    }
}
