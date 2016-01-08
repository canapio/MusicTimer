//
//  ButtonViewController.swift
//  MusicTimer
//
//  Created by GwakDoyoung on 2016. 1. 7..
//  Copyright © 2016년 Kohei Hayakawa. All rights reserved.
//

import UIKit

protocol ButtonControllerDelegate: NSObjectProtocol {
    func touchBegan(sender: AnyObject!)
}

class ButtonViewController: NSObject, ButtonControllerDelegate {
    
    var buttonViewArray:[ButtonView] = []
    
    func touchBegan(sender: AnyObject!) {
        for btn: ButtonView in buttonViewArray {
            if sender !== btn {
                btn.forceTouchCancel()
            }
        }
    }
}