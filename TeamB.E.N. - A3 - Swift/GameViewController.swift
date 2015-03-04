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
    
    var scene : SCNScene!
    var cameraNode : SCNNode!
    var camera : SCNCamera!
    var wallNode: SCNNode!
    var motionManager : CMMotionManager!
    
    
    //let activityManager = CMMotionActivityManager()
    let customQueue = NSOperationQueue()
    
    
    let numSteps = 100 //Step counter that will be imported from NSUserDefaults
    
//    scnView.allowsCameraControl = true
    
    var cameraOffsetX:Float = 0.0
    var cameraOffsetY:Float = 0.0
    
    var rotationOffset:Int = 0
    var direction:Int = 0
    var turnLeft = true
    var turnRight = true
    
    override func viewDidLoad() {
        
        NSLog("loading")
        super.viewDidLoad()
        
        /*if CMMotionActivityManager.isActivityAvailable() {
            self.activityManager.startActivityUpdatesToQueue(customQueue) {
                (activity:CMMotionActivity!) -> Void in
                NSLog("@", activity.description)
        
            }
        }*/
        
        scnView.autoenablesDefaultLighting = true
        scnView.allowsCameraControl = true
        
        
        let tapRecognizer = UITapGestureRecognizer(target: self, action: "handleTap:")
        view.gestureRecognizers = [tapRecognizer]
        
        motionManager = CMMotionManager()
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
        
        motionManager.startDeviceMotionUpdatesToQueue(NSOperationQueue.currentQueue()) {
            (deviceMotion, error) -> Void in
            
//            NSLog(deviceMotion.attitude.pitch.description)
            if(deviceMotion.attitude.pitch < -0.2) {
                NSLog("direction: %d", self.direction)
                if(self.direction == 0) {
                    self.cameraNode.position.y = self.cameraNode.position.y + 0.1
                }
                else if(self.direction == 1) {
                    self.cameraNode.position.x = self.cameraNode.position.x + 0.1
                }
                else if(self.direction == 2) {
                    self.cameraNode.position.y = self.cameraNode.position.y - 0.1
                }
                else if(self.direction == 3) {
                    self.cameraNode.position.x = self.cameraNode.position.x - 0.1
                }
//                NSLog("x: %f, y: %f, z: %f", self.cameraNode.position.x, self.cameraNode.position.y, self.cameraNode.position.z)
            }
            
            if(deviceMotion.attitude.roll < -1 && self.turnLeft) {
                self.rotationOffset -= 1
                self.direction = abs((self.rotationOffset % 4))
                self.cameraNode.pivot = SCNMatrix4MakeRotation(Float(M_PI_2) * Float(self.direction), 0, 0, 1)
                
                self.turnLeft = false
                
                //NSLog("w: %f, x: %f, y: %f, z: %f", self.cameraNode.rotation.w, self.cameraNode.rotation.x, self.cameraNode.rotation.y, self.cameraNode.rotation.z)
            }
            else if(deviceMotion.attitude.roll > 1 && self.turnRight) {
                self.rotationOffset += 1
                self.direction = abs((self.rotationOffset % 4))
                self.cameraNode.pivot = SCNMatrix4MakeRotation(Float(M_PI_2) * Float(self.direction), 0, 0, 1)
                
                self.turnRight = false
                
                //NSLog("w: %f, x: %f, y: %f, z: %f", self.cameraNode.rotation.w, self.cameraNode.rotation.x, self.cameraNode.rotation.y, self.cameraNode.rotation.z)
            }
            
            if(deviceMotion.attitude.roll > 0) {
                self.turnLeft = true
            }
            else if(deviceMotion.attitude.roll < 0) {
                self.turnRight = true
            }
        }
        
        
    }
    
    override func viewWillDisappear(animated: Bool) {
        /*if CMMotionActivityManager.isActivityAvailable() {
            self.activityManager.stopActivityUpdates()
        }*/
        super.viewWillDisappear(animated)
    }
    
    func setupWorld() {
        
        
        scene = SCNScene()
        scene.physicsWorld.speed = 1
        
        //Create the sphere
        setupSphere()
        
        //Setup camera
        setupCamera(0.0, offsetY: 0.0)
        
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
        //sphereNode.physicsBody?.restitution = 2.5
        sphereNode.position = SCNVector3(x: 15, y: 15, z: 1)
        
        scene.rootNode.addChildNode(sphereNode)
    }
    
    func setupCamera(offsetX:Float, offsetY:Float) {
        camera = SCNCamera()
        
        cameraNode = SCNNode()
        cameraNode.camera = camera
        cameraNode.position = SCNVector3(x: 15+offsetX, y: 15+offsetY, z: 10)
        //cameraNode.camera?.yFov = 30
        
        NSLog("camera moved")
        
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
        let redTile = SCNPlane(width: 10.0, height: 10.0)
        redTile.firstMaterial?.doubleSided = true
        redTile.firstMaterial?.diffuse.contents = UIColor.redColor()
        
        let whiteTile = SCNPlane(width: 10.0, height: 10.0)
        whiteTile.firstMaterial?.doubleSided = true
        whiteTile.firstMaterial?.diffuse.contents = UIColor.whiteColor()
        
        var redNode1 = SCNNode()
        redNode1.geometry = redTile
        redNode1.physicsBody = SCNPhysicsBody.staticBody()
        redNode1.position = SCNVector3(x: 0.0, y: 0.0, z: 0.0)
        scene.rootNode.addChildNode(redNode1)
        
        var redNode2 = SCNNode()
        redNode2.geometry = redTile
        redNode2.physicsBody = SCNPhysicsBody.staticBody()
        redNode2.position = SCNVector3(x: 20.0, y: 0.0, z: 0.0)
        scene.rootNode.addChildNode(redNode2)
        
        var redNode3 = SCNNode()
        redNode3.geometry = redTile
        redNode3.physicsBody = SCNPhysicsBody.staticBody()
        redNode3.position = SCNVector3(x: 0.0, y: 20.0, z: 0.0)
        scene.rootNode.addChildNode(redNode3)
        
        var redNode4 = SCNNode()
        redNode4.geometry = redTile
        redNode4.physicsBody = SCNPhysicsBody.staticBody()
        redNode4.position = SCNVector3(x: 10.0, y: 10.0, z: 0.0)
        scene.rootNode.addChildNode(redNode4)
        
        var redNode5 = SCNNode()
        redNode5.geometry = redTile
        redNode5.physicsBody = SCNPhysicsBody.staticBody()
        redNode5.position = SCNVector3(x: 20.0, y: 20.0, z: 0.0)
        scene.rootNode.addChildNode(redNode5)
        
        
        
        var whiteNode1 = SCNNode()
        whiteNode1.geometry = whiteTile
        whiteNode1.physicsBody = SCNPhysicsBody.staticBody()
        whiteNode1.position = SCNVector3(x: 10.0, y: 0.0, z: 0.0)
        scene.rootNode.addChildNode(whiteNode1)
        
        var whiteNode2 = SCNNode()
        whiteNode2.geometry = whiteTile
        whiteNode2.physicsBody = SCNPhysicsBody.staticBody()
        whiteNode2.position = SCNVector3(x: 0.0, y: 10.0, z: 0.0)
        scene.rootNode.addChildNode(whiteNode2)
        
        var whiteNode3 = SCNNode()
        whiteNode3.geometry = whiteTile
        whiteNode3.physicsBody = SCNPhysicsBody.staticBody()
        whiteNode3.position = SCNVector3(x: 10.0, y: 20.0, z: 0.0)
        scene.rootNode.addChildNode(whiteNode3)
        
        var whiteNode4 = SCNNode()
        whiteNode4.geometry = whiteTile
        whiteNode4.physicsBody = SCNPhysicsBody.staticBody()
        whiteNode4.position = SCNVector3(x: 20.0, y: 10.0, z: 0.0)
        scene.rootNode.addChildNode(whiteNode4)
        
        
    }
    
    func handleTap(sender: AnyObject) {
        setupSphere()
    }

}
