//
//  DateCellTableViewController.swift
//  MusicTimer
//
//  Created by GwakDoyoung on 2015. 12. 28.
//  Copyright (c) 2015 canapio. All rights reserved.
//

import UIKit

class DateCellTableViewController: UITableViewController, ButtonViewDelegate {
    
    let kPickerAnimationDuration = 0.40 // duration for the animation to slide the date picker into view
    let kDatePickerTag           = 99   // view tag identifiying the date picker view
    
    let kTitleKey = "title" // key for obtaining the data source item's title
    let kDateKey  = "date"  // key for obtaining the data source item's date value
    
    // keep track of which rows have date cells
    let kDateStartRow = 0
    let kDateEndRow   = 1
    
    let kDateCellID       = "dateCell";       // the cells with the start or end date
    let kDatePickerCellID = "datePickerCell"; // the cell containing the date picker
    let kOtherCellID      = "otherCell";      // the remaining cells at the end

    var dataArray: [[String: AnyObject]] = []
    var dateFormatter = NSDateFormatter()
    
    // keep track which indexPath points to the cell with UIDatePicker
    var datePickerIndexPath: NSIndexPath?
    
    var pickerCellRowHeight: CGFloat = 216
    
    @IBOutlet weak var setCountLabel: UILabel!
    @IBOutlet var pickerView: UIDatePicker!
//    @IBOutlet weak var puaseButton: UIButton!
//    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var pauseButotnView: ButtonView!
    @IBOutlet weak var startButtonView: ButtonView!
    
    // for debug
    @IBOutlet weak var hiddenView: UIView!
    
    
    var timerView: TimerView! = nil

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.scrollEnabled = false
        
        var highInterval: Double! = 4//60*7
        var lowInterval: Double! = 3//60*1
        
        let hs = NSUserDefaults.standardUserDefaults().objectForKey("highInterval")
        let ls = NSUserDefaults.standardUserDefaults().objectForKey("lowInterval")
        if hs != nil {
            highInterval = Double(hs as! String)
        }
        
        if ls != nil {
            lowInterval = Double(ls as! String)
        }
        
        let date0 : NSDate! = NSDate.init(timeIntervalSince1970: highInterval)//cal.dateFromComponents(components)?.dateByAddingTimeInterval(60*7)
        let date1 : NSDate! = NSDate.init(timeIntervalSince1970: lowInterval)//cal.dateFromComponents(components)?.dateByAddingTimeInterval(60*1)
        
        let setCount = NSUserDefaults.standardUserDefaults().integerForKey("SetCount")
        updateSetCount(setCount)
        
        
//        startButton.layer.cornerRadius = startButton.frame.height/2.0
//        puaseButton.layer.cornerRadius = puaseButton.frame.height/2.0
//        puaseButton.tintColor = UIColor.init(netHex: DEFALUT_COLOR)
//        puaseButton.enabled = false
//        puaseButton.alpha = 0.7
        
        
        pauseButotnView.layer.cornerRadius = pauseButotnView.frame.width/2
        pauseButotnView.bgColor1 = UIColor.init(white: 1.0, alpha: 1.0)
        pauseButotnView.bgColor2 = UIColor.init(white: 1.0, alpha: 0.5)
        pauseButotnView.image = UIImage.init(named: "pause")
        pauseButotnView.imageView.tintColor = UIColor.init(netHex: DEFALUT_COLOR)
        pauseButotnView.delegate = self
        
        
        pauseButotnView.enable = false
        
        startButtonView.layer.cornerRadius = startButtonView.frame.width/2
        startButtonView.bgColor1 = UIColor.init(netHex: DEFALUT_COLOR)
        startButtonView.bgColor2 = UIColor.init(netHex: DEFALUT_COLOR, alpha: 0.5)
        startButtonView.image = UIImage.init(named: "start2")
        startButtonView.imageView.tintColor = UIColor.whiteColor()
        startButtonView.delegate = self
        
        let buttonController = ButtonViewController.init()
        buttonController.buttonViewArray.append(pauseButotnView)
        buttonController.buttonViewArray.append(startButtonView)
        
