//
//  GameSceneView.swift
//  FPShooter
//
//  Created by Vivek Nagar on 7/28/16.
//  Copyright © 2016 Vivek Nagar. All rights reserved.
//

import SceneKit
import SpriteKit

protocol GameInputDelegate {
#if os(iOS)
    func handleTouchesBegan(_ touches: Set<UITouch>, with event: UIEvent?)
    func handleTouchesMoved(_ touches: Set<UITouch>, with event: UIEvent?)
    func handleTouchesEnded(_ touches: Set<UITouch>, with event: UIEvent?)
#elseif os(OSX)
    func handleMouseDown(with: NSEvent)
    func handleMouseUp(with: NSEvent)
    func handleKeyDown(with: NSEvent)
    func handleKeyUp(with: NSEvent)
#endif
}

class GameSceneView : SCNView {
    var eventsDelegate: GameInputDelegate?
    
#if os(iOS)
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setup2DOverlay()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
    
    override init(frame: CGRect, options: [String : Any]?) {
        super.init(frame:frame, options:options)
        setup2DOverlay()
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let eventsDelegate = eventsDelegate else {
            super.touchesBegan(touches as Set<UITouch>, with:event)
            return
        }
        eventsDelegate.handleTouchesBegan(touches as Set<UITouch>, with:event)
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let eventsDelegate = eventsDelegate else {
            super.touchesMoved(touches as Set<UITouch>, with:event)
            return
        }
        eventsDelegate.handleTouchesMoved(touches as Set<UITouch>, with:event)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let eventsDelegate = eventsDelegate else {
            super.touchesEnded(touches as Set<UITouch>, with:event)
            return
        }
        eventsDelegate.handleTouchesEnded(touches as Set<UITouch>, with:event)
    }

#elseif os(OSX)
    
    override func viewDidMoveToWindow() {
        super.viewDidMoveToWindow()
        setup2DOverlay()
    }
    
    override func setFrameSize(_ newSize: NSSize) {
        super.setFrameSize(newSize)
    }
    
    override func mouseDown(with event: NSEvent) {
        guard let eventsDelegate = eventsDelegate else {
            super.mouseDown(with: event)
            return
        }
        eventsDelegate.handleMouseDown(with: event)
    }
    
    override func mouseUp(with event: NSEvent) {
        guard let eventsDelegate = eventsDelegate else {
            super.mouseUp(with: event)
            return
        }
        eventsDelegate.handleMouseUp(with: event)
    }
    
    override func keyDown(with event: NSEvent) {
        guard let eventsDelegate = eventsDelegate else {
            super.keyDown(with: event)
            return
        }
        eventsDelegate.handleKeyDown(with: event)
    }
    
    override func keyUp(with event: NSEvent) {
        guard let eventsDelegate = eventsDelegate else {
            super.keyUp(with: event)
            return
        }
        eventsDelegate.handleKeyUp(with: event)
    }

#endif
    
    private func setup2DOverlay() {
        // Setup the game overlays using SpriteKit.
        let skScene = SKScene(size: CGSize(width: bounds.size.width, height: bounds.size.height))
        skScene.scaleMode = SKSceneScaleMode.resizeFill
        
        // Assign the SpriteKit overlay to the SceneKit view.
        overlaySKScene = skScene
        
        self.debugOptions = SCNDebugOptions.showPhysicsShapes
        //self.debugOptions = SCNDebugOptions.showWireframe
        // allows the user to manipulate the camera
        //self.allowsCameraControl = true
        
        // show statistics such as fps and timing information
        self.showsStatistics = true
        
        // configure the view
        self.backgroundColor = SKColor.black

    }
    
}

