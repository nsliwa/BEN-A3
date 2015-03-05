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
    @IBOutlet weak var label_balls: UIButton!
    
    var scene : SCNScene!
    var cameraNode : SCNNode!
    var camera : SCNCamera!
    var wallNode: SCNNode!
    var motionManager : CMMotionManager!
    
    var westNode : SCNNode!
    var eastNode : SCNNode!
    var northNode : SCNNode!
    var southNode : SCNNode!
    var ceilingNode : SCNNode!
    
    @IBAction func onButtonExploreClick(sender: UIButton) {
        if( scnView.allowsCameraControl == true) {
            scnView.allowsCameraControl = false
            //cameraNode.position = SCNVector3(x: 15, y: 15, z: 27)
        }
        else if (scnView.allowsCameraControl == false) {
            scnView.allowsCameraControl = true
        }
    }
    
    //let activityManager = CMMotionActivityManager()
    let customQueue = NSOperationQueue()
    
    var balls = 0 //Step counter that will be imported from NSUserDefaults
    var ballNodes: [SCNNode] = []
    //var ballNodes: UnsafeMutablePointer<SCNNode> = nil
    
    
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
        
        
        let tapRecognizer = UITapGestureRecognizer(target: self, action: "handleTap:")
        let doubleTapRecognizer = UITapGestureRecognizer(target: self, action: "handleDoubleTap:")
        tapRecognizer.numberOfTapsRequired = 1
        doubleTapRecognizer.numberOfTapsRequired = 2
        
        
        view.gestureRecognizers = [tapRecognizer, doubleTapRecognizer]
        
        motionManager = CMMotionManager()
        motionManager.deviceMotionUpdateInterval = 0.1
        
        motionManager.startDeviceMotionUpdatesToQueue(NSOperationQueue.currentQueue()) {
            (deviceMotion, error) -> Void in
            
            let accel = deviceMotion.gravity
            
            let accelX = Float(9.8 * accel.x)
            let accelY = Float(9.8 * accel.y)
            let accelZ = Float(-9.8)
            
            self.scene.physicsWorld.gravity = SCNVector3(x: accelX, y: accelY, z: accelZ)
        }
        
        NSLog("setting up")
        setupWorld()
        NSLog("setting down")
    }
    
    override func viewWillAppear(animated: Bool) {
        let defaults = NSUserDefaults.standardUserDefaults()
        if let steps_today = defaults.stringForKey("stepToday")
        {
            NSLog("today: %@", steps_today)
            let today = steps_today.toInt()!;
            
            self.balls = today / 100
        }
        
        
        self.label_balls.setTitle(NSString(format: "Balls: %d", balls), forState: UIControlState.Normal)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        self.motionManager.startDeviceMotionUpdatesToQueue(NSOperationQueue.currentQueue()) {
            (deviceMotion, error) -> Void in
            
//            NSLog(deviceMotion.attitude.pitch.description)
            if(deviceMotion.attitude.pitch < -0.2) {
                NSLog("direction: %d", self.direction)
                if(self.direction == 0 && self.cameraNode.position.y < 20) {
                    self.cameraNode.position.y = self.cameraNode.position.y + 0.6
                }
                else if(self.direction == 1 && self.cameraNode.position.x < 20) {
                    self.cameraNode.position.x = self.cameraNode.position.x + 0.6
                }
                else if(self.direction == 2 && self.cameraNode.position.y > 0) {
                    self.cameraNode.position.y = self.cameraNode.position.y - 0.6
                }
                else if(self.direction == 3 && self.cameraNode.position.x > 0) {
                    self.cameraNode.position.x = self.cameraNode.position.x - 0.6
                }
                NSLog("x: %f, y: %f, z: %f", self.cameraNode.position.x, self.cameraNode.position.y, self.cameraNode.position.z)
            }
            else if(deviceMotion.attitude.pitch > 1.2) {
                NSLog("direction: %d", self.direction)
                if(self.direction == 0 && self.cameraNode.position.y > 0) {
                    self.cameraNode.position.y = self.cameraNode.position.y - 0.6
                }
                else if(self.direction == 1 && self.cameraNode.position.x > 0) {
                    self.cameraNode.position.x = self.cameraNode.position.x - 0.6
                }
                else if(self.direction == 2 && self.cameraNode.position.y < 20) {
                    self.cameraNode.position.y = self.cameraNode.position.y + 0.6
                }
                else if(self.direction == 3 && self.cameraNode.position.x < 20) {
                    self.cameraNode.position.x = self.cameraNode.position.x + 0.6
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
        scene.physicsWorld

        scene.physicsWorld.speed = 1
        
        //Create the sphere
//        setupSphere()
        
        //Setup camera
        setupCamera()
        
        setupWall()
        
        scnView.backgroundColor = UIColor.blackColor()
        //scnView.allowsCameraControl = true
        
        let southWall = SCNBox(width: 30.0, height: 1.0, length: 30.0, chamferRadius: 0.0)
        southWall.firstMaterial?.diffuse.contents = UIColor.blueColor()
        southNode = SCNNode(geometry: southWall)
        southNode.physicsBody = SCNPhysicsBody.staticBody()
        southNode.position = SCNVector3(x: 10.0, y: -5.0, z: 15.0)
        scene.rootNode.addChildNode(southNode)
        
        let northWall = SCNBox(width: 30.0, height: 1.0, length: 30.0, chamferRadius: 0.0)
        northWall.firstMaterial?.diffuse.contents = UIColor.greenColor()
        northNode = SCNNode(geometry: northWall)
        northNode.physicsBody = SCNPhysicsBody.staticBody()
        northNode.position = SCNVector3(x: 10.0, y: 25.0, z: 15.0)
        scene.rootNode.addChildNode(northNode)
        
        let eastWall = SCNBox(width: 1.0, height: 30.0, length: 30.0, chamferRadius: 0.0)
        eastWall.firstMaterial?.diffuse.contents = UIColor.yellowColor()
        eastNode = SCNNode(geometry: eastWall)
        eastNode.physicsBody = SCNPhysicsBody.staticBody()
        eastNode.position = SCNVector3(x: 25.0, y: 10.0, z: 15.0)
        scene.rootNode.addChildNode(eastNode)
        
        let westWall = SCNBox(width: 1.0, height: 30.0, length: 30.0, chamferRadius: 0.0)
        westWall.firstMaterial?.diffuse.contents = UIColor.orangeColor()
        westNode = SCNNode(geometry: westWall)
        westNode.physicsBody = SCNPhysicsBody.staticBody()
        westNode.position = SCNVector3(x: -5.0, y: 10.0, z: 15.0)
        scene.rootNode.addChildNode(westNode)
        
        let ceilingWall = SCNBox(width: 30.0, height: 30.0, length: 1.0, chamferRadius: 0.0)
        ceilingNode = SCNNode(geometry: ceilingWall)
        ceilingNode.physicsBody = SCNPhysicsBody.staticBody()
        ceilingNode.position = SCNVector3(x: 10.0, y: 10.0, z: 30.0)
        scene.rootNode.addChildNode(ceilingNode)
        
        scnView.scene = self.scene

        scnView.scene = scene
        

    }
    
    func setupSphere() {
        let sphereGeometry = SCNSphere(radius: 1.0)
        sphereGeometry.segmentCount = 128
        
        let sphereNode = SCNNode(geometry: sphereGeometry)
        sphereNode.physicsBody = SCNPhysicsBody.dynamicBody()
        //ball.geometry?.firstMaterial = ballMaterial;
        //sphereNode.physicsBody?.restitution = 2.5
        if var cam = self.cameraNode?.position {
            sphereNode.position = SCNVector3(x: cam.x, y: cam.y, z: 5)
        }
        else {
            sphereNode.position = SCNVector3(x: 15, y: 15, z: 5)
        }
        
        sphereNode.physicsBody?.damping = 0.1
        sphereNode.physicsBody?.rollingFriction = 0.1
        sphereNode.physicsBody?.restitution = 2.0
        sphereNode.name = "ball"
        
        self.scene.rootNode.addChildNode(sphereNode)
        
        self.ballNodes.append(sphereNode)
        
    }
    
    func setupCamera() {
        camera = SCNCamera()
        
        cameraNode = SCNNode()
        cameraNode.camera = camera
        cameraNode.position = SCNVector3(x: 15, y: 15, z: 27)
        //cameraNode.camera?.yFov = 30
        
        NSLog("camera moved")
        
        self.scene.rootNode.addChildNode(cameraNode)
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
        self.scene.rootNode.addChildNode(redNode1)
        
        var redNode2 = SCNNode()
        redNode2.geometry = redTile
        redNode2.physicsBody = SCNPhysicsBody.staticBody()
        redNode2.position = SCNVector3(x: 20.0, y: 0.0, z: 0.0)
        self.scene.rootNode.addChildNode(redNode2)
        
        var redNode3 = SCNNode()
        redNode3.geometry = redTile
        redNode3.physicsBody = SCNPhysicsBody.staticBody()
        redNode3.position = SCNVector3(x: 0.0, y: 20.0, z: 0.0)
        self.scene.rootNode.addChildNode(redNode3)
        
        var redNode4 = SCNNode()
        redNode4.geometry = redTile
        redNode4.physicsBody = SCNPhysicsBody.staticBody()
        redNode4.position = SCNVector3(x: 10.0, y: 10.0, z: 0.0)
        self.scene.rootNode.addChildNode(redNode4)
        
        var redNode5 = SCNNode()
        redNode5.geometry = redTile
        redNode5.physicsBody = SCNPhysicsBody.staticBody()
        redNode5.position = SCNVector3(x: 20.0, y: 20.0, z: 0.0)
        self.scene.rootNode.addChildNode(redNode5)
        
        
        
        var whiteNode1 = SCNNode()
        whiteNode1.geometry = whiteTile
        whiteNode1.physicsBody = SCNPhysicsBody.staticBody()
        whiteNode1.position = SCNVector3(x: 10.0, y: 0.0, z: 0.0)
        self.scene.rootNode.addChildNode(whiteNode1)
        
        var whiteNode2 = SCNNode()
        whiteNode2.geometry = whiteTile
        whiteNode2.physicsBody = SCNPhysicsBody.staticBody()
        whiteNode2.position = SCNVector3(x: 0.0, y: 10.0, z: 0.0)
        self.scene.rootNode.addChildNode(whiteNode2)
        
        var whiteNode3 = SCNNode()
        whiteNode3.geometry = whiteTile
        whiteNode3.physicsBody = SCNPhysicsBody.staticBody()
        whiteNode3.position = SCNVector3(x: 10.0, y: 20.0, z: 0.0)
        self.scene.rootNode.addChildNode(whiteNode3)
        
        var whiteNode4 = SCNNode()
        whiteNode4.geometry = whiteTile
        whiteNode4.physicsBody = SCNPhysicsBody.staticBody()
        whiteNode4.position = SCNVector3(x: 20.0, y: 10.0, z: 0.0)
        self.scene.rootNode.addChildNode(whiteNode4)
        
    }
    
    func handleTap(sender: AnyObject) {
        for ball in self.ballNodes {
            if(self.direction == 0) {
                ball.physicsBody?.applyForce(SCNVector3Make(0, 30, 0), impulse: true)
            }
            else if(self.direction == 1) {
                ball.physicsBody?.applyForce(SCNVector3Make(30, 0, 0), impulse: true)
            }
            else if(self.direction == 2) {
                ball.physicsBody?.applyForce(SCNVector3Make(0, -30, 0), impulse: true)
            }
            else if(self.direction == 3) {
                ball.physicsBody?.applyForce(SCNVector3Make(-30, 0, 0), impulse: true)

            }
            
        }
    }
    
    func handleDoubleTap(sender: AnyObject) {
        NSLog("dbl")
        if(self.balls > 0) {
            setupSphere()
            
            self.balls -= 1
            self.label_balls.setTitle(NSString(format: "Balls: %d", balls), forState: UIControlState.Normal)
        }
        
    }

}
