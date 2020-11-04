//
//  Common+Extensions.swift
//  sPhoto
//
//  Created by 곰 on 2020/11/04.
//

import UIKit
import AVFoundation

public func Log<T>(_ object: T?, filename: String = #file, line: Int = #line, funcname: String = #function) {
    #if DEBUG
        guard let object = object else { return }
        print("=== \(Date()) \(filename.components(separatedBy: "/").last ?? "") (line: \(line)) :: \(funcname) :: \(object)")
    #endif
}

extension URL {
    var isHidden: Bool {
        get {
            return (try? resourceValues(forKeys: [.isHiddenKey]))?.isHidden == true
        }
        set {
            var resourceValues = URLResourceValues()
            resourceValues.isHidden = newValue
            do {
                try setResourceValues(resourceValues)
            } catch {
                print("URL isHidden error:", error)
            }
        }
    }
    
    var isDirectory: Bool {
        get {
            return (try? resourceValues(forKeys: [.isDirectoryKey]))?.isDirectory == true
        }
    }
    
    var contentsOfDirectoryFile: [URL] {
        get {
            do {
                let directoryContents = try FileManager.default.contentsOfDirectory(at: self,
                                                                                 includingPropertiesForKeys:[.contentModificationDateKey],
                options: [.skipsSubdirectoryDescendants]).filter { $0.pathExtension.lowercased() == "jpg" || $0.pathExtension.lowercased() == "jpeg" || $0.pathExtension.lowercased() == "png" || $0.pathExtension.lowercased() == "gif" }.sorted(by: {
                   let date0 = try $0.promisedItemResourceValues(forKeys:[.contentModificationDateKey]).contentModificationDate!
                   let date1 = try $1.promisedItemResourceValues(forKeys:[.contentModificationDateKey]).contentModificationDate!
                   return date0.compare(date1) == .orderedDescending
                })
                return directoryContents
            } catch {
                print("URL contentsOfDirectoryFile error:", error)
            }
            return []
        }
    }
    
    var contentsOfDirectory: [URL] {
        get {
            if let urlArray = try? FileManager.default.contentsOfDirectory(at: self, includingPropertiesForKeys: [.contentModificationDateKey], options: [.skipsHiddenFiles]) {
                return urlArray.map { url in
                    (url, (try? url.resourceValues(forKeys: [.contentModificationDateKey]))?.contentModificationDate ?? Date.distantPast)
                }
                .sorted(by: { $0.1 > $1.1 }) // sort descending modification dates
                .map { $0.0 } // extract file names
            } else {
                return []
            }
        }
    }
}

extension Date {
    public static var nowDate: Date {
        get {
            let dateFormatter = DateFormatter()
            dateFormatter.timeZone = TimeZone.autoupdatingCurrent
            dateFormatter.locale = Locale.current
            dateFormatter.dateFormat = "yyyy.MM.dd"
            if let now = dateFormatter.date(from: dateFormatter.string(from: Date())) {
                return now
            }
            return Date()
        }
    }
    
    public static var timeIntervalSince1970NowDate: Double {
        get {
            let dateFormatter = DateFormatter()
            dateFormatter.timeZone = TimeZone.autoupdatingCurrent
            dateFormatter.locale = Locale.current
            dateFormatter.dateFormat = "yyyy.MM.dd HH:mm:ss"
            if let now = dateFormatter.date(from: dateFormatter.string(from: Date())) {
                return now.timeIntervalSince1970.rounded()
            }
            return 0
        }
    }
}

extension UIView {
    public static var identifier: String {
        return String(describing: self)
    }
}

extension UIViewController {
    public static var identifier: String {
        return String(describing: self)
    }
    
    public var safeRect: CGRect {
        if let navigationBar = self.navigationController?.navigationBar, let toolbar = self.navigationController?.toolbar {
            
            let navigationHeight = navigationBar.frame.origin.y + navigationBar.frame.height
            let toobarHeight = UIScreen.main.bounds.height - toolbar.frame.origin.y
            let safeHeight = UIScreen.main.bounds.height - navigationHeight - toobarHeight
            let result = CGRect(x: 0, y: navigationHeight, width: UIScreen.main.bounds.width, height: safeHeight)
            return result
        }
        
        return .zero
    }
}

