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
  
  var page = 1
  
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
    self.page = self.page + 1
    var pageUrl = NSURL(string: "?page=\(page)", relativeToURL: topicsUrl)
    getDataFromUrl(pageUrl!){data in dispatch_async(dispatch_get_main_queue()){
      for (key, subJson) in JSON(data: data!) {
        println(key)
        if key != "error" {
          self.topics += [JSON(data: data!)]
        } else {
          self.page = self.page + 1
          self.loadMore()
        }
      }}
    }
  }
  
  // table delegate
  override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
    return self.topics.count
  }
    
  override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    var res = 0
    for (date, subTopics) in self.topics[section] {
      res = subTopics.count
    }
    return res
  }
  
  override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
    var view = UIView(frame: CGRectMake(0, 0, self.view.bounds.width, 100))
    var label = UILabel(frame: CGRectMake(0, -5, view.bounds.width, 30))
    label.font = UIFont.systemFontOfSize(14)
    label.textColor = UIColor.whiteColor()
    label.textAlignment = NSTextAlignment.Center
    view.addSubview(label)
    view.backgroundColor = UIColor(red: 0.2, green: 0.7, blue: 0.9, alpha: 1)
    for (date, subJson) in self.topics[section] {
      if section == 0 {
        label.text = "最新文章"
      } else {
        label.text = date
      }
    }
    self.navigationController!.title = "最新文章"
    return view
  }
  
  override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    var cell:TopicTableViewCell = tableView.dequeueReusableCellWithIdentifier("TextTableCell") as! TopicTableViewCell
    // load more
    if indexPath.section == self.topics.count - 1 {
      if indexPath.row == self.topics[indexPath.section].count - 1 {
        loadMore()
      }
    }
    
    for (date, subTopics) in topics[indexPath.section] {
      if let title = subTopics[indexPath.row]["title"].string {
        cell.titleLabel.text = title
      }
      if let desc = subTopics[indexPath.row]["description"].string {
        cell.descLabel.text = desc
      }
      if let url = subTopics[indexPath.row]["cover"]["file"]["url"].string {
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
    }
    
    return cell
  }
  
  override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
  }
  
  // prepare for topicView segue
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    if segue.identifier == topicViewSegueIdentifier {
      if let destination = segue.destinationViewController as? TopicViewController {
        if let topicIndex = textTable.indexPathForSelectedRow() {
          let item = topics[topicIndex.section]
          for (date, subJson) in item {
            destination.titleText = subJson[topicIndex.row]["title"].stringValue
            destination.webUrl = subJson[topicIndex.row]["url"].stringValue
          }
        }
      }
    }
  }
}
