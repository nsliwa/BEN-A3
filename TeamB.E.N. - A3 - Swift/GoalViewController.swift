//
//  GoalViewController.swift
//  TeamB.E.N. - A3 - Swift
//
//  Created by Nicole Sliwa on 2/25/15.
//  Copyright (c) 2015 Team B.E.N. All rights reserved.
//

import UIKit

class GoalViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var goal_field: UITextField!
    
    let defaults = NSUserDefaults.standardUserDefaults()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NSLog("view did load in goals")
        
        goal_field.delegate = self
//        goal_field.returnKeyType = UIReturnKeyType
//        goal_field.becomeFirstResponder()
        
        if let goals = defaults.stringForKey("stepGoal")
        {
            NSLog("goals %@", goals)
            goal_field.text = goals
        }

        // Do any additional setup after loading the view.
    }
    
    

    @IBAction func onSaveButtonClick(sender: UIButton) {
        
        NSLog("goals: %@", goal_field.text)
        defaults.setObject(goal_field.text, forKey: "stepGoal")
        self.view.endEditing(true)
    }

    
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        
        var result = true
        let prospectiveText = (textField.text as NSString).stringByReplacingCharactersInRange(range, withString: string)
        
        if textField == goal_field {
            if countElements(string) > 0 {
                let disallowedCharacterSet = NSCharacterSet(charactersInString: "0123456789").invertedSet
                let replacementStringIsLegal = string.rangeOfCharacterFromSet(disallowedCharacterSet) == nil
                let resultingStringLengthIsLegal = countElements(prospectiveText) <= 5
                
                result = replacementStringIsLegal && resultingStringLengthIsLegal
            }
        }
        
        NSLog("change char")
        
        return result
    }
    
    func textFieldShouldEndEditing(textField: UITextField!) -> Bool {  //delegate method
        NSLog("end editing")
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldShouldReturn(textField: UITextField!) -> Bool {   //delegate method
        textField.resignFirstResponder()
        
        NSLog("should return")
        
        return true
    }
    
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        NSLog("touches began")
        self.view.endEditing(true)
    }

}
