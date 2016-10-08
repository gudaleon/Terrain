//
//  GameViewController.swift
//  SceneKitGame
//
//  Created by Vivek Nagar on 9/12/16.
//  Copyright © 2016 Vivek Nagar. All rights reserved.
//

import QuartzCore
import SpriteKit
import SceneKit

#if os(iOS) || os(tvOS)
    typealias ViewController = UIViewController
#elseif os(OSX)
    typealias ViewController = NSViewController
#endif

class GameViewController: ViewController, GameInputDelegate, SCNSceneRendererDelegate {
    let CAMERA_Y_POSITION:SCNFloat = 10.0
    var terrain:TerrainNode!
    var cameraNode:SCNNode!
    var scnView:SCNView?
    var scene:SCNScene!
    internal var controllerStoredDirection = float2(0.0) // left/right up/down
    internal var speed:SCNFloat = 1.0
    
#if os(OSX)
    @IBOutlet weak var gameView: GameView!
    override func awakeFromNib(){
        super.awakeFromNib()
    
        let view = GameSceneView(frame:gameView!.frame)
        view.eventsDelegate = self
        view.delegate = self
        view.translatesAutoresizingMaskIntoConstraints = false
        self.gameView!.addSubview(view)
        self.scnView = view

        // Create a bottom space constraint
        var constraint = NSLayoutConstraint (item: view,
                            attribute: NSLayoutAttribute.bottom,
                            relatedBy: NSLayoutRelation.equal,
                            toItem: self.gameView!,
                            attribute: NSLayoutAttribute.bottom,
                            multiplier: 1,
                            constant: 0)
        self.gameView!.addConstraint(constraint)
    
        // Create a top space constraint
        constraint = NSLayoutConstraint (item: view,
                        attribute: NSLayoutAttribute.top,
                        relatedBy: NSLayoutRelation.equal,
                        toItem: self.gameView!,
                        attribute: NSLayoutAttribute.top,
                        multiplier: 1,
                        constant: 0)
        self.gameView!.addConstraint(constraint)
    
        // Create a right space constraint
        constraint = NSLayoutConstraint (item: view,
                        attribute: NSLayoutAttribute.right,
                        relatedBy: NSLayoutRelation.equal,
                        toItem: self.gameView!,
                        attribute: NSLayoutAttribute.right,
                        multiplier: 1,
                        constant: 0)
        self.gameView!.addConstraint(constraint)
    
        // Create a left space constraint
        constraint = NSLayoutConstraint (item: view,
                        attribute: NSLayoutAttribute.left,
                        relatedBy: NSLayoutRelation.equal,
                        toItem: self.gameView!,
                        attribute: NSLayoutAttribute.left,
                        multiplier: 1,
                        constant: 0)
        self.gameView!.addConstraint(constraint)
    
        self.setupScene()

    }
    
    func handleKeyDown(with event: NSEvent) {
        // Return Key
        if(event.keyCode == 36) {
            self.lookAround()
            return
        }
        if let direction = KeyboardDirection(rawValue: event.keyCode) {
            if !event.isARepeat {
                //print(direction.vector)
                self.controllerStoredDirection += direction.vector
            }
            return
        }
        return
    }
    
    func handleKeyUp(with event: NSEvent) {
        if let direction = KeyboardDirection(rawValue: event.keyCode) {
            if !event.isARepeat {
                //print(direction.vector)
                self.controllerStoredDirection -= direction.vector
            }
            return
        }
        return
    }
    
    internal func handleMouseDown(with theEvent: NSEvent) {
        guard let view = scnView else {
            fatalError("Scene not created")
        }
    
        guard let overlayScene = view.overlaySKScene else {
            print("No overlay scene")
            return
        }
    
        let location:CGPoint = theEvent.location(in: overlayScene)
        let node:SKNode = overlayScene.atPoint(location)
        if let name = node.name { // Check if node name is not nil
            if(name == "cameraNode") {
            self.lookAround()
            }
        }
    }
    
    internal func handleMouseUp(with: NSEvent) {
    }
    
#else
    var touchStartLocation:CGPoint = CGPoint(x:0, y:0)
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.speed = 2.0
        let view = GameSceneView(frame:self.view.frame, options:nil)
        view.eventsDelegate = self
        view.delegate = self
        self.scnView = view
        self.view.addSubview(view)
        
        self.setupScene()
    }
    
    override var shouldAutorotate: Bool {
        return true
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .allButUpsideDown
        } else {
            return .all
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }
    
    func handleTouchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let view = scnView else {
            fatalError("Scene not created")
        }
    
        guard let overlayScene = view.overlaySKScene else {
            print("No overlay scene")
            return
        }

        let touch = touches.first! as UITouch
        touchStartLocation = touch.location(in: overlayScene)
        let node:SKNode = overlayScene.atPoint(touchStartLocation)
        if let name = node.name { // Check if node name is not nil
            if(name == "cameraNode") {
                self.lookAround()
            }
        }
    }
    
    func handleTouchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first! as UITouch
        let location = touch.location(in: scnView)
        
        let moveAmtX = location.x - touchStartLocation.x
        let moveAmtY = location.y - touchStartLocation.y
        var direction = float2(0.0, 0.0)
        if(abs(moveAmtX) > abs(moveAmtY)) {
            //left or right
            if(moveAmtX > 0.0) {
                direction = float2(-1, 0)
            } else {
                direction = float2(1, 0)
            }
        } else {
            //up or down
            if(moveAmtY > 0.0) {
                direction = float2(0, -1)
            } else {
                direction = float2(0, 1)
            }
        }
        self.controllerStoredDirection = direction
        print(self.controllerStoredDirection)
    }
    
    func handleTouchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.resetState()
    }
    
    func handleTouchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.resetState()
    }
    
    private func resetState() {
        touchStartLocation = CGPoint(x:0, y:0)
        self.controllerStoredDirection = float2(0.0, 0.0)
    }

    
