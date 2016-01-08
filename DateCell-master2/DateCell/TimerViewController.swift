//
//  TimerViewController.swift
//  MusicTimer
//
//  Created by GwakDoyoung on 2015. 12. 28.
//  Copyright © 2015년 canapio. All rights reserved.
//

import UIKit
import MediaPlayer

class TimerViewController: UIViewController {
    
    let dateFormatter = NSDateFormatter()
    
    var highDate: NSDate!
    var lowDate: NSDate!
    var setCount: Int!
    var isDone: Bool!
    var highLowInterval: NSTimeInterval!
    
    
    @IBOutlet weak var slideView: UIView!
    @IBOutlet weak var currentLabel: UILabel!
    @IBOutlet weak var totalLabel: UILabel!
    
    @IBOutlet weak var activeHighLabel: UILabel!
    @IBOutlet weak var activeLowLabel: UILabel!
    
    @IBOutlet weak var setGraphicView: UIView!
    @IBOutlet weak var setTitleLabel: UILabel!
    @IBOutlet weak var setStatusLabel: UILabel!
    
    let player = MPMusicPlayerController.systemMusicPlayer();
    
    
    var updateTimer: NSTimer!
//    var highBackgroundTimer: NSTimer!
//    var lowBackgroundTimer: NSTimer!
    
    var startDate: NSDate!
    var pauseDate: NSDate!
    
