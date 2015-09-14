//
//  ViewController.swift
//  Demo
//
//  Created by cloud on 8/29/15.
//  Copyright (c) 2015 cloud. All rights reserved.
//

import UIKit
import SwiftyJSON
import Foundation

@objc
protocol ViewControllerDelegate {
  optional func toggleSideView()
  optional func collapseSideVIew()
}

class ViewController: UITableViewController, UITableViewDelegate, UITableViewDataSource {
  
  var delegate: ViewControllerDelegate?
    
  @IBOutlet var textTable: UITableView!
  @IBOutlet weak var spinLabel: UIActivityIndicatorView!
    
  let topicViewSegueIdentifier = "topicViewSegue"
   
  let baseUrl = NSURL(string: "http://127.0.0.1:3000/api/v1/topics")
  var topics: [JSON] = [] {
    didSet{
      updateTable()
    }
  }
    
    override func viewDidLoad() {
        super.viewDidLoad()
      
      self.navigationItem.title = "极客公园·观察"
      
      var leftBarButtonItem = UIBarButtonItem.new()
      leftBarButtonItem.title = "☰"
      leftBarButtonItem.target = self
      leftBarButtonItem.action = "tapMenuBtn:"
      
      self.navigationItem.leftBarButtonItem = leftBarButtonItem
      
        textTable.delegate = self
        textTable.dataSource = self
       
        spinLabel.hidesWhenStopped = true
        spinLabel.startAnimating()
        getDataFromUrl(baseUrl!) {data in dispatch_async(dispatch_get_main_queue()){
            self.topics = [JSON(data: data!)]
            }
        }
        
        self.refreshControl?.addTarget(self, action: "handleRefresh:", forControlEvents: UIControlEvents.ValueChanged)
    }
    
    func handleRefresh(refreshControl: UIRefreshControl){
        getDataFromUrl(baseUrl!){data in dispatch_async(dispatch_get_main_queue()){
            self.topics = [JSON(data: data!)]
            }
        }
        self.textTable.reloadData()
        refreshControl.endRefreshing()
    }
    
    func updateTable() {
        println(topics)
        println(topics.count)
        textTable.reloadData()
        spinLabel.stopAnimating()
    }
    
    func getDataFromUrl(url: NSURL, completion: ((data: NSData?) -> Void)) {
        NSURLSession.sharedSession().dataTaskWithURL(url) {(data, response, error) in
            completion(data: data)
        }.resume()
    }
    
    func loadMore(){
        var page = self.topics.count + 1
        var pageUrl = NSURL(string: "http://127.0.0.1:3000/api/v1/topics?page=\(page)")
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
        var cell:TableViewCell = tableView.dequeueReusableCellWithIdentifier("TextTableCell") as! TableViewCell
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
            println(url)
            getDataFromUrl(NSURL(string: url)!){ data in dispatch_async(dispatch_get_main_queue()) {
                cell.imageLabel.image = UIImage(data: data!)
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
                    println(item)
                    println(item["title"].stringValue)
                    destination.titleText = item["title"].stringValue
                    destination.webUrl = item["url"].stringValue
                }
            }
        }
    }
  
  @IBAction func tapMenuBtn(sender: AnyObject) {
    delegate?.toggleSideView?()
  }
}

