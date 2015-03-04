//
//  MasterViewController.swift
//  TeamB.E.N. - A3 - Swift
//
//  Created by Nicole Sliwa on 2/25/15.
//  Copyright (c) 2015 Team B.E.N. All rights reserved.
//

import UIKit
import CoreMotion

class MasterViewController: UIViewController {
    
    // Outlets to UI
    @IBOutlet weak var label_yesterday: UILabel!
    @IBOutlet weak var progress_yesterday: UIProgressView!
    @IBOutlet weak var image_yesterday: UIImageView!
    
    @IBOutlet weak var label_today: UILabel!
    @IBOutlet weak var progress_today: UIProgressView!
    @IBOutlet weak var image_today: UIImageView!
    
    @IBOutlet weak var label_activity: UILabel!
    @IBOutlet weak var image_activity: UIImageView!
    
    @IBOutlet weak var button_reward: UIButton!

    
    
    //Motion Mngr objs
    let motionManager = CMMotionManager()
    let activityManager = CMMotionActivityManager()
    let customQueue = NSOperationQueue()
    let pedometer = CMPedometer()
    
    var stepGoal:Int = 0
    var progress:Float = 0.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        var defaultDict: NSDictionary?
        if let path = NSBundle.mainBundle().pathForResource("CustomDefaults", ofType: "plist") {
            defaultDict = NSDictionary(contentsOfFile: path)
        }
        if let dict = defaultDict {
            NSUserDefaults.standardUserDefaults().registerDefaults(dict)
//            NSLog(dict.description)
        }
        
        let defaults = NSUserDefaults.standardUserDefaults()
        if let goals = defaults.stringForKey("stepGoal")
        {
            stepGoal = goals.toInt()!;
        }
        
        
        //Date and calendar objs
        let cal = NSCalendar.currentCalendar()
        let now = NSDate()
        
        let minusOneDay = NSDateComponents()
        minusOneDay.day = -1
        let nowMinusOneDay = cal.dateByAddingComponents(minusOneDay, toDate: now, options: nil)
        
        let startOfYesterday = cal.dateBySettingHour(0, minute: 0, second: 0, ofDate: nowMinusOneDay!, options: nil)
        let endOfYesterday = cal.dateBySettingHour(23, minute: 59, second: 59, ofDate: nowMinusOneDay!, options: nil)
        
        if CMMotionActivityManager.isActivityAvailable(){
            self.activityManager.startActivityUpdatesToQueue( self.customQueue)
                { (activity:CMMotionActivity!) -> Void in
                    
                    // parse out activity
                    var activityTxt = ""
                    var imageTxt = "still"
                    
                    if(activity.running){
                        activityTxt = "Running"
                        imageTxt = "running"
                    } else if(activity.walking){
                        activityTxt = "Walking"
                        imageTxt = "walking"
                    } else if (activity.stationary) {
                        activityTxt = "You are doing nothing. Stop That!"
                        imageTxt = "still"
                    } else if (activity.cycling){
                        activityTxt = "Cycling"
                        imageTxt = "cycling"
                    } else if (activity.automotive) {
                        activityTxt = "You are in a car. Lazy."
                        imageTxt = "car"
                    }
                    
                    NSLog(activity.description)
                    
                    dispatch_async(dispatch_get_main_queue())
                    {
                        if(activityTxt != "")
                        {
                            self.label_activity.text = activityTxt
                            self.image_activity.image = UIImage(named: imageTxt)
                        }

                    }
            }
        }
        
        let startOfToday = cal.dateBySettingHour(0, minute: 0, second: 0, ofDate: NSDate(), options: nil)
        
        if CMPedometer.isStepCountingAvailable(){
            self.pedometer.startPedometerUpdatesFromDate(startOfToday) { (pedData: CMPedometerData!, error: NSError!) -> Void in
                
                dispatch_async(dispatch_get_main_queue())
                    {
                        self.progress = Float(pedData.numberOfSteps.stringValue.toInt()!) / Float(self.stepGoal)
                        self.progress_today.progress = self.progress
                        
                        if(self.progress < 0.5) {
                            self.image_today.backgroundColor = UIColor.redColor()
                            self.button_reward.enabled = true
                        }
                        else if(self.progress < 1.0) {
                            self.image_today.backgroundColor = UIColor.yellowColor()
                            self.button_reward.enabled = false
                        }
                        else {
                            self.image_today.backgroundColor = UIColor.greenColor()
                            self.button_reward.enabled = true
                        }
                        
                        self.label_today.text = pedData.numberOfSteps.stringValue + " steps"
                }
            }
            
            self.pedometer.queryPedometerDataFromDate(startOfYesterday, toDate: endOfYesterday) { (pedData: CMPedometerData!, error: NSError!) -> Void in
                
                dispatch_async(dispatch_get_main_queue())
                    {
                        self.progress = Float(pedData.numberOfSteps.stringValue.toInt()!) / Float(self.stepGoal)
                        self.progress_yesterday.progress = self.progress
                        
                        if(self.progress < 0.5) {
                            self.image_yesterday.backgroundColor = UIColor.redColor()
                        }
                        else if(self.progress < 1.0) {
                            self.image_yesterday.backgroundColor = UIColor.yellowColor()
                        }
                        else {
                            self.image_yesterday.backgroundColor = UIColor.greenColor()
                        }
                        
                        self.label_yesterday.text = pedData.numberOfSteps.stringValue + " steps"
                        
                }
            }
        }
        
    }
    
    @IBAction func onRewardButtonClick(sender: UIButton) {
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