#endif
    
    private func setupScene() {
        guard let view = scnView else {
            fatalError("Scene View not set")
        }
        
        // create a new scene
        scene = SCNScene()
        scene.background.contents = "art.scnassets/textures/img_skybox.jpg"
        
        // create and add a camera to the scene
        cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        cameraNode.camera!.zFar = 400
        scene.rootNode.addChildNode(cameraNode!)
        
        // place the camera
        cameraNode.position = SCNVector3(x: 0, y: CAMERA_Y_POSITION, z: 15)
        
        // create and add a light to the scene
        let lightNode = SCNNode()
        lightNode.light = SCNLight()
        lightNode.light!.type = .omni
        lightNode.position = SCNVector3(x: 0, y: 10, z: 10)
        scene.rootNode.addChildNode(lightNode)
        
        // create and add an ambient light to the scene
        let ambientLightNode = SCNNode()
        ambientLightNode.light = SCNLight()
        ambientLightNode.light!.type = .ambient
        ambientLightNode.light!.color = SKColor.darkGray
        scene.rootNode.addChildNode(ambientLightNode)
        
        // set the scene to the view
        view.scene = scene
        
        // allows the user to manipulate the camera
        //view.allowsCameraControl = true
        
        // show statistics such as fps and timing information
        view.showsStatistics = true
        
        // configure the view
        view.backgroundColor = SKColor.black
        
        //add SKScene
        self.createOverlayScene()
        
        //self.addFloor()
        self.addTerrain()
        
        //start animation
        view.play(self)

    }
    
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        let delX = SCNFloat(controllerStoredDirection.x) * speed
        let delZ = SCNFloat(controllerStoredDirection.y) * speed
        if(delX == 0.0 && delZ == 0.0) {
            return
        }
        
        let newCameraPosition = SCNVector3Make(cameraNode.position.x-delX, cameraNode.position.y, cameraNode.position.z-delZ)
        let height = self.getGroundHeight(position:newCameraPosition)
        //print("ground height is \(height)")
        cameraNode.position = SCNVector3Make(newCameraPosition.x, height, newCameraPosition.z)
    }
    
    private func getGroundHeight(position:SCNVector3) -> SCNFloat
    {
        return terrain.getHeight(x:position.x, y:position.z) + CAMERA_Y_POSITION
    }

    
    private func addFloor() {
        let floorNode = SCNNode()
        let floor = SCNFloor()
        floor.reflectionFalloffEnd = 2.0
        floorNode.geometry = floor
        floorNode.geometry?.firstMaterial?.diffuse.contents = "art.scnassets/textures/dirt.jpg"
        //floorNode.geometry?.firstMaterial?.diffuse.contentsTransform = SCNMatrix4MakeScale(2, 2, 1)
        floorNode.geometry?.firstMaterial?.locksAmbientWithDiffuse = true
        floorNode.physicsBody = SCNPhysicsBody.static()
        scene.rootNode.addChildNode(floorNode)
    }

    private func addTerrain() {
        //let terrain = TerrainNode(width: 256, depth:256)
        terrain = TerrainNode(imageName: "heightmap", imageType: "png", inDirectory: "art.scnassets/textures")
        if let imagePath = Bundle.main.path(forResource: "dirt", ofType: "jpg", inDirectory: "art.scnassets/textures")
        {
            let dirt_texture = GameImage(contentsOfFile: imagePath)!
            terrain.create(withTexture:dirt_texture)
        } else {
            terrain.create(withColor: SKColor.green)
        }
        terrain.position = SCNVector3Make(0, 0, 0)
        scene.rootNode.addChildNode(terrain)
    }
    
    private func createOverlayScene() {
        //setup overlay
        let overlayScene = SKScene(size: scnView!.bounds.size);
        scnView!.overlaySKScene = overlayScene;
        let node = SKSpriteNode(imageNamed:"art.scnassets/textures/video_camera.png")
        node.position = CGPoint(x: overlayScene.size.width * 0.85, y: overlayScene.size.height*0.85)
        node.name = "cameraNode"
        node.xScale = 0.4
        node.yScale = 0.4
        overlayScene.addChild(node)
        //overlayScene.cameraButtonHandler = lookAround
    }
    
    private func lookAround() {
        cameraNode.eulerAngles = SCNVector3(x: 0, y:0, z: 0)
        SCNTransaction.begin()
        SCNTransaction.animationDuration = 10.0
        cameraNode.eulerAngles = SCNVector3(x: 0, y: SCNFloat(M_PI*2.0), z: 0)
        SCNTransaction.commit()
    }

}
