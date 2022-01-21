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
        
        // create and configure a material for each face
        let box1 = scene?.rootNode.childNode(withName: "box1", recursively: true)
        let box2 = scene?.rootNode.childNode(withName: "box2", recursively: true)
        
        let diceFaces = ["die1", "die2", "die3", "die4", "die5", "die6"]
        var materials: [SCNMaterial] = Array()

        for index in 0...5 {
            let material = SCNMaterial()
            material.diffuse.contents = UIImage(named: diceFaces[index])
            materials.append(material)
        }

        // set the material to the 3d object geometry
        box1?.geometry?.materials = materials
        box2?.geometry?.materials = materials
        
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
        var isDiceHitten = Bool()
        
        /// Handle PanGesture for rotation and applyForce to dice
        /// - Parameter panGesture: panGesture parameter
        @objc func handlePan(_ panGesture: UIPanGestureRecognizer){
//            let p = panGesture.location(in: view)
//            let hitResults = view.hitTest(p, options: [:])
            
            guard let box1 = scene?.rootNode.childNode(withName: "box1", recursively: true) else { return }
            guard let box2 = scene?.rootNode.childNode(withName: "box2", recursively: true) else { return }
            guard let camera = scene?.rootNode.childNode(withName: "camera", recursively: true) else { return }
            
//            let translation = panGesture.translation(in: panGesture.view)
            let location = panGesture.location(in: self.view)
            
            switch panGesture.state {
            case .began:
                scene?.physicsWorld.gravity.y = 0
                guard let hitNodeResult = view.hitTest(location, options: nil).first else { return }
                lastPanLocation = hitNodeResult.worldCoordinates
                panStartZ = CGFloat(view.projectPoint(lastPanLocation).z)
                
                
                if hitNodeResult.node.name == "box1" || hitNodeResult.node.name == "box2" {
                    isDiceHitten = true
                }
                
                if isDiceHitten {
                    let worldTouchPosition = view.unprojectPoint(SCNVector3(location.x, location.y, panStartZ))
                    let movementVector = SCNVector3(
                        worldTouchPosition.x - lastPanLocation.x,
                        worldTouchPosition.y - lastPanLocation.y,
                        worldTouchPosition.z - lastPanLocation.z)
                    box1.localTranslate(by: movementVector)
                    box2.localTranslate(by: movementVector)
                    self.lastPanLocation = worldTouchPosition
                }
//                print(view.isNode(box1, insideFrustumOf: camera))
                
//                if hitNodeResult.node.name == "dice" {
//                    box = hitNodeResult.node ?? SCNNode()
//                }
            case .changed:
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
                if isDiceHitten {
                    let worldTouchPosition = view.unprojectPoint(SCNVector3(location.x, location.y, panStartZ))
                    let movementVector = SCNVector3(
                        worldTouchPosition.x - lastPanLocation.x,
                        worldTouchPosition.y - lastPanLocation.y,
                        worldTouchPosition.z - lastPanLocation.z)
                    box1.physicsBody?.applyForce(movementVector, asImpulse: true)
                    box2.physicsBody?.applyForce(movementVector, asImpulse: true)
                    self.lastPanLocation = worldTouchPosition
                }
                
            case .ended:
//                let dicePosition = SCNVector3(
//                    box1.worldPosition.x,
//                    30,
//                    box1.worldPosition.z)
//                let euler = SCNVector3(
//                    -90,
//                    0,
//                    0)
//
//                let constraint = SCNLookAtConstraint(target: box1)
//                camera.constraints = [constraint]
//                camera.eulerAngles = euler
//
//                let move = SCNAction.move(to: dicePosition, duration: 1.0)
//                camera.runAction(move)
//                camera.localTranslate(by: dicePosition)
                
                if isDiceHitten {
                    scene?.physicsWorld.gravity.y = -1
                    
//                    let constraint = SCNLookAtConstraint(target: box1)
//                     camera.constraints = [constraint]
//                     // 3
//                     let dicePosition = box1
//                        .convertPosition(SCNVector3(x: box1.worldPosition.x, y: 30, z: box1.worldPosition.z), to: nil)
//                     // 4
//                    let move = SCNAction.move(to: dicePosition, duration: 1.0)
//                    camera.runAction(move)
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                        if self.view.nodesInsideFrustum(of: camera).map({ $0.name == "box1" || $0.name == "box2" }).contains(true) {
                            print("Invalid Roll, No Roll")
                            self.durationOfReturn = 1.0
                        } else {
                            print("We have a valid roll")
                            self.durationOfReturn = 2.0
                        }
                        self.returnDice()
                    }
                }
            default:
                break
            }
        }
        
        func returnDice() {
            scene?.physicsWorld.gravity.y = 0
            
            guard let box1 = scene?.rootNode.childNode(withName: "box1", recursively: true) else { return }
            guard let box2 = scene?.rootNode.childNode(withName: "box2", recursively: true) else { return }
            
//            let globalPosition = box1.convertPosition(positionDice1, to: nil)
              // 4
            box1.runAction(SCNAction.move(to: positionDice1, duration: durationOfReturn))
            box2.runAction(SCNAction.move(to: positionDice2, duration: durationOfReturn))
            box1.physicsBody?.clearAllForces()
            box2.physicsBody?.clearAllForces()
            isDiceHitten = false
        }
    }
}
