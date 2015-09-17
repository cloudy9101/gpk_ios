//
//  BasicTableViewController.swift
//  Demo
//
//  Created by cloud on 9/14/15.
//  Copyright (c) 2015 cloud. All rights reserved.
//

import UIKit

@objc
protocol BasicTableViewDelegate {
  optional func toggleSideView()
  optional func collapseSideView()
}

class BasicTableViewController: UITableViewController {
  
  var delegate: BasicTableViewDelegate?
  
  let topicsUrl = NSURL(string: "http://127.0.0.1:3000/api/v1/ios/topics")
  let videosUrl = NSURL(string: "http://127.0.0.1:3000/api/v1/videos")
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    var leftBarButtonItem = UIBarButtonItem.new()
    leftBarButtonItem.title = "☰"
    leftBarButtonItem.target = self
    leftBarButtonItem.action = "tapMenuBtn:"
    self.navigationItem.leftBarButtonItem = leftBarButtonItem
  }
  
  func getDataFromUrl(url: NSURL, completion: ((data: NSData?) -> Void)) {
    NSURLSession.sharedSession().dataTaskWithURL(url) {(data, response, error) in
      completion(data: data)
    }.resume()
  }
  
  func tapMenuBtn(sender: AnyObject) {
    delegate?.toggleSideView?()
  }
}
