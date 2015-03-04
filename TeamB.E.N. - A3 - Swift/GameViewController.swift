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
    //let activityManager = CMMotionActivityManager()
    let motionManager = CMMotionManager()
    let customQueue = NSOperationQueue()
    let scene = SCNScene()
    
    let numSteps = 100 //Step counter that will be imported from NSUserDefaults
    
    override func viewDidLoad() {
        
        NSLog("loading")
        super.viewDidLoad()
        
        /*if CMMotionActivityManager.isActivityAvailable() {
            self.activityManager.startActivityUpdatesToQueue(customQueue) {
                (activity:CMMotionActivity!) -> Void in
                NSLog("@", activity.description)
        
            }
        }*/
        
        let tapRecognizer = UITapGestureRecognizer(target: self, action: "handleTap:")
        view.gestureRecognizers = [tapRecognizer]
        
        motionManager.deviceMotionUpdateInterval = 0.1
        motionManager.startDeviceMotionUpdatesToQueue(NSOperationQueue.currentQueue()) {
            (deviceMotion, error) -> Void in
            
            let accel = deviceMotion.gravity
            
            let accelX = Float(9.8 * accel.x)
            let accelY = Float(9.8 * accel.y)
            let accelZ = Float(9.8 * accel.z)
            
            self.scene.physicsWorld.gravity = SCNVector3(x: accelX, y: accelY, z: accelZ)
        }
        
        NSLog("setting up")
        setupWorld()
        NSLog("setting down")
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        
    }
    
    override func viewWillDisappear(animated: Bool) {
        /*if CMMotionActivityManager.isActivityAvailable() {
            self.activityManager.stopActivityUpdates()
        }*/
        super.viewWillDisappear(animated)
    }
    
    func setupWorld() {
        
        
        
        scene.physicsWorld.speed = 1
        
        //Create the sphere
        setupSphere()
        
        //Setup camera
        setupCamera()
        
        //Setup floor
        //setupFloor()
        setupWall()
        
        scnView.backgroundColor = UIColor.blackColor()
        //scnView.allowsCameraControl = true
        
        scnView.scene = scene
    }
    
    func setupSphere() {
        let sphereGeometry = SCNSphere(radius: 1.0)
        sphereGeometry.segmentCount = 128
        
        let sphereNode = SCNNode(geometry: sphereGeometry)
        sphereNode.physicsBody = SCNPhysicsBody.dynamicBody()
        //ball.geometry?.firstMaterial = ballMaterial;
        sphereNode.physicsBody?.restitution = 2.5
        sphereNode.position = SCNVector3(x: 0, y: 0, z: 0)
        
        scene.rootNode.addChildNode(sphereNode)
    }
    
    func setupCamera() {
        let cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        cameraNode.position = SCNVector3(x: 0, y: 0, z: 30)
        
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
        floorNode.position = SCNVector3(x: 0.0, y: 0.0, z: -5)
        
        scene.rootNode.addChildNode(floorNode)
    }
    
    func setupWall() {
        let wall = SCNPlane(width: 10.0, height: 10.0)
        wall.firstMaterial?.doubleSided = true
        wall.firstMaterial?.diffuse.contents = UIColor.redColor() // make it red!!
        
        // add the plane to the world as a static body (no dynamic physics)
        let wallNode = SCNNode()
        wallNode.geometry = wall
        wallNode.physicsBody = SCNPhysicsBody.staticBody()
        wallNode.position = SCNVector3(x: 0.0, y: 0.0, z: -5)
        
        scene.rootNode.addChildNode(wallNode)
    }
    
    func handleTap(sender: AnyObject) {
        setupSphere()
    }

}
