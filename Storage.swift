//
//  Storage.swift
//  SwiftColorArt
//
//  Created by Jan Gregor Triebel on 29.01.15.
//  Copyright (c) 2015 Jan Gregor Triebel. All rights reserved.
//

import Foundation
import UIKit
import CryptoSwift

class Storage {
  
  func cacheDirPath() -> NSURL {
    
    var cachesURL       = NSFileManager.defaultManager().URLsForDirectory(.CachesDirectory, inDomains: .UserDomainMask)[0] as? NSURL
    var cacheDirectory  = cachesURL!.URLByAppendingPathComponent("swiftcolorart")
    var fileManager     = NSFileManager()
    var isDir: ObjCBool = false
    
    if fileManager.fileExistsAtPath(cacheDirectory.path!, isDirectory:&isDir) {
      if isDir {
        println("Cache directory at: \(cacheDirectory.path!) already exists")
      } else {
        // file exists and is not a directory
      }
    } else {
      // file or folder does not exist
      var err:NSError?
      fileManager.createDirectoryAtURL(cacheDirectory, withIntermediateDirectories: true, attributes:nil, error: &err)
      if err != nil {
        println("Error (\(err?.description)) creating cache directory at: \(cacheDirectory.path!)")
      }
    }
    
    return cacheDirectory
  }
  
  func doesCacheExistForImage(image: UIImage) -> Bool {
    var fileManager     = NSFileManager()
    var isDir: ObjCBool = false
    var finalPath       = cacheDirPath().URLByAppendingPathComponent(getUniqueImageIdentifier(image))
    
    if fileManager.fileExistsAtPath(finalPath.path!, isDirectory:&isDir) {
      if isDir {
        println("Color file at '\(finalPath.path!)' does not exist yet")
        return false
      } else {
        println("Color file at '\(finalPath.path!)' does exist")
        return true
      }
    } else {
      println("Color file at '\(finalPath.path!)' does not exist yet")
      return false
    }
  }
  
  func getUniqueImageIdentifier(image: UIImage) -> String {

    var imageData: NSData = NSData(data: UIImageJPEGRepresentation(image, 0.5))
    
    let data = CryptoSwift.Hash.md5(imageData).calculate()?.md5()?.hexString
    
    return data!
  }
  
  func storeColorsForImage(colors: Colors, image: UIImage) {
    var finalPath = self.cacheDirPath().URLByAppendingPathComponent(getUniqueImageIdentifier(image))
    NSKeyedArchiver.archiveRootObject(colors, toFile: finalPath.path!)
  }
  
  func loadColorsForImage(image: UIImage) -> Colors {
    var finalPath = self.cacheDirPath().URLByAppendingPathComponent(getUniqueImageIdentifier(image))
    return NSKeyedUnarchiver.unarchiveObjectWithFile(finalPath.path!) as Colors
  }
}