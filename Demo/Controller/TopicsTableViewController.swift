//
//  ViewController.swift
//  Demo
//
//  Created by cloud on 8/29/15.
//  Copyright (c) 2015 cloud. All rights reserved.
//

import UIKit
import SwiftyJSON

class TopicsTableViewController: BasicTableViewController, UITableViewDelegate, UITableViewDataSource {
  
  @IBOutlet var textTable: UITableView!
  @IBOutlet weak var spinLabel: UIActivityIndicatorView!
    
  let topicViewSegueIdentifier = "TopicViewSegue"
   
  var topics: [JSON] = [] {
    didSet{
      updateTable()
    }
  }
    
  override func viewDidLoad() {
    super.viewDidLoad()
    
    self.navigationItem.title = "观察"
    
    textTable.delegate = self
    textTable.dataSource = self
   
    spinLabel.hidesWhenStopped = true
    spinLabel.startAnimating()
    getDataFromUrl(topicsUrl!) {data in dispatch_async(dispatch_get_main_queue()){
      self.topics = [JSON(data: data!)]
      }
    }
  
    self.refreshControl?.addTarget(self, action: "handleRefresh:", forControlEvents: UIControlEvents.ValueChanged)
  }
  
  func handleRefresh(refreshControl: UIRefreshControl){
    getDataFromUrl(topicsUrl!){data in dispatch_async(dispatch_get_main_queue()){
      self.topics = [JSON(data: data!)]
      }
    }
    self.textTable.reloadData()
    refreshControl.endRefreshing()
  }
  
  func updateTable() {
    textTable.reloadData()
  }
  
  func loadMore(){
    var page = self.topics.count + 1
    var pageUrl = NSURL(string: "?page=\(page)", relativeToURL: topicsUrl)
    getDataFromUrl(pageUrl!){data in dispatch_async(dispatch_get_main_queue()){
        self.topics += [JSON(data: data!)]
        }
    }
  }
  
  // table delegate
  override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return self.topics.count * 10
  }
  
  override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    var cell:TopicTableViewCell = tableView.dequeueReusableCellWithIdentifier("TextTableCell") as! TopicTableViewCell
    // load more
    if indexPath.row == self.topics.count * 10 - 1 {
      loadMore()
    }
    
    let page = indexPath.row / 10
    let row = indexPath.row - page * 10
    
    if let title = topics[page][row]["title"].string {
      cell.titleLabel.text = title
    }
    if let desc = topics[page][row]["description"].string {
      cell.descLabel.text = desc
    }
    if let url = topics[page][row]["cover"]["file"]["url"].string {
      cell.unique = url
      cell.imageLabel.image = UIImage(named: "ImagePlaceholder")
      getDataFromUrl(NSURL(string: url)!){ data in dispatch_async(dispatch_get_main_queue())
        {
          if cell.unique == url {
            cell.imageLabel.image = UIImage(data: data!)
          }
        }
      }
    }
    
    return cell
  }
  
  override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
  }
  
  // prepare for topicView segue
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    if segue.identifier == topicViewSegueIdentifier {
      if let destination = segue.destinationViewController as? TopicViewController {
        if let topicIndex = textTable.indexPathForSelectedRow()?.row {
          let item = topics[topicIndex/10][topicIndex % 10]
          destination.titleText = item["title"].stringValue
          destination.webUrl = item["url"].stringValue
        }
      }
    }
  }
}
