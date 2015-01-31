//
//  Colors.swift
//  SwiftColorArt
//
//  Created by Jan Gregor Triebel on 29.01.15.
//  Copyright (c) 2015 Jan Gregor Triebel. All rights reserved.
//

import Foundation
import UIKit

class Colors: NSObject, NSCoding {
  var backgroundColor: UIColor
  var primaryColor: UIColor
  var secondaryColor: UIColor
  var detailColor: UIColor
  
  init(backgroundColor: UIColor, primaryColor: UIColor, secondaryColor: UIColor, detailColor: UIColor) {
    self.backgroundColor = backgroundColor
    self.primaryColor    = primaryColor
    self.secondaryColor  = secondaryColor
    self.detailColor     = detailColor
  }
  
  // MARK: NSCoding
  
  required convenience init(coder decoder: NSCoder) {
    let backgroundColor = decoder.decodeObjectForKey("backgroundColor") as UIColor!
    let primaryColor    = decoder.decodeObjectForKey("primaryColor") as UIColor!
    let secondaryColor  = decoder.decodeObjectForKey("secondaryColor") as UIColor!
    let detailColor     = decoder.decodeObjectForKey("detailColor") as UIColor!
    
    self.init(backgroundColor: backgroundColor, primaryColor: primaryColor, secondaryColor: secondaryColor, detailColor: detailColor);
  }
  
  func encodeWithCoder(coder: NSCoder) {
    coder.encodeObject(self.backgroundColor, forKey: "backgroundColor")
    coder.encodeObject(self.primaryColor,    forKey: "primaryColor")
    coder.encodeObject(self.secondaryColor,  forKey: "secondaryColor")
    coder.encodeObject(self.detailColor,     forKey: "detailColor")
  }
}