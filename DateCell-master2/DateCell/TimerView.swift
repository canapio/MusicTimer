//
//  TimerView.swift
//  MusicTimer
//
//  Created by GwakDoyoung on 2016. 1. 7..
//  Copyright © 2016년 Kohei Hayakawa. All rights reserved.
//

import UIKit
import MediaPlayer

class TimerView: UIView, ButtonViewDelegate {
    
    
    var viewController: UIViewController!
    
    private var pauseRect: CGRect!
    private var startRect: CGRect!
    
    var pauseButtonView: ButtonView!
    var stopButtonView: ButtonView!
    
    
    
    /*parrent is self*/
    var timerRedBGView: UIView!
    var timerRedBGMaskView: UIView!
    
    /*parrent is timerRedBGView*/
    var currentLabel_w: OSLable!
    var currentSecondLabel_w: OSLable!
    var highLowLabel_w: OSLable!
    var setLabel_w: OSLable!
    
    var currentLabel_r: OSLable!
    var currentSecondLabel_r: OSLable!
    var highLowLabel_r: OSLable!
    var setLabel_r: OSLable!
    
    var currentLabelText: String! {
        didSet {
            if currentLabel_r != nil { currentLabel_r.text = currentLabelText }
            if currentLabel_w != nil { currentLabel_w.text = currentLabelText }
        }
    }
    var currentSecondLabelText: String! {
        didSet {
            if currentSecondLabel_r != nil { currentSecondLabel_r.text = currentSecondLabelText }
            if currentSecondLabel_w != nil { currentSecondLabel_w.text = currentSecondLabelText }
        }
    }
    var highLowLabelText: String! {
        didSet {
            if highLowLabel_r != nil { highLowLabel_r.text = highLowLabelText }
            if highLowLabel_w != nil { highLowLabel_w.text = highLowLabelText }
        }
    }
    var setLabelText: String! {
        didSet {
            if setLabel_r != nil { setLabel_r.text = setLabelText }
            if setLabel_w != nil { setLabel_w.text = setLabelText }
        }
    }
    
    
    
    var maskCircleView: UIView!
    
    
    
    
    
    
    
    
    let dateFormatter = NSDateFormatter()
    
    
    var highDate: NSDate!
    var lowDate: NSDate!
    var setCount: Int!
    var isDone: Bool!
    var highLowInterval: NSTimeInterval!
    
    
    let player = MPMusicPlayerController.systemMusicPlayer();
    
    
    var updateTimer: NSTimer!
    //    var highBackgroundTimer: NSTimer!
    //    var lowBackgroundTimer: NSTimer!
    
    var startDate: NSDate!
    var pauseDate: NSDate!
    
