//
//  Border.swift
//  SwiftColorArt
//
//  Created by Jan Gregor Triebel on 11.01.15.
//  Copyright (c) 2015 Jan Gregor Triebel. All rights reserved.
//

import Foundation
import UIKit
import CoreGraphics

/// Border
///
/// A struct to keep trac of dimensions and border width to check a point's location
///
public struct Border {
  
  public let rect: CGRect
  
  public let width: CGFloat
  
  let top: Bool
  let right: Bool
  let bottom: Bool
  let left: Bool
  
  public init (rect: CGRect, width: CGFloat, top: Bool, right: Bool, bottom: Bool, left: Bool ){
    self.rect = rect
    self.width = width
    self.top = top
    self.right = right
    self.bottom = bottom
    self.left = left
  }
  
  public func isPointInBorder(_ point: CGPoint) -> Bool {
    if top && point.y <= width {
      return true
    } else if right && point.x >= rect.maxX - width {
      return true
    } else if bottom && point.y >= rect.maxY - width {
      return true
    } else if left && point.x <= width {
      return true
    }
    
    return false
  }
  
  public func createBorderSet() -> [CGPoint] {
    
    var borderSet: [CGPoint] = Array()
    
    if top {
      for x in 0...Int(rect.maxX) {
        for y in 0...Int(width) {
          let point = CGPoint(x: x, y: y)
          borderSet.append(point)
        }
      }
    }
    
    if bottom {
      for x in 0...Int(rect.maxX) {
        for y in Int(rect.maxY - width)...Int(rect.maxY) {
          let point = CGPoint(x: x, y: y)
          borderSet.append(point)
        }
      }
    }
    
    if right {
      for x in Int(rect.maxX - width)...Int(rect.maxX) {
        for y in 0...Int(rect.maxY) {
          let point = CGPoint(x: x, y: y)
          borderSet.append(point)
        }
      }
    }
    
    if left {
      for x in 0...Int(width) {
        for y in 0...Int(rect.maxY) {
          let point = CGPoint(x: x, y: y)
          borderSet.append(point)
        }
      }
    }
    
    return borderSet
  }
}