extension UIAlertController {
    @objc func textDidChange() {
        guard let textField = self.textFields?.first,
              let saveAction = self.actions.first(where: { $0.title == "Save" })
        else {
            return
        }
        
        let text = textField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        saveAction.isEnabled = !text.isEmpty
    }
}

extension UIImage {
    public convenience init?(color: UIColor, size: CGSize = CGSize(width: 1, height: 1)) {
      let rect = CGRect(origin: .zero, size: size)
      UIGraphicsBeginImageContextWithOptions(rect.size, false, 0.0)
      color.setFill()
      UIRectFill(rect)
      let image = UIGraphicsGetImageFromCurrentImageContext()
      UIGraphicsEndImageContext()
      
      guard let cgImage = image?.cgImage else { return nil }
      self.init(cgImage: cgImage)
    }
    
    public static func imageByCombiningImage(firstImage: UIImage, withImage secondImage: UIImage) -> UIImage? {
        let rect = AVMakeRect(aspectRatio: firstImage.size, insideRect: CGRect(origin: .zero, size: secondImage.size))
        UIGraphicsBeginImageContext(secondImage.size)
        firstImage.draw(in: rect)
        secondImage.draw(in: CGRect(origin: .zero, size: secondImage.size))
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
    
    public static func downsample(imageAt imageURL: URL, to pointSize: CGSize, scale: CGFloat) -> UIImage? {
        let imageSourceOptions = [kCGImageSourceShouldCache: false] as CFDictionary
        let imageSource = CGImageSourceCreateWithURL(imageURL as CFURL, imageSourceOptions)!
        
        let maxDimentionInPixels = max(pointSize.width, pointSize.height) * scale
        
        let downsampledOptions = [kCGImageSourceCreateThumbnailFromImageAlways: true,
                                  kCGImageSourceShouldCacheImmediately: true,
                                  kCGImageSourceCreateThumbnailWithTransform: true,
                                  kCGImageSourceThumbnailMaxPixelSize: maxDimentionInPixels] as CFDictionary
        
        let downsampledImage = CGImageSourceCreateThumbnailAtIndex(imageSource, 0, downsampledOptions)
        if downsampledImage != nil {
            return UIImage(cgImage: downsampledImage!)
        }
        
        return nil
    }
}

extension UIImageView {
    var contentClippingRect: CGRect {
            guard let image = image else { return bounds }
            guard contentMode == .scaleAspectFit else { return bounds }
            guard image.size.width > 0 && image.size.height > 0 else { return bounds }

            let scale: CGFloat
            if image.size.width > image.size.height {
                scale = bounds.width / image.size.width
            } else {
                scale = bounds.height / image.size.height
            }

            let size = CGSize(width: image.size.width * scale, height: image.size.height * scale)
            let x = (bounds.width - size.width) / 2.0
            let y = (bounds.height - size.height) / 2.0

            return CGRect(x: x, y: y, width: size.width, height: size.height)
        }
}

extension UICollectionView {
    //This function prevents the collectionView from accessing a deallocated cell. In the
    //event that the cell for the indexPath is nil, a default CGRect is returned in its place
    func getFrameFromCollectionViewCell(for indexPath: IndexPath) -> CGRect {
        //Get the currently visible cells from the collectionView
        let visibleCells = self.indexPathsForVisibleItems
        
        //If the current indexPath is not visible in the collectionView,
        //scroll the collectionView to the cell to prevent it from returning a nil value
        if !visibleCells.contains(indexPath) {
            
            //Scroll the collectionView to the cell that is currently offscreen
            self.scrollToItem(at: indexPath, at: .centeredVertically, animated: false)
            
            //Reload the items at the newly visible indexPaths
            self.reloadItems(at: self.indexPathsForVisibleItems)
            self.layoutIfNeeded()
            
            //Prevent the collectionView from returning a nil value
            guard let guardedCell = self.cellForItem(at: indexPath) else {
                return CGRect(x: UIScreen.main.bounds.midX, y: UIScreen.main.bounds.midY, width: 100.0, height: 100.0)
            }
            
            return guardedCell.frame
        }
        //Otherwise the cell should be visible
        else {
            //Prevent the collectionView from returning a nil value
            guard let guardedCell = self.cellForItem(at: indexPath) else {
                return CGRect(x: UIScreen.main.bounds.midX, y: UIScreen.main.bounds.midY, width: 100.0, height: 100.0)
            }
            //The cell was found successfully
            return guardedCell.frame
        }
    }
}