    var isHigh: Bool!
    
    
    
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)   
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    /*
    Font Family Name = [Caviar Dreams]
    Font Names = [["CaviarDreams-BoldItalic", "CaviarDreams-Italic"]]
    */
    
    func setInit () {
        
        
        
        
        
        
        timerRedBGView = UIView.init(frame: CGRectMake(0, 0, self.frame.width, self.frame.height))
        timerRedBGView.backgroundColor = UIColor.init(netHex: DEFALUT_COLOR)
        self.addSubview(timerRedBGView)
        
        timerRedBGMaskView = UIView.init(frame: CGRectZero)
        timerRedBGMaskView.backgroundColor = UIColor.blackColor()
        timerRedBGView.maskView = timerRedBGMaskView
        
        
        
        
        
        
        
        
        
        
        currentLabel_r = OSLable.init(frame: CGRectMake(0, 0, self.frame.width, 400))
        self.addSubview(currentLabel_r)

        currentSecondLabel_r = OSLable.init(frame: CGRectMake(0, 0, self.frame.width, 30))
        self.addSubview(currentSecondLabel_r)
        
        highLowLabel_r = OSLable.init(frame: CGRectMake(0, 0, self.frame.width, 30))
        self.addSubview(highLowLabel_r)
        
        setLabel_r = OSLable.init(frame: CGRectMake(0, 0, self.frame.width, 30))
        self.addSubview(setLabel_r)
        
        makeLabels(currentLabel_r, currentSecondLabel: currentSecondLabel_r, highLowLabel: highLowLabel_r,  setLabel: setLabel_r, textColor: UIColor.init(netHex: DEFALUT_COLOR))
        
        

        
        
        currentLabel_w = OSLable.init(frame: CGRectMake(0, 0, self.frame.width, 400))
        timerRedBGView.addSubview(currentLabel_w)
        
        currentSecondLabel_w = OSLable.init(frame: CGRectMake(0, 0, self.frame.width, 30))
        timerRedBGView.addSubview(currentSecondLabel_w)
        
        highLowLabel_w = OSLable.init(frame: CGRectMake(0, 0, self.frame.width, 30))
        timerRedBGView.addSubview(highLowLabel_w)
        
        setLabel_w = OSLable.init(frame: CGRectMake(0, 0, self.frame.width, 30))
        timerRedBGView.addSubview(setLabel_w)
        
        makeLabels(currentLabel_w, currentSecondLabel: currentSecondLabel_w, highLowLabel: highLowLabel_w,  setLabel: setLabel_w, textColor: UIColor.whiteColor())
        
        
        timerRedBGView.superview?.bringSubviewToFront(timerRedBGView)
        
        
        
        makeButtons()
        
        dateFormatter.timeZone = NSTimeZone.init(name: "UTC")
    }
    
    func makeLabels (currentLabel: UILabel, currentSecondLabel: UILabel, highLowLabel: UILabel, setLabel: UILabel, textColor: UIColor) {
        let gap: CGFloat = 34.0
        let gap0:
        CGFloat = 6.0
        let currentLabely: CGFloat = gap
        let secondLabelTop: CGFloat = -8.0
        let setLabelTop: CGFloat = 22.0
        
        
        
        
        currentLabel.text = "00:00"
        currentLabel.font = UIFont.init(name: "CaviarDreams-Italic", size: 20)
        currentLabel.textColor = textColor
        currentLabel.numberOfLines = 1
        currentLabel.sizeToFit()
        
        currentLabel.font = UIFont.init(name: "CaviarDreams-Italic", size: 20*(self.frame.width-gap*2)/currentLabel.frame.width)
        currentLabel.sizeToFit()
        
        currentLabel.frame = CGRectMake(-gap0, currentLabely, self.frame.width, currentLabel.frame.height)
        currentLabel.textAlignment = NSTextAlignment.Center
        
        
        
        currentSecondLabel.frame = CGRectMake(gap, currentLabel.frame.origin.y + currentLabel.frame.height + secondLabelTop, self.frame.width-gap*2, 24)
        currentSecondLabel.text = "000"
        currentSecondLabel.font = UIFont.init(name: "CaviarDreams-BoldItalic", size: 22)
        currentSecondLabel.textAlignment = NSTextAlignment.Right
        currentSecondLabel.textColor = textColor
        currentSecondLabel.layer.masksToBounds = false
        currentSecondLabel.clipsToBounds = false
        
        
        
        
        highLowLabel.frame = CGRectMake(gap, currentSecondLabel.frame.origin.y + currentSecondLabel.frame.height + setLabelTop, self.frame.width-gap*2, 30)
        highLowLabel.text = "HIGH"
        highLowLabel.font = UIFont.init(name: "CaviarDreams-BoldItalic", size: 26)
        highLowLabel.textAlignment = NSTextAlignment.Left
        highLowLabel.textColor = textColor
        highLowLabel.layer.masksToBounds = false
        highLowLabel.clipsToBounds = false
        
        
        
        setLabel.frame = CGRectMake(gap, currentSecondLabel.frame.origin.y + currentSecondLabel.frame.height + setLabelTop, self.frame.width-gap*2, 30)
        setLabel.text = "1/2 SET"
        setLabel.font = UIFont.init(name: "CaviarDreams-BoldItalic", size: 26)
        setLabel.textAlignment = NSTextAlignment.Right
        setLabel.textColor = textColor
        setLabel.layer.masksToBounds = false
        setLabel.clipsToBounds = false
    }
    
    func makeButtons () {
        maskCircleView = UIView.init(frame: CGRectMake(0, 0, 0, 0))
        maskCircleView.backgroundColor = UIColor.blackColor()
        self.maskView = maskCircleView
        
        pauseButtonView = ButtonView.init(frame: CGRectMake(0, 0, 100, 100))
        stopButtonView = ButtonView.init(frame: CGRectMake(0, 0, 100, 100))
        
        pauseButtonView.bgColor1 = UIColor.init(white: 1.0, alpha: 1.0)
        pauseButtonView.bgColor2 = UIColor.init(white: 1.0, alpha: 0.5)
        pauseButtonView.image = UIImage.init(named: "pause")
        pauseButtonView.imageView.tintColor = UIColor.init(netHex: DEFALUT_COLOR)
        pauseButtonView.delegate = self
        
        
        stopButtonView.layer.cornerRadius = stopButtonView.frame.width/2
        stopButtonView.bgColor1 = UIColor.init(netHex: 0x82232A)
        stopButtonView.bgColor2 = UIColor.init(netHex: 0x82232A, alpha: 0.5)
        stopButtonView.image = UIImage.init(named: "stop")
        stopButtonView.imageView.tintColor = UIColor.whiteColor()
        stopButtonView.delegate = self
        
        let buttonController = ButtonViewController.init()
        buttonController.buttonViewArray.append(pauseButtonView)
        buttonController.buttonViewArray.append(stopButtonView)
        
        pauseButtonView.bcDelegate = buttonController
        stopButtonView.bcDelegate = buttonController
        
        stopButtonView.alpha = 0
        
        self.addSubview(pauseButtonView)
        self.addSubview(stopButtonView)
    }
    
    
    
    //
    func startTimerWithAnimate (pRect: CGRect, sRect: CGRect) {
        
        pauseRect = pRect
        startRect = sRect
        pauseButtonView.frame = pauseRect
        stopButtonView.frame = startRect
        
        pauseButtonView.layer.cornerRadius = pauseButtonView.frame.width/2
        stopButtonView.layer.cornerRadius = stopButtonView.frame.width/2
        
        maskCircleView.transform = CGAffineTransformMakeScale(1.0, 1.0);
        maskCircleView.frame = sRect
        maskCircleView.layer.cornerRadius = sRect.height/2
        
        
        
        self.backgroundColor = UIColor.init(netHex: DEFALUT_COLOR)
        stopButtonView.alpha = 0
        
        let dis = sqrt(pow(stopButtonView.center.x, 2.0) + pow(stopButtonView.center.y, 2.0))
        let rat = dis/(stopButtonView.frame.height/2)
        
        UIView.animateWithDuration(0.16, delay: 0.0, options: UIViewAnimationOptions.CurveEaseOut, animations: { () -> Void in
            self.maskCircleView.transform = CGAffineTransformMakeScale(rat, rat)
            self.stopButtonView.alpha = 1
            }, completion: { (completion) -> Void in
                
                self.backgroundColor = UIColor.init(white: 0.94, alpha: 1.0)
                
        })
        
        
        
        
        
        
        highLowInterval = highDate + lowDate
        
        
        isHigh = false
        isDone = false
        
        
        UIApplication.sharedApplication().beginBackgroundTaskWithExpirationHandler(nil)
        updateTimer = NSTimer.scheduledTimerWithTimeInterval(0.03, target: self, selector: "update", userInfo: nil, repeats: true);
        NSRunLoop.currentRunLoop().addTimer(updateTimer, forMode: NSRunLoopCommonModes)
        
        
        
        startTimer()
        
        
    }
    func stopTimerWithAnimate () {
        
        stopTimer()
        
        UIView.animateWithDuration(0.15, delay: 0.0, options: UIViewAnimationOptions.CurveEaseOut, animations: { () -> Void in
            self.maskCircleView.transform = CGAffineTransformMakeScale(1.0, 1.0)
            self.stopButtonView.alpha = 0
            
            }, completion: { (completion) -> Void in
                self.alpha = 0
                
        })
    }
    
    
    
    func touchEnded(sender: AnyObject!) {
        if sender === stopButtonView {
            stopTimerWithAnimate()
        } else if sender === pauseButtonView {
            if pauseDate != nil {
                // 플레이중
                resumeTimer(sender as! ButtonView)
            } else {
                // 멈춰있음
                pauseTimer(sender as! ButtonView)
            }
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
                
                let rate = CGFloat(interval)/CGFloat(highInterval)
                self.timerRedBGMaskView.frame = CGRectMake(0, 0, self.frame.width, self.frame.height*rate)
                
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
                
                let rate = 1.0 - CGFloat(interval)/CGFloat(lowInterval)
                self.timerRedBGMaskView.frame = CGRectMake(0, self.frame.height*(1.0-rate), self.frame.width, self.frame.height*rate)
            }
            
            let currentTime = NSDate.init(timeIntervalSince1970: interval)
            
            dateFormatter.dateFormat = "HH"
            
            if Int(dateFormatter.stringFromDate(currentTime)) > 0 {
                dateFormatter.dateFormat = "HH:mm:ss"
            } else {
                dateFormatter.dateFormat = "mm:ss"
            }
            
            currentLabelText = dateFormatter.stringFromDate(currentTime)
            
            dateFormatter.dateFormat = "SS"
            currentSecondLabelText = dateFormatter.stringFromDate(currentTime)
            
            if setCount == 0 {
                setLabelText = "Unlimit SET"
            } else {
                setLabelText = "\(Int(currentSet)) / \(setCount) SET"
            }
            
        }
    }
    
    func startTimer () {
        
        startDate = NSDate.init()
        pauseDate = nil
        
    }
    func stopTimer () {
        if updateTimer != nil {
            updateTimer.invalidate()
            updateTimer = nil
        }
    }
    func endAllSet () {
        if isDone==true {return}
        isDone = true
        
        if player.playbackState == MPMusicPlaybackState.Playing {
            player.pause()
        }
        
        let alert = UIAlertController(title: "Complete", message: "All set done", preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .Default, handler: { action in
//            self.navigationController?.dismissViewControllerAnimated(true, completion: nil)
        }))
        viewController.presentViewController(alert, animated: true, completion: nil)
        
        
    }
    
    
    func pauseTimer (sender: ButtonView) {
        pauseDate = NSDate()
        
        if isHigh == true {
            if player.playbackState == MPMusicPlaybackState.Playing {
                player.pause()
            }
        }
        
//        sender.setTitle("Resume", forState: UIControlState.Normal)
        sender.image = UIImage.init(named: "play")
    }
    func resumeTimer (sender: ButtonView) {
        let resumeDate = NSDate()
        print(resumeDate - pauseDate)
        startDate = startDate.dateByAddingTimeInterval(resumeDate - pauseDate)
        pauseDate = nil
        
        if isHigh == true {
            if player.playbackState != MPMusicPlaybackState.Playing {
                player.play()
            }
        }
        
//        sender.setTitle("Pause", forState: UIControlState.Normal)
        sender.image = UIImage.init(named: "pause")
    }
    
    
    
    
    func activeHigh () {
        if pauseDate != nil {return}
        isHigh = true
//        updateTotalLabel(isHigh)
        if player.playbackState != MPMusicPlaybackState.Playing {
            player.play()
        }
        
//        updateHighUI()
        highLowLabelText = "HIGH"
    }
    
    func activeLow () {
        if pauseDate != nil {return}
        isHigh = false
//        updateTotalLabel(isHigh)
        if player.playbackState == MPMusicPlaybackState.Playing {
            player.pause()
        }
        
//        updateLowUI()
        highLowLabelText = "Low"
    }
    
    
    
    
    
    
    
    
}

class OSLable :UILabel {
    override func drawTextInRect(rect: CGRect) {
        let insets: UIEdgeInsets = UIEdgeInsetsMake(0, 5, 0, 5)
        super.drawTextInRect(UIEdgeInsetsInsetRect(rect, insets))
    }
}



