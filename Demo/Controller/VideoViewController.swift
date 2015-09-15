//
//  VideoViewController.swift
//  Demo
//
//  Created by cloud on 9/15/15.
//  Copyright (c) 2015 cloud. All rights reserved.
//

import UIKit

class VideoViewController: UIViewController {
 
  var url = String()
 
  @IBOutlet weak var webView: UIWebView!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    webView.loadRequest(NSURLRequest(URL: NSURL(string: url)!))
  }

}
