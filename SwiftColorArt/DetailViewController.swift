//
//  DetailViewController.swift
//  SwiftColorArt
//
//  Created by Jan Gregor Triebel on 06.01.15.
//  Copyright (c) 2015 Jan Gregor Triebel. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {

    @IBOutlet weak var imageView: UIImageView!

    @IBOutlet weak var backgroundColorLabel: UILabel!
    @IBOutlet weak var primaryColorLabel: UILabel!
    @IBOutlet weak var secondaryColorLabel: UILabel!
    @IBOutlet weak var detailColorLabel: UILabel!
    
    var detailItem:String?

    func configureView() {
        // Update the user interface for the detail item.
        if let detail: String = self.detailItem {
            if let imageView = self.imageView {
                
                var image:UIImage = UIImage(named: detail)!
                
                imageView.image = image
                
                var swiftColorArt:SwiftColorArt = SwiftColorArt(inputImage: image)
                
                println("Read primary color \(swiftColorArt.primaryColor?.description)")
                
                self.backgroundColorLabel.textColor = swiftColorArt.backgroundColor!
                self.backgroundColorLabel.text      = "Found Background Color"
                
                self.primaryColorLabel.textColor    = swiftColorArt.primaryColor!
                self.primaryColorLabel.text         = "Found Primary Color"

                self.secondaryColorLabel.textColor  = swiftColorArt.secondaryColor!
                self.secondaryColorLabel.text       = "Found Secondary Color"
                
                self.detailColorLabel.textColor     = swiftColorArt.detailColor!
                self.detailColorLabel.text          = "Found Detail Color"
            }
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

