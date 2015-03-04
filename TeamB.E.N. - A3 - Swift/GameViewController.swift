//
//  GameController.swift
//  TeamB.E.N. - A3 - Swift
//
//  Created by ch484-mac4 on 2/26/15.
//  Copyright (c) 2015 Team B.E.N. All rights reserved.
//

import CoreMotion
import UIKit
import SceneKit
import QuartzCore

class GameViewController: UIViewController {
    
    @IBOutlet weak var scnView: SCNView!
    let activityManager = CMMotionActivityManager()
    let customQueue = NSOperationQueue()
    
    let numSteps = 100 //Step counter that will be imported from NSUserDefaults
    
    override func viewDidLoad() {
        
        NSLog("loading")
        super.viewDidLoad()
        
        if CMMotionActivityManager.isActivityAvailable() {
            self.activityManager.startActivityUpdatesToQueue(customQueue) {
                (activity:CMMotionActivity!) -> Void in
                NSLog("@", activity.description)
            }
        }
        NSLog("setting up")
        setupWorld()
        NSLog("setting down")
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        
    }
    
    override func viewWillDisappear(animated: Bool) {
        if CMMotionActivityManager.isActivityAvailable() {
            self.activityManager.stopActivityUpdates()
        }
        super.viewWillDisappear(animated)
    }
    
    func setupWorld() {
        
        NSLog("setting view")
        let scene = SCNScene()
        
        NSLog("done setting view") 
        
        let boxGeometry = SCNBox(width: 10.0, height: 10.0, length: 10.0, chamferRadius: 1.0)
        let boxNode = SCNNode(geometry: boxGeometry)
        scene.rootNode.addChildNode(boxNode)
        
        scnView.scene = scene
    }

}
