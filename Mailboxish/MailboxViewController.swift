//
//  MailboxViewController.swift
//  Mailboxish
//
//  Created by Michelle Harvey on 2/15/16.
//  Copyright © 2016 Michelle Venetucci Harvey. All rights reserved.
//

import UIKit

class MailboxViewController: UIViewController, UIScrollViewDelegate, UIGestureRecognizerDelegate {

    @IBOutlet weak var laterFeedView: UIImageView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var feedView: UIImageView!
    @IBOutlet weak var messageImageView: UIImageView!
    @IBOutlet weak var messageContainerView: UIView!
    @IBOutlet weak var rightIconImageView: UIImageView!
    @IBOutlet weak var leftIconImageView: UIImageView!
    @IBOutlet weak var feedImageView: UIImageView!
    @IBOutlet weak var rescheduleView: UIImageView!
    @IBOutlet weak var archiveFeedView: UIImageView!
    @IBOutlet weak var navSegmentedControl: UISegmentedControl!
    @IBOutlet weak var composeImageView: UIImageView!
    @IBOutlet weak var sideMenuImageView: UIImageView!
    @IBOutlet weak var listView: UIImageView!
    
    // Message pan gesture config
    let leftIconOffsetFromMessageView = CGFloat(-42)
    let rightIconOffsetFromMessageView = CGFloat(337)
    let rightIconInitialXPosition = CGFloat(277)
    let leftIconInitialXPosition = CGFloat(17)
    
    // Menu edge gesture config
    let maxMenuOpenDistance = CGFloat(270)
    let minMenuOpenDistance = CGFloat(0)
    let menuBreakpoint = CGFloat(150)
    
    // Message background colors
    let greenColor = UIColor(red: 116/255, green: 215/255, blue: 104/255, alpha: 1)
    let redColor = UIColor(red: 233/255, green: 85/255, blue: 59/255, alpha: 1)
    let yellowColor = UIColor(red: 249/255, green: 209/255, blue: 69/255, alpha: 1)
    let tanColor = UIColor(red: 215/255, green: 165/255, blue: 120/255, alpha: 1)
    let grayColor = UIColor(red: 227/255, green: 227/255, blue: 227/255, alpha: 1)
    
    // Gesture recognizer config
    var messagePanGestureRecognizer: UIPanGestureRecognizer!
    var menuPanGestureRecognizer: UIPanGestureRecognizer!
    var menuEdgeGestureRecognizer: UIScreenEdgePanGestureRecognizer!
    
    enum messageStatus {
        case reschedule
        case list
        case archive
        case delete
        case normal
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the initial active segment to mailbox view
        navSegmentedControl.selectedSegmentIndex = 1

        // scroll view setup
        scrollView.contentSize = feedView.image!.size
        
        // Gesture for individual message
        messagePanGestureRecognizer = UIPanGestureRecognizer(target: self, action: "messageDidPan:")
        messagePanGestureRecognizer.delegate = self
        messageImageView.addGestureRecognizer(messagePanGestureRecognizer)
        
        // Edge pan to reveal menu
        menuEdgeGestureRecognizer = UIScreenEdgePanGestureRecognizer(target: self, action: "onEdgePan:")
        menuEdgeGestureRecognizer.edges = UIRectEdge.Left
        scrollView.addGestureRecognizer(menuEdgeGestureRecognizer)
        
        // Pan gesture for open menu
        menuPanGestureRecognizer = UIPanGestureRecognizer(target: self, action: "menuDidPanOpen:")
        menuPanGestureRecognizer.delegate = self
    }
    
    func onEdgePan(sender: UIScreenEdgePanGestureRecognizer) {
        // Relative change in (x,y) coordinates from where gesture began.
        let translation = sender.translationInView(view)
        
        setScrollViewPosition(translation)
        
        if sender.state == UIGestureRecognizerState.Ended {
            snapScrollViewPosition(translation)
        }
    }
    
    func snapScrollViewPosition(translation: CGPoint) {
        UIView.animateWithDuration(0.2) { () -> Void in
            if translation.x < self.menuBreakpoint {
               self.scrollView.frame.origin.x = 0
               self.scrollView.removeGestureRecognizer(self.menuPanGestureRecognizer)
            } else {
               self.scrollView.frame.origin.x = self.maxMenuOpenDistance
               self.scrollView.addGestureRecognizer(self.menuPanGestureRecognizer)
            }
        }
    }
    
    func menuDidPanOpen(sender: UIPanGestureRecognizer) {
        feedPanGesture(sender.translationInView(view))
        
        if sender.state == .Ended {
            snapScrollViewPosition(sender.translationInView(view))
        }
    }
    
    func feedPanGesture(translation: CGPoint) {
        scrollView.frame.origin.x = translation.x + maxMenuOpenDistance
    }
    
    func setScrollViewPosition(translation: CGPoint) {
        
        if translation.x < maxMenuOpenDistance {
            scrollView.frame.origin.x = translation.x
        } else {
            scrollView.frame.origin.x = maxMenuOpenDistance
        }
    }
    
    
    func messageDidPan(sender: UIPanGestureRecognizer) {
        keepImageAndIconsNSyncWithPanGesture(sender.translationInView(view))
        
        if (sender.state == .Began || sender.state == .Changed) {
            updateMessageActionState()
        } else if sender.state == .Ended {
            snapMessageViewToEndState()
            self.scrollView.scrollEnabled = true
        }
    }
    
    func keepImageAndIconsNSyncWithPanGesture(translation: CGPoint) {
        messageImageView.frame.origin.x = translation.x
        leftIconImageView.frame.origin.x = translation.x + leftIconOffsetFromMessageView
        rightIconImageView.frame.origin.x = translation.x + rightIconOffsetFromMessageView
    }
    
