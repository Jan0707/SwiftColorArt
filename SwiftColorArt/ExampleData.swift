//
//  ExampleData.swift
//  SwiftColorArt
//
//  Created by Jan Gregor Triebel on 11.01.15.
//  Copyright (c) 2015 Jan Gregor Triebel. All rights reserved.
//

import Foundation

struct ExampleData {
  let title: String
  let imageName: String
  let url: String

  init(title: String, imageName: String, url: String) {
    self.title = title
    self.imageName = imageName
    self.url = url
  }
}