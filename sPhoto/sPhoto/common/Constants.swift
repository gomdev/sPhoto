//
//  Constants.swift
//  sPhoto
//
//  Created by 곰 on 2020/11/04.
//

import Foundation

struct Constants {
    static let appGroupId = ""
    
    static let documentsUrl: URL = {
        return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    }()
    
    static let sharedUrl: URL? = {
        return FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: appGroupId)
    }()
    
    static let thumbnailUrl: URL = {
        return documentsUrl.appendingPathComponent(".thumbnail")
    }()
    
    static let lockUrl: URL = {
        return documentsUrl.appendingPathComponent(".locked")
    }()
}