    var isHigh: Bool!
    
    

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let homeButton : UIBarButtonItem = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.Done, target: self, action: "clickClose")
        self.navigationItem.rightBarButtonItem = homeButton
        
        
        dateFormatter.timeZone = NSTimeZone.init(name: "UTC")
        slideView.transform = CGAffineTransformMakeRotation(CGFloat(-M_PI*0.25));
        
        highLowInterval = highDate + lowDate

        isHigh = false
        isDone = false

        updatActiveLabel(isHigh)
        updateTotalLabel(isHigh)
        
        
        UIApplication.sharedApplication().beginBackgroundTaskWithExpirationHandler(nil)
        updateTimer = NSTimer.scheduledTimerWithTimeInterval(0.03, target: self, selector: "update", userInfo: nil, repeats: true);
        NSRunLoop.currentRunLoop().addTimer(updateTimer, forMode: NSRunLoopCommonModes)
        
        
        
        startTimer()
        
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidDisappear(animated: Bool) {
        if updateTimer != nil {
            updateTimer.invalidate()
            updateTimer = nil
        }
    }
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    func clickClose () {
        self.navigationController?.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func clickStopButton(sender: AnyObject) {
        self.navigationController?.dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    
    @IBAction func clickPauseOrResume(sender: AnyObject) {
        if pauseDate != nil {
            // 플레이중
            resumeTimer(sender as! UIButton)
        } else {
            // 멈춰있음
            pauseTimer(sender as! UIButton)
        }
    }
    
    
    
    func playorpause () {
        if player.playbackState == MPMusicPlaybackState.Playing {
            // 재생중
            print("playing");
            player.pause();
//            updateUIAtStop ()
        } else if player.playbackState == MPMusicPlaybackState.Stopped {
            // 멈춰있는중
            print("stoping \(player)");
            player.play();
//            updateUIAtStart ()
        } else if player.playbackState == MPMusicPlaybackState.Paused {
            // 일시정지중
            print("pausing");
            player.play();
//            updateUIAtStart ()
        } else {
            
        }
    }
    
    func update () {
        if pauseDate != nil {
            // 
        } else {
            // startDate와 현재시간 계산
            let nowDate = NSDate()
            let totalInterval = nowDate-startDate
            let currentSet = totalInterval / highLowInterval
            var interval = totalInterval % highLowInterval
            let highInterval = highDate.timeIntervalSince1970
            let lowInterval = lowDate.timeIntervalSince1970
            
            
            
            
            if interval <= highInterval {
                // high
                interval = highInterval-(interval)
                if isHigh == false {
                    activeHigh()
                }
            } else {
                // low
                
                // end
                if setCount != 0 && Int(currentSet) >= setCount-1 {
                    endAllSet ()
                    return
                }
                
                
                interval = interval - highInterval
                interval = lowInterval-(interval)
                if isHigh == true {
                    activeLow()
                }
            }
            
            let currentTime = NSDate.init(timeIntervalSince1970: interval)
            
            dateFormatter.dateFormat = "HH"
            
            if Int(dateFormatter.stringFromDate(currentTime)) > 0 {
                dateFormatter.dateFormat = "HH:mm:ss"
            } else {
                dateFormatter.dateFormat = "mm:ss"
            }
            
            currentLabel.text = dateFormatter.stringFromDate(currentTime)
            
            if setCount == 0 {
                setStatusLabel.text = "Unlimit"
            } else {
                setStatusLabel.text = "\(Int(currentSet)) / \(setCount)"
            }
            
        }
    }
    
    func startTimer () {
        
        startDate = NSDate.init()
        pauseDate = nil
    }
    func stopTimer () {
        
    }
    func endAllSet () {
        if isDone==true {return}
        isDone = true
        
        if player.playbackState == MPMusicPlaybackState.Playing {
            player.pause()
        }
        
        let alert = UIAlertController(title: "Complete", message: "All set done", preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .Default, handler: { action in
            self.navigationController?.dismissViewControllerAnimated(true, completion: nil)
        }))
        self.presentViewController(alert, animated: true, completion: nil)
        
        
    }
    
    
    func pauseTimer (sender: UIButton) {
        pauseDate = NSDate()
        
        if isHigh == true {
            if player.playbackState == MPMusicPlaybackState.Playing {
                player.pause()
            }
        }
        
        sender.setTitle("Resume", forState: UIControlState.Normal)
    }
    func resumeTimer (sender: UIButton) {
        let resumeDate = NSDate()
        print(resumeDate - pauseDate)
        startDate = startDate.dateByAddingTimeInterval(resumeDate - pauseDate)
        pauseDate = nil
        
        if isHigh == true {
            if player.playbackState != MPMusicPlaybackState.Playing {
                player.play()
            }
        }
        
        sender.setTitle("Pause", forState: UIControlState.Normal)
    }
    
    

    
    func activeHigh () {
        if pauseDate != nil {return}
        isHigh = true
        updateTotalLabel(isHigh)
        if player.playbackState != MPMusicPlaybackState.Playing {
            player.play()
        }
        
        updateHighUI()
    }
    
    func activeLow () {
        if pauseDate != nil {return}
        isHigh = false
        updateTotalLabel(isHigh)
        if player.playbackState == MPMusicPlaybackState.Playing {
            player.pause()
        }
        
        updateLowUI()
    }
    
    
    
    func updatActiveLabel(isHigh: Bool) {
        var activeFont: UIFont! = UIFont.boldSystemFontOfSize(18)
        var unactiveFont: UIFont! = UIFont.systemFontOfSize(18)
        if #available(iOS 8.2, *) {
            activeFont = UIFont.systemFontOfSize(18, weight: 0.8)
            unactiveFont = UIFont.systemFontOfSize(18, weight: 0.05)
        } else {
            // Fallback on earlier versions
        }
        
        if isHigh == true {
            activeHighLabel.font = activeFont
            activeLowLabel.font = unactiveFont
            activeHighLabel.alpha = 1.0
            activeLowLabel.alpha = 0.4
        } else {
            activeHighLabel.font = unactiveFont
            activeLowLabel.font = activeFont
            activeHighLabel.alpha = 0.4
            activeLowLabel.alpha = 1.0
        }
        
    }
    
    func updateTotalLabel(isHigh: Bool) {
        dateFormatter.dateFormat = "HH"
        
        print(Int(dateFormatter.stringFromDate(highDate)))
        
        if (isHigh == true && Int(dateFormatter.stringFromDate(highDate)) > 0) || (isHigh == false && Int(dateFormatter.stringFromDate(lowDate)) > 0) {
            dateFormatter.dateFormat = "HH:mm:ss"
        } else {
            dateFormatter.dateFormat = "mm:ss"
        }
        
        if isHigh == true {
            totalLabel.text = dateFormatter.stringFromDate(highDate)
        } else {
            totalLabel.text = dateFormatter.stringFromDate(lowDate)
        }
        
    }
    
    
    func updateHighUI () {
        let bgColor = UIColor.init(netHex: 0xFCFCFC)
        let textColor = UIColor.init(netHex: 0x000000)
        
        
        
        
        UIView.transitionWithView(view, duration: 0.12, options: UIViewAnimationOptions.TransitionCrossDissolve, animations: { () -> Void in
            self.view.backgroundColor = bgColor
            
            self.currentLabel.textColor = textColor
            self.slideView.backgroundColor = textColor
            self.totalLabel.textColor = textColor
            
            self.activeHighLabel.textColor = textColor
            self.activeLowLabel.textColor = textColor
            
            self.setTitleLabel.textColor = textColor
            self.setStatusLabel.textColor = textColor
            
            self.updatActiveLabel(true)
            }, completion: nil)
        
        
    }
    func updateLowUI () {
        let bgColor = UIColor.init(netHex: 0x0A0A0A)
        let textColor = UIColor.init(netHex: 0xFAFAFA)
        
        UIView.transitionWithView(view, duration: 0.12, options: UIViewAnimationOptions.TransitionCrossDissolve, animations: { () -> Void in
            self.view.backgroundColor = bgColor
            
            
            self.currentLabel.textColor = textColor
            self.slideView.backgroundColor = textColor
            self.totalLabel.textColor = textColor
            
            self.activeHighLabel.textColor = textColor
            self.activeLowLabel.textColor = textColor
            
            self.setTitleLabel.textColor = textColor
            self.setStatusLabel.textColor = textColor
            
            self.updatActiveLabel(false)
            }, completion: nil)
        
        
    }
    
    
    
    
    
    
    
    

}

func - (left: NSDate, right: NSDate) -> NSTimeInterval {
    return left.timeIntervalSinceDate(right)
}
func + (left: NSDate, right: NSDate) -> NSTimeInterval {
    return left.timeIntervalSince1970 + right.timeIntervalSince1970
}


extension UIColor {
    convenience init(netHex:Int, alpha: CGFloat) {
        let red = (netHex >> 16) & 0xff
        let green = (netHex >> 8) & 0xff
        let blue = netHex & 0xff
        self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: alpha)
    }
    convenience init(netHex:Int) {
        self.init(netHex: netHex, alpha: 1.0)
    }
    
}