        pauseButotnView.bcDelegate = buttonController
        startButtonView.bcDelegate = buttonController

        
        // setup our data source
//        let itemOne = [kTitleKey : "7 set"]
        let itemTwo = [kTitleKey : "High Interval", kDateKey : date0]
        let itemThree = [kTitleKey : "Low Interval", kDateKey : date1]
        dataArray = [itemTwo, itemThree]
        
        dateFormatter.dateStyle = .ShortStyle // show short-style date format
        dateFormatter.timeStyle = .ShortStyle
        
        dateFormatter.timeZone = NSTimeZone.init(name: "UTC")
        dateFormatter.dateFormat = "HH:mm"
        
        // if the local changes while in the background, we need to be notified so we can update the date
        // format in the table view cells
        //
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "localeChanged:", name: NSCurrentLocaleDidChangeNotification, object: nil)
        
        
        
        timerView = TimerView.init(frame: CGRectMake(0, 0, self.view.frame.width, self.view.frame.height))
        self.view.addSubview(timerView)
        timerView.setInit()
        timerView.alpha = 0
        
        
        let recognizer = UILongPressGestureRecognizer.init(target: self, action: "touchLongPress:")
        recognizer.minimumPressDuration = 2.0
        self.hiddenView.addGestureRecognizer(recognizer)

        
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        displayInlineDatePickerForRowAtIndexPath(NSIndexPath.init(forRow: kDateStartRow, inSection: 0), animated: false)
    }

    
    // MARK: - Locale
    
    /*! Responds to region format or locale changes.
    */
    func localeChanged(notif: NSNotification) {
    // the user changed the locale (region format) in Settings, so we are notified here to
    // update the date format in the table view cells
    //
        tableView.reloadData()
    }
    

    /*! Determines if the given indexPath has a cell below it with a UIDatePicker.
    
    @param indexPath The indexPath to check if its cell has a UIDatePicker below it.
    */
    func hasPickerForIndexPath(indexPath: NSIndexPath) -> Bool {
        var hasDatePicker = false
        
        let targetedRow = indexPath.row + 1
        
        let checkDatePickerCell = tableView.cellForRowAtIndexPath(NSIndexPath(forRow: targetedRow, inSection: 0))
        let checkDatePicker = checkDatePickerCell?.viewWithTag(kDatePickerTag)
        
        hasDatePicker = checkDatePicker != nil
        return hasDatePicker
    }

    /*! Updates the UIDatePicker's value to match with the date of the cell above it.
    */
    func updateDatePicker() {
        if let indexPath = datePickerIndexPath {
            let associatedDatePickerCell = tableView.cellForRowAtIndexPath(indexPath)
            if let targetedDatePicker = associatedDatePickerCell?.viewWithTag(kDatePickerTag) as! UIDatePicker? {
                let itemData = dataArray[self.datePickerIndexPath!.row - 1]
                var date = NSDate()
                let calendar = NSCalendar.currentCalendar()
                let components = calendar.components([.Day , .Month , .Year], fromDate: date)
                date = calendar.dateFromComponents(components)!
                date = date.dateByAddingTimeInterval((itemData[kDateKey] as! NSDate).timeIntervalSince1970)
                targetedDatePicker.setDate(date, animated: false)
                
                
            }
        }
    }

    
    /*! Determines if the UITableViewController has a UIDatePicker in any of its cells.
    */
    func hasInlineDatePicker() -> Bool {
        return (datePickerIndexPath != nil)
    }
    
    /*! Determines if the given indexPath points to a cell that contains the UIDatePicker.
    
    @param indexPath The indexPath to check if it represents a cell with the UIDatePicker.
    */
    func indexPathHasPicker(indexPath: NSIndexPath) -> Bool {
        return hasInlineDatePicker() && datePickerIndexPath?.row == indexPath.row
    }

    /*! Determines if the given indexPath points to a cell that contains the start/end dates.
    
    @param indexPath The indexPath to check if it represents start/end date cell.
    */
    func indexPathHasDate(indexPath: NSIndexPath) -> Bool {
        var hasDate = false
        
        if (indexPath.row == kDateStartRow) || (indexPath.row == kDateEndRow || (hasInlineDatePicker() && (indexPath.row == kDateEndRow + 1))) {
            hasDate = true
        }
        return hasDate
    }

    
    // MARK: - Table view data source

    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return (indexPathHasPicker(indexPath) ? pickerCellRowHeight : tableView.rowHeight)
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Potentially incomplete method implementation.
        // Return the number of sections.
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
  
        if hasInlineDatePicker() {
            // we have a date picker, so allow for it in the number of rows in this section
            var numRows = dataArray.count
            return ++numRows;
        }
        
        return dataArray.count;
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell: UITableViewCell?
        
        var cellID = kOtherCellID
        
        if indexPathHasPicker(indexPath) {
            // the indexPath is the one containing the inline date picker
            cellID = kDatePickerCellID     // the current/opened date picker cell
        } else if indexPathHasDate(indexPath) {
            // the indexPath is one that contains the date information
            cellID = kDateCellID       // the start/end date cells
        }
        
        cell = tableView.dequeueReusableCellWithIdentifier(cellID)
    