    func updateMessageActionState() {
        switch Int(messageImageView.frame.origin.x) {
        case Int.min...(-260):
            messageContainerView.backgroundColor = tanColor
            rightIconImageView.image = UIImage(named: "list_icon")
        case -259...(-60):
            messageContainerView.backgroundColor = yellowColor
            rightIconImageView.image = UIImage(named: "later_icon")
        case -59...0:
            rightIconImageView.frame.origin.x = rightIconInitialXPosition
            messageContainerView.backgroundColor = grayColor
            rightIconImageView.alpha = messageImageView.frame.origin.x/60.0 * -1
        case 1...60:
            leftIconImageView.frame.origin.x = leftIconInitialXPosition
            rightIconImageView.alpha = messageImageView.frame.origin.x/60.0
            messageContainerView.backgroundColor = grayColor
        case 61...260:
            messageContainerView.backgroundColor = greenColor
            leftIconImageView.image = UIImage(named: "archive_icon")
        default:
            messageContainerView.backgroundColor = redColor
            leftIconImageView.image = UIImage(named: "delete_icon")
        }
    }
    
    func snapMessageViewToEndState() {
        switch checkPosition(messageImageView) {
        case .normal:
            UIView.animateWithDuration(0.3, delay: 0.0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.5, options: [], animations: { () -> Void in
                self.resetMessageView()
            }, completion: nil)
        case .reschedule:
            UIView.animateWithDuration(0.3, delay: 0.0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.5, options: [], animations: { () -> Void in
                self.messageImageView.frame.origin.x = -380
                self.rightIconImageView.center.x = -350
                }, completion: { (Bool) -> Void in
                    self.rescheduleView.alpha = 1
                })
            
        case .list:
            UIView.animateWithDuration(0.3, delay: 0.0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.5, options: [], animations: { () -> Void in
                self.messageImageView.frame.origin.x = -380
                self.rightIconImageView.center.x = -30
                }, completion: { (Bool) -> Void in
                    self.listView.alpha = 1
                })
        case .archive, .delete:
            UIView.animateWithDuration(0.3, delay: 0.0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.5, options: [], animations: { () -> Void in
                self.messageImageView.frame.origin.x = 380
                self.leftIconImageView.center.x = 350
            }, completion: { finished in
                self.closeAndResetMessage()
            })
        }
    }
    
    func resetMessageView() {
        self.messageImageView.frame.origin.x = 0
        self.leftIconImageView.center.x = 30
        self.rightIconImageView.center.x = 290
    }
    
    func checkPosition(view: UIImageView!) -> messageStatus {
        switch Int(view.frame.origin.x) {
        case Int.min...(-260):
            return .list
        case -260...(-60):
           return .reschedule
        case 60...260:
            return .archive
        case 260...Int.max as ClosedInterval:
            return .delete
        default:
            return .normal
        }
    }

    
    func closeAndResetMessage() {
        let initialFeedPosition = feedImageView.frame.origin.y
        let messageHeight = messageContainerView.frame.height
        let messageContainerInitialPosition = messageContainerView.frame.origin.y
        
        UIView.animateWithDuration(0.3, animations: { () -> Void in
            self.feedImageView.frame.origin.y = initialFeedPosition - messageHeight
            self.messageContainerView.frame.origin.y = messageContainerInitialPosition - messageHeight
        }) { finished in
            self.resetMessageView()
            UIView.animateWithDuration(0.5, delay: 1, options: .CurveEaseOut, animations: { () -> Void in
                    self.feedImageView.frame.origin.y = initialFeedPosition
                    self.messageContainerView.frame.origin.y = messageContainerInitialPosition
            }, completion: nil)
        }
    }

    @IBAction func onRescheduleDidTap(sender: UITapGestureRecognizer) {
        rescheduleView.alpha = 0
        closeAndResetMessage()
    }
    
    @IBAction func onListDidTap(sender: UITapGestureRecognizer) {
        listView.alpha = 0
        closeAndResetMessage()
        
    }
    
    @IBAction func didChangeNavSegmentedControl(sender: UISegmentedControl) {
        UIView.animateWithDuration(0.3) { () -> Void in
            switch sender.selectedSegmentIndex {
            case 0:
                self.laterFeedView.frame.origin.x = 0
                self.archiveFeedView.frame.origin.x = 320
                self.feedImageView.frame.origin.x = 320
                self.messageContainerView.frame.origin.x = 320
            case 2:
                self.laterFeedView.frame.origin.x = -320
                self.archiveFeedView.frame.origin.x = 0
                self.feedImageView.frame.origin.x = -320
                self.messageContainerView.frame.origin.x = -320
            default:
                self.laterFeedView.frame.origin.x = -320
                self.archiveFeedView.frame.origin.x = 320
                self.feedImageView.frame.origin.x = 0
                self.messageContainerView.frame.origin.x = 0
            }
        }
    }
    
    @IBAction func composeButtonDidTap(sender: AnyObject) {
        UIView.animateWithDuration(0.3, delay: 0, options: .CurveEaseOut, animations: { () -> Void in
            self.composeImageView.alpha = 1
            self.composeImageView.frame.origin.y -= 480
            self.scrollView.alpha = 0.5
            self.sideMenuImageView.alpha = 0
        }, completion: nil)
    }
    
    @IBAction func composeCancelDidTap(sender: AnyObject) {
        UIView.animateWithDuration(0.3, delay: 0, options: .CurveEaseOut, animations: { () -> Void in
            self.composeImageView.alpha = 0
            self.composeImageView.frame.origin.y += 480
            self.scrollView.alpha = 1
            self.sideMenuImageView.alpha = 1
        }, completion: nil)
    }
}
