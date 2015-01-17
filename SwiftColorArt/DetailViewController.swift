//
//  DetailViewController.swift
//  SwiftColorArt
//
//  Created by Jan Gregor Triebel on 06.01.15.
//  Copyright (c) 2015 Jan Gregor Triebel. All rights reserved.
//

import UIKit
import SwiftColorArtFramework

class DetailViewController: UIViewController {

  @IBOutlet weak var imageView: UIImageView!

  @IBOutlet weak var primaryColorLabel: UILabel!
  @IBOutlet weak var secondaryColorLabel: UILabel!
  @IBOutlet weak var detailColorLabel: UILabel!
  
  @IBOutlet weak var detailColorButton: UIButton!
  
  var detailItem: ExampleData?

  func configureView() {
    // Update the user interface for the detail item.
    if let detail: ExampleData = self.detailItem {
      if let imageView = self.imageView {
        
        var image:UIImage = UIImage(named: detail.imageName)!
        
        imageView.image = image
                
        var swiftColorArt:SWColorArt = SWColorArt(inputImage: image)
        
        self.view.backgroundColor = swiftColorArt.backgroundColor!
        
        self.primaryColorLabel.textColor   = swiftColorArt.primaryColor!
        self.secondaryColorLabel.textColor = swiftColorArt.secondaryColor!
        
        self.detailColorButton.setTitleColor(swiftColorArt.detailColor!, forState: UIControlState.Normal)
        
        self.primaryColorLabel.text = detail.title
      }
    }
  }

  @IBAction func clickButton(sender: AnyObject) {
    if let detail: ExampleData = self.detailItem {
      let targetURL = NSURL(string: detail.url)
      let application = UIApplication.sharedApplication()
      
      application.openURL(targetURL!);
    }
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view, typically from a nib.
    self.configureView()
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }


}

