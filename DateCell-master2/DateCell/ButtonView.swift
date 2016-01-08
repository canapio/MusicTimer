//
//  ButtonView.swift
//  MusicTimer
//
//  Created by GwakDoyoung on 2016. 1. 6..
//  Copyright © 2016년 Kohei Hayakawa. All rights reserved.
//

import UIKit







@objc protocol ButtonViewDelegate: NSObjectProtocol {
    optional func touchBegan(sender: AnyObject!)
    optional func touchCancelled(sender: AnyObject!)
    optional func touchMoved(sender: AnyObject!)
    optional func touchEnded(sender: AnyObject!)
}


class ButtonView: UIView {
    let TOUCH_EXTRA_RANGE: CGFloat = 15.0
    
    var delegate: ButtonViewDelegate! = nil
    var bcDelegate: ButtonControllerDelegate! = nil
    
    var touchOn: Bool! = false
    
    var imageView: UIImageView!
    var bgColor1: UIColor! {
        didSet {
            self.backgroundColor = bgColor1
        }
    }
    var bgColor2: UIColor!
    override var frame: CGRect {
        didSet {
            super.frame = frame
            if imageView != nil {imageView.center = CGPointMake(self.frame.width/2, self.frame.height/2)}
        }
    }
    var image: UIImage! {
        get { return self.image }
        set (newImage) {
            if newImage != nil {
                if imageView == nil {
                    imageView = UIImageView.init()
                    self.addSubview(imageView)
                }
                imageView.image = newImage.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)
                imageView.frame = CGRectMake(0, 0, newImage.size.width, newImage.size.height)
                imageView.center = CGPointMake(self.frame.width/2, self.frame.height/2)
            }
            
        }
    }
    var enable: Bool = true {
        didSet {
            if enable == true {
                self.userInteractionEnabled = true
                self.alpha = 1.0
            } else {
                self.userInteractionEnabled = false
                self.alpha = 0.5
            }
        }
    }
    
    

    override init(frame: CGRect) {
        super.init(frame: frame)
        setInit()
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setInit()
    }
    
    func setInit () {
        
    }
    
    
    
    
    
    
    func forceTouchCancel () {
        if touchOn == true {
            touchOn = false
            self.buttonCancelAnimation()
        }
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if bcDelegate != nil && bcDelegate.respondsToSelector("touchBegan:") {
            bcDelegate.touchBegan(self)
        }
        
        touchOn = true
        self.buttonOnAnimation()
    }
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        
        let touch = touches.first
        let touchPoint: CGPoint = (touch?.locationInView(self))!
        let rect: CGRect = CGRectMake(-TOUCH_EXTRA_RANGE, -TOUCH_EXTRA_RANGE, self.frame.width+TOUCH_EXTRA_RANGE*2, self.frame.height+TOUCH_EXTRA_RANGE*2)
        
        if CGRectContainsPoint(rect, touchPoint) {
            if !touchOn {
                touchOn = true
                self.buttonOnAnimation()
            }
        } else {
            if touchOn == true {
                touchOn = false
                self.buttonCancelAnimation()
            }
        }
        
    }
    override func touchesCancelled(touches: Set<UITouch>?, withEvent event: UIEvent?) {
        if touchOn == true {
            touchOn = false
            self.buttonCancelAnimation()
        }
    }
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if touchOn==true {
            self.buttonOffAnimation()
            
            if delegate != nil && delegate.respondsToSelector("touchEnded:") {
                delegate.touchEnded!(self)
            }
        }
    }
    
    
    
    func buttonOnAnimation () {
        UIView.animateWithDuration(0.05) { () -> Void in
            self.layer.backgroundColor = self.bgColor2.CGColor
        }
    }
    func buttonOffAnimation () {
        UIView.animateWithDuration(0.32) { () -> Void in
            self.layer.backgroundColor = self.bgColor1.CGColor
        }
    }
    func buttonCancelAnimation () {
        UIView.animateWithDuration(0.07) { () -> Void in
            self.layer.backgroundColor = self.bgColor1.CGColor
        }
    }
    
    
}
