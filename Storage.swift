//
//  Storage.swift
//  SwiftColorArt
//
//  Created by Jan Gregor Triebel on 29.01.15.
//  Copyright (c) 2015 Jan Gregor Triebel. All rights reserved.
//

import Foundation
import UIKit

class Storage {
  
  func cacheDirPath() -> NSURL {
    
    let cachesURL       = FileManager.default().urlsForDirectory(.cachesDirectory, inDomains: .userDomainMask)[0] as NSURL
    let cacheDirectory  = cachesURL.appendingPathComponent("swiftcolorart")
    let fileManager     = FileManager()
    var isDir: ObjCBool = false
    
    if fileManager.fileExists(atPath: (cacheDirectory?.path!)!, isDirectory:&isDir) {
      if isDir {
        print("Cache directory at: \(cacheDirectory?.path!) already exists")
      } else {
        // file exists and is not a directory
      }
    } else {
      // file or folder does not exist
        do {
            try fileManager.createDirectory(atPath: (cacheDirectory?.absoluteString)!, withIntermediateDirectories: true, attributes: [:])
        } catch  {
            print("Error creating cache directory at: \(cacheDirectory?.path!)")
        }
    }
    
    return cacheDirectory!
  }
  
  func doesCacheExistForImage(_ image: UIImage) -> Bool {
    let fileManager     = FileManager()
    var isDir: ObjCBool = false
    let finalPath       = cacheDirPath().appendingPathComponent(getUniqueImageIdentifier(image))
    
    if fileManager.fileExists(atPath: (finalPath?.path!)!, isDirectory:&isDir) {
      if isDir {
        print("Color file at '\(finalPath?.path!)' does not exist yet")
        return false
      } else {
        print("Color file at '\(finalPath?.path!)' does exist")
        return true
      }
    } else {
      print("Color file at '\(finalPath?.path!)' does not exist yet")
      return false
    }
  }
  
  func getUniqueImageIdentifier(_ image: UIImage) -> String {

    /*var imageData: NSData = NSData(data: UIImageJPEGRepresentation(image, 0.5))
    
    let data = CryptoSwift.Hash.md5(imageData).calculate()?.md5()?.hexString
    
    return data!*/
    
    return String(arc4random())
  }
  
  func storeColorsForImage(_ colors: Colors, image: UIImage) {
    let finalPath = self.cacheDirPath().appendingPathComponent(getUniqueImageIdentifier(image))
    NSKeyedArchiver.archiveRootObject(colors, toFile: (finalPath?.path!)!)
  }
  
  func loadColorsForImage(_ image: UIImage) -> Colors {
    let finalPath = self.cacheDirPath().appendingPathComponent(getUniqueImageIdentifier(image))
    return NSKeyedUnarchiver.unarchiveObject(withFile: finalPath!.path!) as! Colors
  }
}
