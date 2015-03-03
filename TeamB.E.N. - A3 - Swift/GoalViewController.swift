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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        goal_field.delegate = self

        // Do any additional setup after loading the view.
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
        
        return result
    }
    

}
