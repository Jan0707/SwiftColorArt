//
//  MasterViewController.swift
//  SwiftColorArt
//
//  Created by Jan Gregor Triebel on 06.01.15.
//  Copyright (c) 2015 Jan Gregor Triebel. All rights reserved.
//

import UIKit

class MasterViewController: UITableViewController {

  var examples:[ExampleData] = []


  override func awakeFromNib() {
    super.awakeFromNib()
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    
    let example1 = ExampleData(title: "Ponte Sisto", imageName: "pontesisto.jpg", url: "http://commons.wikimedia.org/wiki/File:Rome_(IT),_Ponte_Sisto_--_2013_--_4094.jpg")
    let example2 = ExampleData(title: "Reykjavik", imageName: "reykjavik.jpg", url: "http://commons.wikimedia.org/wiki/File:Vista_de_Reikiavik_desde_Perlan,_Distrito_de_la_Capital,_Islandia,_2014-08-13,_DD_137-139_HDR.JPG")
    let example3 = ExampleData(title: "Carousel", imageName: "carousel.jpg", url: "http://commons.wikimedia.org/wiki/File:Dülmen,_Viktorkirmes_auf_dem_Marktplatz_--_2014_--_3712.jpg")
    let example4 = ExampleData(title: "Centaurea", imageName: "centaurea.jpg", url: "http://commons.wikimedia.org/wiki/File:Centaurea_jacea_01.JPG")
    let example5 = ExampleData(title: "Mount Hood", imageName: "mounthood.jpg", url: "http://commons.wikimedia.org/wiki/File:Mount_Hood_reflected_in_Mirror_Lake,_Oregon.jpg")
    let example6 = ExampleData(title: "Green Peas", imageName: "greenpeas.jpg", url: "http://commons.wikimedia.org/wiki/File:India_-_Varanasi_green_peas_-_2714.jpg")
    
    self.examples.append(example1)
    self.examples.append(example2)
    self.examples.append(example3)
    self.examples.append(example4)
    self.examples.append(example5)
    self.examples.append(example6)
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }

  // MARK: - Segues

  override func prepare(for segue: UIStoryboardSegue, sender: AnyObject?) {
    if segue.identifier == "showDetail" {
      if let indexPath = self.tableView.indexPathForSelectedRow {
        let example = examples[indexPath.row]
        (segue.destinationViewController as! DetailViewController).detailItem = example
      }
    }
  }

  // MARK: - Table View

  func numberOfSectionsInTableView(tableView: UITableView) -> Int {
    return 1
  }

  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return examples.count
  }
    
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath as IndexPath) as UITableViewCell

    let example = examples[indexPath.row]
    cell.textLabel!.text = example.title
    return cell
  }
}

