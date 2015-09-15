//
//  TopicViewController.swift
//  Demo
//
//  Created by cloud on 8/31/15.
//  Copyright (c) 2015 cloud. All rights reserved.
//

import UIKit

class TopicViewController: UIViewController {

//    @IBOutlet weak var titleLabel: UILabel!
//    @IBOutlet weak var textLabel: UITextView!
  @IBOutlet var webView: UIWebView!
  
  var titleText = String()
  var webUrl = String()
  
  override func viewDidLoad() {
    super.viewDidLoad()

    // Do any additional setup after loading the view.
//        titleLabel.text = titleText
    webView.loadRequest(NSURLRequest(URL: NSURL(string: webUrl)!))
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  

  /*
  // MARK: - Navigation

  // In a storyboard-based application, you will often want to do a little preparation before navigation
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    // Get the new view controller using segue.destinationViewController.
    // Pass the selected object to the new view controller.
  }
  */

}
