//
//  ContainerViewController.swift
//  Demo
//
//  Created by cloud on 9/7/15.
//  Copyright (c) 2015 cloud. All rights reserved.
//

import UIKit

class ContainerViewController: UIViewController {
  
  struct Constants {
    static let topic = "文章"
    static let video = "视频"
  }
  
  var mainNavigationController: UINavigationController!
  var topicsTableViewController: TopicsTableViewController!
  var currentState: SlideOutState = .BothCollapsed {
    didSet {
      let shouldShowShadow = currentState != .BothCollapsed
      showShadowForMainViewController(shouldShowShadow)
    }
  }
  var sideViewController: SideViewController?
  let mainViewExpandedOffset: CGFloat = 120
  
  enum SlideOutState {
    case BothCollapsed
    case SideViewExpanded
  }
  
  override func viewDidLoad() {
    topicsTableViewController = UIStoryboard.topicsTableViewController()
    topicsTableViewController?.delegate = self
    
    mainNavigationController = UINavigationController(rootViewController: topicsTableViewController)
    view.addSubview(mainNavigationController.view)
    addChildViewController(mainNavigationController)
    
    let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: "handlePanGesture:")
    mainNavigationController.view.addGestureRecognizer(panGestureRecognizer)
  }
  
  func addChildSideViewController(sideViewController: SideViewController) {
    view.insertSubview(sideViewController.view, atIndex: 0)
    
    addChildViewController(sideViewController)
    sideViewController.didMoveToParentViewController(self)
  }

}

extension ContainerViewController: BasicTableViewDelegate {
  func toggleSideView() {
    let notAlreadyExpanded = (currentState != .SideViewExpanded)
    
    if notAlreadyExpanded {
      addSideViewController()
    }
    
    animateSideView(shouldExpand: notAlreadyExpanded)
  }
  
  func addSideViewController() {
    if (sideViewController == nil) {
      sideViewController = UIStoryboard.sideViewController()
      sideViewController?.delegate = self
      
      addChildSideViewController(sideViewController!)
    }
  }
  
  func animateSideView(#shouldExpand: Bool) {
    if shouldExpand {
      currentState = .SideViewExpanded
      
      animateMainViewXPosition(targetPosition: CGRectGetWidth(mainNavigationController.view.frame) - mainViewExpandedOffset)
    } else {
      animateMainViewXPosition(targetPosition: 0) { finished in
        self.currentState = .BothCollapsed
        
        self.sideViewController!.view.removeFromSuperview()
        self.sideViewController = nil
      }
    }
  }
  
  func animateMainViewXPosition(#targetPosition: CGFloat, completion: ((Bool) -> Void)! = nil) {
    UIView.animateWithDuration(0.5, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: .CurveEaseInOut, animations: {
      self.mainNavigationController.view.frame.origin.x = targetPosition
    }, completion: completion)
  }
  
  func showShadowForMainViewController(shouldShowShadow: Bool) {
    if (shouldShowShadow) {
      mainNavigationController.view.layer.shadowOpacity = 0.8
    } else {
      mainNavigationController.view.layer.shadowOpacity = 0.0
    }
  }
}

extension ContainerViewController: UIGestureRecognizerDelegate {
  func handlePanGesture(recognizer: UIPanGestureRecognizer) {
    let gestureIsDraggingFromLeftToRight = (recognizer.velocityInView(view).x > 0)
    
    switch(recognizer.state) {
    case .Began:
      if (currentState == .BothCollapsed) {
        if (gestureIsDraggingFromLeftToRight) {
          addSideViewController()
        }
      }
      showShadowForMainViewController(true)
    case .Changed:
      recognizer.view!.center.x = recognizer.view!.center.x + recognizer.translationInView(view).x
      recognizer.setTranslation(CGPointZero, inView: view)
    case .Ended:
      if (sideViewController != nil) {
        let hasMoveGreaterThanHalfway = recognizer.view!.center.x > view.bounds.size.width
        animateSideView(shouldExpand: hasMoveGreaterThanHalfway)
      }
    default:
      break
    }
  }
}

extension ContainerViewController: SideViewControllerDelegate {
  func itemSelected(item: String) {
    var viewController: BasicTableViewController?
    switch(item) {
      case Constants.topic:
        viewController = UIStoryboard.topicsTableViewController()
      case Constants.video:
        viewController = UIStoryboard.videosTableViewController()
    default:
      viewController = UIStoryboard.topicsTableViewController()
    }
    
    viewController?.delegate = self
    
    mainNavigationController.viewControllers = [viewController!]
    
    mainNavigationController.didMoveToParentViewController(self)
    
    toggleSideView()
  }
}

private extension UIStoryboard {
  
  struct Constants {
    static let sideViewController = "SideViewController"
    static let topicsTableViewController = "TopicsTableViewController"
    static let videosTableViewController = "VideosTableViewController"
  }
  
  class func mainStoryboard() -> UIStoryboard { return UIStoryboard(name: "Main", bundle: NSBundle.mainBundle()) }
  
  class func sideViewController() -> SideViewController? {
    return mainStoryboard().instantiateViewControllerWithIdentifier(Constants.sideViewController) as? SideViewController
  }
  
  class func topicsTableViewController() -> TopicsTableViewController? {
    return mainStoryboard().instantiateViewControllerWithIdentifier(Constants.topicsTableViewController) as? TopicsTableViewController
  }
  
  class func videosTableViewController() -> VideosTableViewController? {
    return mainStoryboard().instantiateViewControllerWithIdentifier(Constants.videosTableViewController) as? VideosTableViewController
  }
}