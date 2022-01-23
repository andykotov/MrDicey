//
//  SceneView.swift
//  MrDicey
//
//  Created by mr. Hakoda on 13.01.2022.
//

import SwiftUI
import SceneKit

enum CollisionTypes: Int {
    case dices = 1
    case wall = 2
    case floor = 4
}

struct SceneView: UIViewRepresentable {
    var scene: SCNScene?
    var options: [Any]
    
    var view = SCNView()
    
    func makeUIView(context: Context) -> SCNView {
        // Instantiate the SCNView and setup the scene
        view.scene = scene
        view.pointOfView = scene?.rootNode.childNode(withName: "camera", recursively: true)
        
        // Getting nodes from MainScene.scn
        let box1 = scene?.rootNode.childNode(withName: "box1", recursively: true)
        let box2 = scene?.rootNode.childNode(withName: "box2", recursively: true)
        let wall = scene?.rootNode.childNode(withName: "wall", recursively: true)
        let floor = scene?.rootNode.childNode(withName: "floor", recursively: true)
        
        // Create and configure a material for each face
        let diceFaces = ["die1", "die2", "die3", "die4", "die5", "die6"]
        var materials: [SCNMaterial] = Array()

        for index in 0...5 {
            let material = SCNMaterial()
            material.diffuse.contents = UIImage(named: diceFaces[index])
            materials.append(material)
        }

        // Set the material to the 3D object geometry
        box1?.geometry?.materials = materials
        box2?.geometry?.materials = materials
        
        // Contact setup
        box1?.physicsBody?.categoryBitMask = CollisionTypes.dices.rawValue
        box1?.physicsBody?.contactTestBitMask = CollisionTypes.wall.rawValue | CollisionTypes.floor.rawValue
        box2?.physicsBody?.categoryBitMask = CollisionTypes.dices.rawValue
        box2?.physicsBody?.contactTestBitMask = CollisionTypes.wall.rawValue | CollisionTypes.floor.rawValue
        wall?.physicsBody?.categoryBitMask = CollisionTypes.wall.rawValue
        wall?.physicsBody?.contactTestBitMask = CollisionTypes.dices.rawValue
        floor?.physicsBody?.categoryBitMask = CollisionTypes.floor.rawValue
        floor?.physicsBody?.contactTestBitMask = CollisionTypes.dices.rawValue
        
        // Add gesture recognizer
        let panGesture = UIPanGestureRecognizer(target: context.coordinator, action: #selector(context.coordinator.handlePan(_:)))
        view.addGestureRecognizer(panGesture)
        
        // A delegate that is called when two physics bodies come in contact with each other
        view.scene?.physicsWorld.contactDelegate = context.coordinator
        
        return view
    }
    
    func updateUIView(_ view: SCNView, context: Context) {
        //
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(view, scene: scene)
    }
    
    class Coordinator: NSObject, SCNPhysicsContactDelegate {
        private let view: SCNView
        private let scene: SCNScene?
        
        init(_ view: SCNView, scene: SCNScene?) {
            self.view = view
            self.scene = scene
            super.init()
        }
        
        let angles: [CGFloat] = [0, 90, 180, 270]
        var panStartZ = CGFloat()
        var lastPanLocation = SCNVector3()
        var positionDice1 = SCNVector3(x: -4, y: 7, z: 7.4)
        var positionDice2 = SCNVector3(x: -2, y: 7, z: 7.4)
        var durationOfReturn = Double()
        var isDiceHitten = Bool()
        var isRollValid = Bool()
        
        /// Handle PanGesture for localTranslate and applyForce to dice
        /// - Parameter panGesture: A discrete gesture recognizer that interprets panning gestures.
        @objc func handlePan(_ panGesture: UIPanGestureRecognizer){
            // Getting nodes from MainScene.scn
            guard let box1 = scene?.rootNode.childNode(withName: "box1", recursively: true) else { return }
            guard let box2 = scene?.rootNode.childNode(withName: "box2", recursively: true) else { return }
            guard let camera = scene?.rootNode.childNode(withName: "camera", recursively: true) else { return }
            
            let location = panGesture.location(in: self.view)
            guard let hitNodeResult = view.hitTest(location, options: nil).first else { return }
            
            switch panGesture.state {
            case .began:
                scene?.physicsWorld.gravity.y = 0
                
                isRollValid = false
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
            case .changed:
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
                if isDiceHitten {
                    scene?.physicsWorld.gravity.y = -1
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                        if self.view.nodesInsideFrustum(of: camera).map({ $0.name == "box1" || $0.name == "box2" }).contains(true) {
                            print("Invalid Roll, No Roll")
                            self.durationOfReturn = 1.0
                        } else {
                            if self.isRollValid {
                                print("We have a valid roll")
                            } else {
                                print("Invalid Roll, No Roll")
                            }
                            self.durationOfReturn = 2.0
                        }
                        self.returnDice()
                    }
                }
            default:
                break
            }
        }
        /// Return of the dice to their place of rest with SCNAction
        func returnDice() {
            scene?.physicsWorld.gravity.y = 0
            
            guard let box1 = scene?.rootNode.childNode(withName: "box1", recursively: true) else { return }
            guard let box2 = scene?.rootNode.childNode(withName: "box2", recursively: true) else { return }
          
            if isRollValid {
                // create and configure a material for each face
                var diceFaces = ["die1", "die2", "die3", "die4", "die5", "die6"]
                
                var materialsArray: [[SCNMaterial]] = Array()

                for _ in 0...1 {
                    var materials: [SCNMaterial] = Array()
                    diceFaces = diceFaces.shuffled()
                    for index in 0...5 {
                        let material = SCNMaterial()
                        material.diffuse.contents = UIImage(named: diceFaces[index])
                        materials.append(material)
                        if index == 4 {
                            print(diceFaces[index])
                        }
                    }
                    materialsArray.append(materials)
                }

                // set the material to the 3d object geometry
                box1.geometry?.materials = materialsArray[0]
                box2.geometry?.materials = materialsArray[1]
            }
            
            box1.runAction(SCNAction.move(to: positionDice1, duration: durationOfReturn))
            box2.runAction(SCNAction.move(to: positionDice2, duration: durationOfReturn))
            
            box1.physicsBody?.clearAllForces()
            box2.physicsBody?.clearAllForces()
            
            isDiceHitten = false
            isRollValid = false
        }
        
        /// Tells the delegate that two bodies have come into contact.
        /// - Parameters:
        ///   - world: The global simulation of collisions, gravity, joints, and other physics effects in a scene.
        ///   - contact: Detailed information about a contact between two physics bodies in a scene’s physics simulation.
        func physicsWorld(_ world: SCNPhysicsWorld, didBegin contact: SCNPhysicsContact) {
            if contact.nodeA.physicsBody?.categoryBitMask == CollisionTypes.wall.rawValue && contact.nodeB.physicsBody?.categoryBitMask == CollisionTypes.dices.rawValue {
                isRollValid = true
            }
        }
    }
}