//        if indexPath.row == 0 {
//            // we decide here that first cell in the table is not selectable (it's just an indicator)
//            cell?.selectionStyle = .None;
//        }
        
        // if we have a date picker open whose cell is above the cell we want to update,
        // then we have one more cell than the model allows
        //
        var modelRow = indexPath.row
        if (datePickerIndexPath != nil && datePickerIndexPath?.row <= indexPath.row) {
            modelRow--
        }
        
        let itemData = dataArray[modelRow]
        
        if cellID == kDateCellID {
            // we have either start or end date cells, populate their date field
            //
            cell?.textLabel?.text = itemData[kTitleKey] as? String
            cell?.detailTextLabel?.text = self.dateFormatter.stringFromDate(itemData[kDateKey] as! NSDate)
        } else if cellID == kOtherCellID {
            // this cell is a non-date cell, just assign it's text label
            //
            cell?.textLabel?.text = itemData[kTitleKey] as? String
        }
        
        return cell!
    }
    
    /*! Adds or removes a UIDatePicker cell below the given indexPath.
    
    @param indexPath The indexPath to reveal the UIDatePicker.
    */
    func toggleDatePickerForSelectedIndexPath(indexPath: NSIndexPath) {
        
        tableView.beginUpdates()
        
        let indexPaths = [NSIndexPath(forRow: indexPath.row + 1, inSection: 0)]
        
        // check if 'indexPath' has an attached date picker below it
        if hasPickerForIndexPath(indexPath) {
            // found a picker below it, so remove it
            tableView.deleteRowsAtIndexPaths(indexPaths, withRowAnimation: .Fade)
        } else {
            // didn't find a picker below it, so we should insert it
            tableView.insertRowsAtIndexPaths(indexPaths, withRowAnimation: .Fade)
        }
        tableView.endUpdates()
    }

    /*! Reveals the date picker inline for the given indexPath, called by "didSelectRowAtIndexPath".
    
    @param indexPath The indexPath to reveal the UIDatePicker.
    */
    func displayInlineDatePickerForRowAtIndexPath(indexPath: NSIndexPath, animated: Bool) {
        
        // display the date picker inline with the table content
        if animated {tableView.beginUpdates()}
        
        var before = false // indicates if the date picker is below "indexPath", help us determine which row to reveal
        if hasInlineDatePicker() {
            before = datePickerIndexPath?.row < indexPath.row
        }
        
        let sameCellClicked = (datePickerIndexPath?.row == indexPath.row + 1)
        
        
        // remove any date picker cell if it exists
        if !sameCellClicked && self.hasInlineDatePicker() {
            if animated {tableView.deleteRowsAtIndexPaths([NSIndexPath(forRow: datePickerIndexPath!.row, inSection: 0)], withRowAnimation: .Fade)}
            datePickerIndexPath = nil
        }
        
        
        if !sameCellClicked {
            // hide the old date picker and display the new one
            let rowToReveal = (before ? indexPath.row - 1 : indexPath.row)
            let indexPathToReveal = NSIndexPath(forRow: rowToReveal, inSection: 0)
            
            if animated {toggleDatePickerForSelectedIndexPath(indexPathToReveal)}
            datePickerIndexPath = NSIndexPath(forRow: indexPathToReveal.row + 1, inSection: 0)
        }
        
        // always deselect the row containing the start or end date
        if animated {tableView.deselectRowAtIndexPath(indexPath, animated:true)}
        
        if animated {tableView.endUpdates()}
        
        // inform our date picker of the current date to match the current cell
        updateDatePicker()
    }
    
    /*! Reveals the UIDatePicker as an external slide-in view, iOS 6.1.x and earlier, called by "didSelectRowAtIndexPath".
    
    @param indexPath The indexPath used to display the UIDatePicker.
    */

    func displayExternalDatePickerForRowAtIndexPath(indexPath: NSIndexPath) {
        
        // first update the date picker's date value according to our model
        let itemData: AnyObject = self.dataArray[indexPath.row]
        self.pickerView.setDate(itemData.valueForKey(kDateKey) as! NSDate, animated: true)
        
        // the date picker might already be showing, so don't add it to our view
        if self.pickerView.superview == nil {
            var startFrame = self.pickerView.frame
            var endFrame = self.pickerView.frame
            
            // the start position is below the bottom of the visible frame
            startFrame.origin.y = CGRectGetHeight(self.view.frame)
            
            // the end position is slid up by the height of the view
            endFrame.origin.y = startFrame.origin.y - CGRectGetHeight(endFrame)
            
            self.pickerView.frame = startFrame
            
            self.view.addSubview(self.pickerView)
            
            // animate the date picker into view
            UIView.animateWithDuration(kPickerAnimationDuration, animations: { self.pickerView.frame = endFrame }, completion: {(value: Bool) in
                // add the "Done" button to the nav bar
                //self.navigationItem.rightBarButtonItem = self.doneButton
            })
        }
    }
    
    
    // MARK: - UITableViewDelegate
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        let cell = tableView.cellForRowAtIndexPath(indexPath)
        if cell?.reuseIdentifier == kDateCellID {
            displayInlineDatePickerForRowAtIndexPath(indexPath, animated: true)
        } else {
            tableView.deselectRowAtIndexPath(indexPath, animated: true)
        }
    }
    
    
    // MARK: - Actions
    
    /*! User chose to change the date by changing the values inside the UIDatePicker.
    
    @param sender The sender for this action: UIDatePicker.
    */
    
    
    @IBAction func dateAction(sender: UIDatePicker) {
        
        var targetedCellIndexPath: NSIndexPath?
        
        if self.hasInlineDatePicker() {
            // inline date picker: update the cell's date "above" the date picker cell
            //
            targetedCellIndexPath = NSIndexPath(forRow: datePickerIndexPath!.row - 1, inSection: 0)
        } else {
            // external date picker: update the current "selected" cell's date
            targetedCellIndexPath = tableView.indexPathForSelectedRow!
        }
        
        let cell = tableView.cellForRowAtIndexPath(targetedCellIndexPath!)
        let targetedDatePicker = sender
        
        // update our data model
        var itemData = dataArray[targetedCellIndexPath!.row]
        
        var date = NSDate()
        let calendar = NSCalendar.currentCalendar()
        let components = calendar.components([.Day , .Month , .Year], fromDate: date)
        date = calendar.dateFromComponents(components)!
        
        let willUpdateDate = NSDate.init(timeIntervalSince1970: targetedDatePicker.date-date)
        itemData[kDateKey] = willUpdateDate
        dataArray[targetedCellIndexPath!.row] = itemData
        
        // update the cell's date string
        cell?.detailTextLabel?.text = dateFormatter.stringFromDate(willUpdateDate)
        
        let willUpdateInterval = willUpdateDate.timeIntervalSince1970
        if  self.datePickerIndexPath!.row-1 == kDateStartRow {
            NSUserDefaults.standardUserDefaults().setObject("\(willUpdateInterval)", forKey: "highInterval")
        } else if  self.datePickerIndexPath!.row-1 == kDateEndRow {
            NSUserDefaults.standardUserDefaults().setObject("\(willUpdateInterval)", forKey: "lowInterval")
        }
        NSUserDefaults.standardUserDefaults().synchronize()
        
    }

    @IBAction func clickStart(sender: AnyObject) {
        

//        let myview = UIView.init(frame: CGRectMake(0, 0, self.tableView.contentSize.width, self.tableView.contentSize.height-self.tableView.tableFooterView!.frame.height))
//        myview.backgroundColor = UIColor.init(white: 0.0, alpha: 1.0)
//        self.view.addSubview(myview)
//        return
        
        
//        let storyboard = UIStoryboard(name: "Main", bundle: nil)
//        let vc = storyboard.instantiateViewControllerWithIdentifier("TimerViewController") as! TimerViewController
//        vc.highDate = dataArray[kDateStartRow][kDateKey] as! NSDate
//        vc.lowDate = dataArray[kDateEndRow][kDateKey] as! NSDate
//        vc.setCount = NSUserDefaults.standardUserDefaults().integerForKey("SetCount")
//        if vc.setCount < 0 { vc.setCount = 0 }
//        
//        let nc = UINavigationController.init(rootViewController: vc)
//        
//        
//        self.navigationController?.presentViewController(nc, animated: true, completion: nil)
    }
    
    @IBAction func cllickUp(sender: AnyObject) {
        var setCount = NSUserDefaults.standardUserDefaults().integerForKey("SetCount")
        setCount = setCount+1
        setSetCount(setCount)
    }
    @IBAction func clickDown(sender: AnyObject) {
        var setCount = NSUserDefaults.standardUserDefaults().integerForKey("SetCount")
        setCount = setCount-1
        if setCount <= 0 { setCount=0; }
        else { }
        setSetCount(setCount)
        updateSetCount(setCount)
    }
    func setSetCount (setCount: Int) {
        NSUserDefaults.standardUserDefaults().setInteger(setCount, forKey: "SetCount")
        NSUserDefaults.standardUserDefaults().synchronize()
        updateSetCount(setCount)
    }
    func updateSetCount (setCount: Int) {
        if setCount == 0 {
            setCountLabel.text = "Unlimit Set"
        } else {
            setCountLabel.text = "\(setCount) Set"
        }
        
    }
    
    
    
    func touchEnded(sender: AnyObject!) {
        if sender === startButtonView {
            print("touch start button")
            
            let highDate = dataArray[kDateStartRow][kDateKey] as! NSDate
            let lowDate = dataArray[kDateEndRow][kDateKey] as! NSDate
            let setCount = NSUserDefaults.standardUserDefaults().integerForKey("SetCount")
            startTimer(highDate, lowDate: lowDate, setCount: setCount)
            
        } else if sender === pauseButotnView {
            print("touch pause button")
        }
    }
    
    func touchLongPress(gestureRecognizer:UIGestureRecognizer) {
        if gestureRecognizer.state == UIGestureRecognizerState.Began {
            startTimer(NSDate.init(timeIntervalSince1970: 4), lowDate: NSDate.init(timeIntervalSince1970: 3), setCount: 0)
        }
    }
    
    func startTimer (highDate: NSDate, lowDate: NSDate, setCount: Int) {
        timerView.alpha = 1

        let pRect = self.view!.convertRect(pauseButotnView.frame, fromView: pauseButotnView.superview)
        let sRect = self.view!.convertRect(startButtonView.frame, fromView: startButtonView.superview)
        timerView.viewController = self
        timerView.highDate = highDate
        timerView.lowDate = lowDate
        timerView.setCount = setCount
        
        timerView.startTimerWithAnimate(pRect, sRect: sRect)
    }
    
}




