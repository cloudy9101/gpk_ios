//
//  VideoTableViewController.swift
//  Demo
//
//  Created by cloud on 9/10/15.
//  Copyright (c) 2015 cloud. All rights reserved.
//

import UIKit
import SwiftyJSON

class VideosTableViewController: BasicTableViewController, UITableViewDelegate, UITableViewDataSource {
  
  var videos: [JSON] = [] {
    didSet{
      updateTable()
    }
  }
  
  @IBOutlet var videosTableView: UITableView!
  @IBOutlet weak var spinView: UIActivityIndicatorView!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    videosTableView.delegate = self
    videosTableView.dataSource = self
   
    spinView.hidesWhenStopped = true
    spinView.startAnimating()
    
    getDataFromUrl(videosUrl!) {data in dispatch_async(dispatch_get_main_queue()){
      self.videos = [JSON(data: data!)]
      }
    }
    
    self.refreshControl?.addTarget(self, action: "handleRefresh:", forControlEvents: UIControlEvents.ValueChanged)
  }
  
  func handleRefresh() {
    getDataFromUrl(videosUrl!) { data in
      dispatch_async(dispatch_get_main_queue()) {
        self.videos = [JSON(data: data!)]
      }
    }
  }
  
  func updateTable() {
    videosTableView.reloadData()
  }
  
  func loadMore() {
    spinView.startAnimating()
    
    var page = self.videos.count + 1
    var pageUrl = NSURL(string: "?page=\(page)", relativeToURL: videosUrl)
    getDataFromUrl(pageUrl!){ data in dispatch_async(dispatch_get_main_queue()){
        self.videos += [JSON(data: data!)]
      }
    }
  }
  
  // table delegate
  override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return self.videos.count * 10
  }
  
  override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    var cell: VideoTableViewCell = videosTableView.dequeueReusableCellWithIdentifier("Video Table View Cell") as! VideoTableViewCell
    // load more
    if indexPath.row == self.videos.count * 10 - 1 {
      loadMore()
    }
    
    let page = indexPath.row / 10
    let row = indexPath.row - page * 10
    
    if let title = videos[page][row]["title"].string {
      cell.title.text = title
    }
    if let desc = videos[page][row]["description"].string {
      cell.desc.text = desc
    }
    if let cover = videos[page][row]["cover"]["url"].string {
      getDataFromUrl(NSURL(string: cover)!){ data in dispatch_async(dispatch_get_main_queue()) {
          cell.cover.image = UIImage(data: data!)
        }
      }
    }
    
    return cell
  }
}
