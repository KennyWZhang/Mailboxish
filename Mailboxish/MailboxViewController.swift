//
//  MailboxViewController.swift
//  Mailboxish
//
//  Created by Michelle Harvey on 2/15/16.
//  Copyright © 2016 Michelle Venetucci Harvey. All rights reserved.
//

import UIKit

class MailboxViewController: UIViewController, UIScrollViewDelegate, UIGestureRecognizerDelegate {

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var feedView: UIImageView!
    @IBOutlet weak var messageImageView: UIImageView!
    @IBOutlet weak var messageContainerView: UIView!
    @IBOutlet weak var rightIconImageView: UIImageView!
    @IBOutlet weak var leftIconImageView: UIImageView!
    @IBOutlet weak var feedImageView: UIImageView!
    
    // Scroll view feed config
    let initialFeedPosition: CGFloat = 165
    let initialFeedImageHeight: CGFloat = 86
    let initialContentSize: CGSize = CGSizeMake(320, 1367.5)
    
    // Message pan gesture config
    let leftIconOffsetFromMessageView = CGFloat(-42)
    let rightIconOffsetFromMessageView = CGFloat(337)
    let rightIconInitialXPosition = CGFloat(277)
    let leftIconInitialXPosition = CGFloat(17)
    
    // Message background colors
    let greenColor = UIColor(red: 116/255, green: 215/255, blue: 104/255, alpha: 1)
    let redColor = UIColor(red: 233/255, green: 85/255, blue: 59/255, alpha: 1)
    let yellowColor = UIColor(red: 249/255, green: 209/255, blue: 69/255, alpha: 1)
    let tanColor = UIColor(red: 215/255, green: 165/255, blue: 120/255, alpha: 1)
    let grayColor = UIColor(red: 227/255, green: 227/255, blue: 227/255, alpha: 1)
    
    var messagePanGestureRecognizer: UIPanGestureRecognizer!
    
    enum messageStatus {
        case reschedule
        case list
        case archive
        case delete
        case normal
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // scroll view setup
        scrollView.contentSize = feedView.image!.size
        
        // Gesture for individual message
        let messagePanGestureRecognizer = UIPanGestureRecognizer(target: self, action: "messageDidPan:")
        messagePanGestureRecognizer.delegate = self
        messageImageView.addGestureRecognizer(messagePanGestureRecognizer)
    }
    
    func messageDidPan(sender: UIPanGestureRecognizer) {
        keepImageAndIconsNSyncWithPanGesture(sender.translationInView(view))
        
        if (sender.state == .Began || sender.state == .Changed) {
            updateMessageActionState()
        } else if sender.state == .Ended {
            snapToEndState()
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
    
    func snapToEndState() {
        switch checkPosition(messageImageView) {
        case .normal:
            UIView.animateWithDuration(0.3, delay: 0.0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.5, options: [], animations: { () -> Void in
                self.messageImageView.frame.origin.x = 0
                self.leftIconImageView.center.x = 30
                self.rightIconImageView.center.x = 290
            }, completion: nil)
        case .reschedule:
            UIView.animateWithDuration(0.3, delay: 0.0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.5, options: [], animations: { () -> Void in
                self.messageImageView.frame.origin.x = -380
                self.rightIconImageView.center.x = -350
            }, completion: nil)
        case .list:
            UIView.animateWithDuration(0.3, delay: 0.0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.5, options: [], animations: { () -> Void in
                self.messageImageView.frame.origin.x = -380
                self.rightIconImageView.center.x = -30
            }, completion: nil)
        case .archive, .delete:
            UIView.animateWithDuration(0.3, delay: 0.0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.5, options: [], animations: { () -> Void in
                self.messageImageView.frame.origin.x = 380
                self.leftIconImageView.center.x = 350
            }, completion: { finished in
                self.closeAndResetMessage()
            })
        }
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
        UIView.animateWithDuration(0.3, animations: { () -> Void in
            self.feedImageView.frame.origin.y = self.initialFeedPosition - self.initialFeedImageHeight
            self.scrollView.contentSize = CGSizeMake(320, self.initialContentSize.height - self.initialFeedImageHeight)
            }, completion: {
                finished in
                self.messageImageView.frame.origin.x = 0
                self.leftIconImageView.center.x = 30
                self.rightIconImageView.center.x = 290
                UIView.animateWithDuration(0.5, delay: 1, options: .CurveEaseOut, animations: { () -> Void in
                    self.feedImageView.frame.origin.y = self.initialFeedPosition
                    self.scrollView.contentSize = CGSizeMake(320, self.initialContentSize.height)
                    }, completion: nil)
        })
    }

    
}
