//
//  SceneView.swift
//  MrDicey
//
//  Created by mr. Hakoda on 13.01.2022.
//

import SwiftUI
import SceneKit
struct SceneView: UIViewRepresentable {
    
    var scene: SCNScene?
    var options: [Any]
    
    var view = SCNView()
    
    func makeUIView(context: Context) -> SCNView {
        
        // Instantiate the SCNView and setup the scene
        view.scene = scene
        view.pointOfView = scene?.rootNode.childNode(withName: "camera", recursively: true)
//        view.showsStatistics = true
//        view.allowsCameraControl = true
        
        // Add gesture recognizer
        let panGesture = UIPanGestureRecognizer(target: context.coordinator, action: #selector(context.coordinator.handlePan(_:)))
        view.addGestureRecognizer(panGesture)
        
        return view
    }
    
    func updateUIView(_ view: SCNView, context: Context) {
        //
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(view, scene: scene)
    }
    
    class Coordinator: NSObject {
        private let view: SCNView
        private let scene: SCNScene?
        
        init(_ view: SCNView, scene: SCNScene?) {
            self.view = view
            self.scene = scene
            super.init()
        }
        
        var panStartZ = CGFloat()
        var lastPanLocation = SCNVector3()
        
        var positionDice1 = SCNVector3(x: -4, y: 7, z: 7.4)
        var positionDice2 = SCNVector3(x: -1.5, y: 7, z: 7.4)
        var durationOfReturn = Double()
        
        /// Handle PanGesture for rotation and applyForce to dice
        /// - Parameter panGesture: panGesture parameter
        @objc func handlePan(_ panGesture: UIPanGestureRecognizer){
//            let p = panGesture.location(in: view)
//            let hitResults = view.hitTest(p, options: [:])
            
            guard let dice1 = scene?.rootNode.childNode(withName: "dice1", recursively: true) else { return }
            guard let dice2 = scene?.rootNode.childNode(withName: "dice2", recursively: true) else { return }
            guard let camera = scene?.rootNode.childNode(withName: "camera", recursively: true) else { return }
            
//            let translation = panGesture.translation(in: panGesture.view)
            let location = panGesture.location(in: self.view)
            
            switch panGesture.state {
            case .began:
                scene?.physicsWorld.gravity.y = 0
                guard let hitNodeResult = view.hitTest(location, options: nil).first else { return }
                lastPanLocation = hitNodeResult.worldCoordinates
                panStartZ = CGFloat(view.projectPoint(lastPanLocation).z)
                
                let worldTouchPosition = view.unprojectPoint(SCNVector3(location.x, location.y, panStartZ))
                let movementVector = SCNVector3(
                    worldTouchPosition.x - lastPanLocation.x,
                    worldTouchPosition.y - lastPanLocation.y,
                    worldTouchPosition.z - lastPanLocation.z)
                dice1.localTranslate(by: movementVector)
                dice2.localTranslate(by: movementVector)
                self.lastPanLocation = worldTouchPosition
//                print(view.isNode(dice1, insideFrustumOf: camera))
                
//                if hitNodeResult.node.name == "dice" {
//                    box = hitNodeResult.node ?? SCNNode()
//                }
            case .changed:
//                print(view.isNode(dice1, insideFrustumOf: camera))
//                let currentPivot = box.pivot
//                let currentPosition = box.position
//                let changePivot = SCNMatrix4Invert(SCNMatrix4MakeRotation(box.rotation.w, box.rotation.x, box.rotation.y, box.rotation.z))
                
//                print(currentPivot)
//                print(currentPosition)

//                box.pivot = SCNMatrix4Mult(changePivot, currentPivot)
//                box.transform = SCNMatrix4Identity
//                box.position = currentPosition
//                let x = Float(translation.x)
//                let y = Float(translation.y)
//                let anglePan = sqrt(pow(x,2)+pow(y,2))*(Float)(Double.pi)/180.0
//
//                var rotationVector = SCNVector4()
//                    rotationVector.x = y
//                    rotationVector.y = -x
//                    rotationVector.z = 0
//                    rotationVector.w = anglePan
//
//
//                box.rotation = rotationVector
                let worldTouchPosition = view.unprojectPoint(SCNVector3(location.x, location.y, panStartZ))
                let movementVector = SCNVector3(
                    worldTouchPosition.x - lastPanLocation.x,
                    worldTouchPosition.y - lastPanLocation.y,
                    worldTouchPosition.z - lastPanLocation.z)
                dice1.physicsBody?.applyForce(movementVector, asImpulse: true)
                dice2.physicsBody?.applyForce(movementVector, asImpulse: true)
                self.lastPanLocation = worldTouchPosition
                
            case .ended:
//                let dicePosition = SCNVector3(
//                    dice1.worldPosition.x,
//                    30,
//                    dice1.worldPosition.z)
//                let euler = SCNVector3(
//                    -90,
//                    0,
//                    0)
//
//                let constraint = SCNLookAtConstraint(target: dice1)
//                camera.constraints = [constraint]
//                camera.eulerAngles = euler
//
//                let move = SCNAction.move(to: dicePosition, duration: 1.0)
//                camera.runAction(move)
//                camera.localTranslate(by: dicePosition)
                
                scene?.physicsWorld.gravity.y = -1
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                    if self.view.nodesInsideFrustum(of: camera).map({ $0.name == "dice1" || $0.name == "dice2" }).contains(true) {
                        print("Invalid Roll, No Roll")
                        self.durationOfReturn = 1.0
                    } else {
                        print("We have a valid roll")
                        self.durationOfReturn = 1.5
                    }
                    self.returnDice()
                }
            default:
                break
            }
        }
        
        func returnDice() {
            scene?.physicsWorld.gravity.y = 0
            
            guard let dice1 = scene?.rootNode.childNode(withName: "dice1", recursively: true) else { return }
            guard let dice2 = scene?.rootNode.childNode(withName: "dice2", recursively: true) else { return }
            
//            let globalPosition = dice1.convertPosition(positionDice1, to: nil)
              // 4
            dice1.runAction(SCNAction.move(to: positionDice1, duration: durationOfReturn))
            dice2.runAction(SCNAction.move(to: positionDice2, duration: durationOfReturn))
            dice1.physicsBody?.clearAllForces()
            dice2.physicsBody?.clearAllForces()
        }
    }
}
