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
    @IBOutlet weak var laterIconImageView: UIImageView!
    @IBOutlet weak var archiveIconImageView: UIImageView!
    @IBOutlet weak var feedImageView: UIImageView!
    
    let initialFeedPosition: CGFloat = 165
    let initialFeedImageHeight: CGFloat = 86
    let initialContentSize: CGSize = CGSizeMake(320, 1367.5)
    
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

        scrollView.contentSize = feedView.image!.size
        
        let messagePanGestureRecognizer = UIPanGestureRecognizer(target: self, action: "messagePan:")
        messagePanGestureRecognizer.delegate = self
        messageImageView.addGestureRecognizer(messagePanGestureRecognizer)
        
        
        view.userInteractionEnabled = true

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
    
    func messagePan(sender: UIPanGestureRecognizer) {
        let translation = sender.translationInView(view)
        var newMessageImageViewLocation = messageImageView.frame.origin
        newMessageImageViewLocation.x = translation.x
        
        if (sender.state == .Began || sender.state == .Changed) {
            switch Int(newMessageImageViewLocation.x) {
            case Int.min...(-260):
                messageContainerView.backgroundColor = tanColor
                archiveIconImageView.frame.origin.x = newMessageImageViewLocation.x - 25 - 17
                laterIconImageView.frame.origin.x = newMessageImageViewLocation.x + 337
                laterIconImageView.image = UIImage(named: "list_icon")
            case -259...(-60):
                messageContainerView.backgroundColor = yellowColor
                archiveIconImageView.frame.origin.x = newMessageImageViewLocation.x - 25 - 17
                laterIconImageView.frame.origin.x = newMessageImageViewLocation.x + 337
                laterIconImageView.image = UIImage(named: "later_icon")
            case -59...0:
                archiveIconImageView.frame.origin.x = 17
                messageContainerView.backgroundColor = grayColor
                laterIconImageView.alpha = newMessageImageViewLocation.x/60.0 * -1
            case 1...60:
                archiveIconImageView.frame.origin.x = 278
                laterIconImageView.alpha = newMessageImageViewLocation.x/60.0
                messageContainerView.backgroundColor = grayColor
            case 61...260:
                messageContainerView.backgroundColor = greenColor
                archiveIconImageView.frame.origin.x = newMessageImageViewLocation.x - 25 - 17
                laterIconImageView.frame.origin.x = newMessageImageViewLocation.x + 337
                archiveIconImageView.image = UIImage(named: "archive_icon")
            default:
                messageContainerView.backgroundColor = redColor
                archiveIconImageView.frame.origin.x = newMessageImageViewLocation.x - 25 - 17
                laterIconImageView.frame.origin.x = newMessageImageViewLocation.x + 337
                archiveIconImageView.image = UIImage(named: "delete_icon")
            }
            
            messageImageView.frame.origin = newMessageImageViewLocation
            
        } else if sender.state == UIGestureRecognizerState.Ended {
            switch checkPosition(self.messageImageView) {
                case .normal:
                    UIView.animateWithDuration(0.3, delay: 0.0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.5, options: [], animations: { () -> Void in
                            self.messageImageView.frame.origin.x = 0
                            self.archiveIconImageView.center.x = 30
                            self.laterIconImageView.center.x = 290
                        }, completion: nil)
                case .reschedule:
                    UIView.animateWithDuration(0.3, delay: 0.0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.5, options: [], animations: { () -> Void in
                            self.messageImageView.frame.origin.x = -380
                            self.laterIconImageView.center.x = -350
                        }, completion: nil)
                case .list:
                    UIView.animateWithDuration(0.3, delay: 0.0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.5, options: [], animations: { () -> Void in
                            self.messageImageView.frame.origin.x = -380
                            self.laterIconImageView.center.x = -30
                        }, completion: nil)
                case .archive, .delete:
                    UIView.animateWithDuration(0.3, delay: 0.0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.5, options: [], animations: { () -> Void in
                            self.messageImageView.frame.origin.x = 380
                            self.archiveIconImageView.center.x = 350
                        }, completion: { finished in
                            self.closeAndResetMessage()
                        })
            }
            self.scrollView.scrollEnabled = true
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
        case 260...Int.max:
            return .delete
        default:
            return .normal
        }
    }
    
    func updateMessageStatus(state: messageStatus) {
        switch state {
            case .reschedule:
                print("Reschedule")
                laterIconImageView.image = UIImage(named: "later_icon")
                laterIconImageView.alpha = 1
                laterIconImageView.center.x = messageImageView.frame.origin.x + messageImageView.frame.width + 30
                archiveIconImageView.alpha = 0
            case .list:
                print("List")
                laterIconImageView.image = UIImage(named: "list_icon")
                laterIconImageView.alpha = 1
                laterIconImageView.center.x = messageImageView.frame.origin.x + messageImageView.frame.width + 30
                archiveIconImageView.alpha = 0
            case .archive:
                print("Archive")
//                messageContainerView.backgroundColor = UIColor.greenColor()
                archiveIconImageView.image = UIImage(named: "archive_icon")
                archiveIconImageView.alpha = 1
                archiveIconImageView.center.x = messageImageView.frame.origin.x - 30
                laterIconImageView.alpha = 0
            case .delete:
                print("Delete")
                messageContainerView.backgroundColor = UIColor.redColor()
                archiveIconImageView.image = UIImage(named: "delete_icon")
                archiveIconImageView.alpha = 1
                archiveIconImageView.center.x = messageImageView.frame.origin.x - 30
                laterIconImageView.alpha = 0
            case .normal:
                print("Normal")
                if messageImageView.frame.origin.x >= -60 && messageImageView.frame.origin.x <= -20 {
                    let percentage = abs((messageImageView.frame.origin.x + 20) / 40)
                    print("Percentage is \(percentage)")
                    laterIconImageView.alpha = percentage
                } else if messageImageView.frame.origin.x <= 60 && messageImageView.frame.origin.x >= 20 {
                    let percentage = abs((messageImageView.frame.origin.x - 20) / 40)
                    print("Percentage is \(percentage)")
                    archiveIconImageView.alpha = percentage
                }
            
        }
    }

    
    func closeAndResetMessage() {
        UIView.animateWithDuration(0.3, animations: { () -> Void in
            self.feedImageView.frame.origin.y = self.initialFeedPosition - self.initialFeedImageHeight
            self.scrollView.contentSize = CGSizeMake(320, self.initialContentSize.height - self.initialFeedImageHeight)
            }, completion: {
                finished in
                self.messageImageView.frame.origin.x = 0
                self.archiveIconImageView.center.x = 30
                self.laterIconImageView.center.x = 290
                UIView.animateWithDuration(0.5, delay: 1, options: .CurveEaseOut, animations: { () -> Void in
                    self.feedImageView.frame.origin.y = self.initialFeedPosition
                    self.scrollView.contentSize = CGSizeMake(320, self.initialContentSize.height)
                    }, completion: nil)
        })
    }

    
}
