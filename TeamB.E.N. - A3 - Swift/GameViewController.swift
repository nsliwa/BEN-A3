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
    let scene = SCNScene()
    
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
        
        scene.physicsWorld.speed = 3
        
        //Create the sphere
        setupSphere()
        
        //Setup camera
        setupCamera()
        
        //Setup floor
        setupFloor()
        
        scnView.backgroundColor = UIColor.blackColor()
        scnView.allowsCameraControl = true
        
        scnView.scene = scene
    }
    
    func setupSphere() {
        let sphereGeometry = SCNSphere(radius: 1.0)
        sphereGeometry.segmentCount = 128
        
        let sphereNode = SCNNode(geometry: sphereGeometry)
        sphereNode.physicsBody = SCNPhysicsBody.dynamicBody()
        sphereNode.position = SCNVector3(x: Float(arc4random())/(Float(UINT32_MAX) * 10), y: 10.0, z: 0)
        
        scene.rootNode.addChildNode(sphereNode)
    }
    
    func setupCamera() {
        let cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        cameraNode.camera?.xFov = 50
        cameraNode.camera?.yFov = 50
        cameraNode.position = SCNVector3(x: 0, y: 2, z: 15)
        
        scene.rootNode.addChildNode(cameraNode)
    }
    
    func setupFloor() {
        let floorMaterial = SCNMaterial()
        floorMaterial.diffuse.contents = UIColor.init(red: 0.4, green: 0.4, blue: 0.4, alpha: 1)
        
        let floor = SCNFloor()
        floor.materials = [floorMaterial]
        floor.reflectivity = 0.1
        
        let floorNode = SCNNode()
        floorNode.geometry = floor
        floorNode.physicsBody = SCNPhysicsBody.staticBody()
        
        scene.rootNode.addChildNode(floorNode)
    }

}
