//
//  TimerManager.swift
//  MusicTimer
//
//  Created by GwakDoyoung on 2016. 1. 6..
//  Copyright © 2016년 Kohei Hayakawa. All rights reserved.
//

import UIKit
import MediaPlayer

class TimerManager {
    static let sharedInstance = TimerManager()
    
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
    
    
    
}
