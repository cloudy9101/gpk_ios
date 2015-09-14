//
//  SideViewController.swift
//  Demo
//
//  Created by cloud on 9/7/15.
//  Copyright (c) 2015 cloud. All rights reserved.
//

import UIKit
import Foundation

@objc
protocol SideViewControllerDelegate {
  optional func itemSelected(item: String)
}

class SideViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
 
  var items = ["观察", "视频"]
  let cellId = "Side Cell"
  
  var delegate: SideViewControllerDelegate?
  
  @IBOutlet weak var sideTableView: UITableView!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    sideTableView.delegate = self
    sideTableView.dataSource = self
  }
  
  func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return items.count
  }
  
  func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    var cell: UITableViewCell = tableView.dequeueReusableCellWithIdentifier(cellId) as! UITableViewCell
    cell.textLabel!.text = items[indexPath.row]
    println(items[indexPath.row])
    return cell
  }
  
  func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    println("click")
    let selectedItem = items[indexPath.row]
    self.delegate?.itemSelected?(selectedItem)
  }
}
