//
//  SwiftColorArtTests.swift
//  SwiftColorArtTests
//
//  Created by Jan Gregor Triebel on 06.01.15.
//  Copyright (c) 2015 Jan Gregor Triebel. All rights reserved.
//

import UIKit
import XCTest
import SwiftColorArtFramework

class SwiftColorArtFrameworkBorderTest: XCTestCase {
  
  func calculationMethod(border: Border){
    var pointsInBorder = 0
    
    for x in 0...Int(border.rect.maxX) {
      for y in 0...Int(border.rect.maxY) {
        
        let point = CGPoint(x: x, y: y)
        
        if border.isPointInBorder(point) {
          pointsInBorder++
        }
      }
    }
  }
  
  func testInBorderViaCalculationSmall() {
    
    var rect   = CGRect(x: 0, y: 0, width: 32, height: 32)
    var border = Border(rect: rect, width: 2, top: true, right: true, bottom: true, left: true)
    
    self.measureBlock() {
      self.calculationMethod(border)
    }
  }
  
  func testInBorderViaCalculationMedium() {
    
    var rect   = CGRect(x: 0, y: 0, width: 128, height: 128)
    var border = Border(rect: rect, width: 8, top: true, right: true, bottom: true, left: true)
    
    self.measureBlock() {
      self.calculationMethod(border)
    }
  }
  
  func testInBorderViaCalculationLarge() {
    
    var rect   = CGRect(x: 0, y: 0, width: 512, height: 512)
    var border = Border(rect: rect, width: 32, top: true, right: true, bottom: true, left: true)
    
    self.measureBlock() {
      self.calculationMethod(border)
    }
  }
  
  func testInBorderViaCalculationExtraLarge() {
    
    var rect   = CGRect(x: 0, y: 0, width: 2048, height: 2048)
    var border = Border(rect: rect, width: 128, top: true, right: true, bottom: true, left: true)
    
    self.measureBlock() {
      self.calculationMethod(border)
    }
  }
}
