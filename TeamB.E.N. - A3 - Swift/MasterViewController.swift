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
    
    //Motion Mngr objs
    let motionManager = CMMotionManager()
    let activityManager = CMMotionActivityManager()
    let customQueue = NSOperationQueue()
    let pedometer = CMPedometer()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Date and calendar objs
        let cal = NSCalendar.currentCalendar()
        let now = NSDate()
        
        let minusOneDay = NSDateComponents()
        minusOneDay.day = -1
        let nowMinusOneDay = cal.dateByAddingComponents(minusOneDay, toDate: now, options: nil)
        
        let startOfYesterday = cal.dateBySettingHour(0, minute: 0, second: 0, ofDate: nowMinusOneDay!, options: nil)
        let endOfYesterday = cal.dateBySettingHour(23, minute: 59, second: 59, ofDate: nowMinusOneDay!, options: nil)
        
        
        print(startOfYesterday)
        print(endOfYesterday)
        
        if CMMotionActivityManager.isActivityAvailable(){
            self.activityManager.startActivityUpdatesToQueue( self.customQueue)
                { (activity:CMMotionActivity!) -> Void in
                    
                    // parse out activity
                    var activityTxt = ""
                    
                    if(activity.walking){
                        activityTxt = "Walking"
                    } else if (activity.stationary) {
                        activityTxt = "You are doing nothing. Stop That!"
                    } else if (activity.cycling){
                        activityTxt = "Cycling"
                    } else if (activity.automotive) {
                        activityTxt = "You are in a car. Lazy."
                    }
                    
                    
                    dispatch_async(dispatch_get_main_queue())
                    {
                            
                            self.label_activity.text = activityTxt

                    }
            }
        }
        
        let startOfToday = cal.dateBySettingHour(0, minute: 0, second: 0, ofDate: NSDate(), options: nil)
        
        if CMPedometer.isStepCountingAvailable(){
            self.pedometer.startPedometerUpdatesFromDate(startOfToday) { (pedData: CMPedometerData!, error: NSError!) -> Void in
                
                dispatch_async(dispatch_get_main_queue())
                    {
                        self.label_today.text = pedData.numberOfSteps.stringValue + " steps"
                }
            }
            
            self.pedometer.queryPedometerDataFromDate(startOfYesterday, toDate: endOfYesterday) { (pedData: CMPedometerData!, error: NSError!) -> Void in
                
                dispatch_async(dispatch_get_main_queue())
                    {
                        self.label_yesterday.text = pedData.numberOfSteps.stringValue + " steps"
                }
            }
        }
        
    }
    
    @IBAction func onGoalButtonClick(sender: UIButton) {
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
