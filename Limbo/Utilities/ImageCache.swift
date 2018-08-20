//
//  ImageCache.swift
//  Limbo
//
//  Created by A-Team User on 15.08.18.
//  Copyright © 2018 A-Team User. All rights reserved.
//

import UIKit

class ImageCache {
    static let shared = ImageCache()
    private var cache: NSCache<NSString, UIImage>!
    
    fileprivate init() {
        self.cache = NSCache.init()
    }
    
    func cacheImage(image: UIImage, forKey key: NSString) {
        self.cache.setObject(image, forKey: key)
    }
    
    func getImage(forKey key: NSString) -> UIImage? {
        return self.cache.object(forKey: key)
    }
}
