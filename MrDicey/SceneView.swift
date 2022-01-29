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
        view.autoenablesDefaultLighting = true
        
        // Getting nodes from MainScene.scn
        let box1 = scene?.rootNode.childNode(withName: "box1", recursively: true)
        let box2 = scene?.rootNode.childNode(withName: "box2", recursively: true)
        
        // Create and configure a material for each face
        let diceFaces = ["die3", "die6", "die4", "die1", "die5", "die2"]
        var materials: [SCNMaterial] = Array()

        for index in 0...5 {
            let material = SCNMaterial()
            material.diffuse.contents = UIImage(named: diceFaces[index])
            materials.append(material)
        }

        // Set the material to the 3D object geometry
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
            guard let light = scene?.rootNode.childNode(withName: "light", recursively: true) else { return }
            
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
                
                // A small animation of taking dice from a resting place
                if isDiceHitten {
                    box1.runAction(SCNAction.scale(to: 0.9, duration: 0.2))
                    box2.runAction(SCNAction.scale(to: 0.9, duration: 0.2))
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                        box1.runAction(SCNAction.scale(to: 1.1, duration: 0.1))
                        box2.runAction(SCNAction.scale(to: 1.1, duration: 0.1))
                    }
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        box1.runAction(SCNAction.scale(to: 1, duration: 0.1))
                        box2.runAction(SCNAction.scale(to: 1, duration: 0.1))
                    }
                }
                
            case .changed:
                //Moving the dice behind the finger
                if isDiceHitten {
                    let worldTouchPosition = view.unprojectPoint(SCNVector3(location.x, location.y, panStartZ))
                    let movementVector = SCNVector3(
                        worldTouchPosition.x - lastPanLocation.x,
                        worldTouchPosition.y - lastPanLocation.y,
                        worldTouchPosition.z - lastPanLocation.z)
                    
                    box1.runAction(SCNAction.move(by: movementVector, duration: 0))
                    box2.runAction(SCNAction.move(by: movementVector, duration: 0))
                    
                    self.lastPanLocation = worldTouchPosition
                    
                    if lastPanLocation.x > 4.0 {
                        light.light?.color = UIColor.green
                    } else {
                        light.light?.color = UIColor.white
                    }
                }
                
            case .ended:
                if isDiceHitten {
                    scene?.physicsWorld.gravity.y = -1
                    
                    // Roll the dice to the right side of the screen
                    if lastPanLocation.x > 4.0 {
                        let movementVector = SCNVector3(
                            lastPanLocation.x,
                            0,
                            lastPanLocation.z)
                        
                        box1.physicsBody?.applyForce(movementVector, asImpulse: true)
                        box2.physicsBody?.applyForce(movementVector, asImpulse: true)
                        
                        isRollValid = true
                    }
                    
                    //Determining the correct roll of the dice
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
            guard let light = scene?.rootNode.childNode(withName: "light", recursively: true) else { return }
          
            if isRollValid {
                // create and configure a material for each face
                var twoDiceMaterials: [[SCNMaterial]] = Array()

                for _ in 0...1 {
                    var materials: [SCNMaterial] = Array()
                    var diceFaces = ["die3", "die6", "die4", "die1", "die5", "die2"]
                    var diceShuffled: [String] = Array()
                    diceFaces = diceFaces.shuffled()
                    
                    // Setting the correct sequence of dice faces
                    for index in 0...5 {
                        if index == 1 {
                            let element = diceFaces.remove(at: diceFaces.firstIndex(where: {
                                Int(String($0.last!))! + Int(String(diceShuffled[0].last!))! != 7
                            })!)
                            diceShuffled.append(element)
                        } else if index == 2 {
                            let element = diceFaces.remove(at: diceFaces.firstIndex(where: {
                                Int(String($0.last!))! + Int(String(diceShuffled[0].last!))! == 7
                            })!)
                            diceShuffled.append(element)
                        } else if index == 3 {
                            let element = diceFaces.remove(at: diceFaces.firstIndex(where: {
                                Int(String($0.last!))! + Int(String(diceShuffled[1].last!))! == 7
                            })!)
                            diceShuffled.append(element)
                        } else {
                            let element = diceFaces.removeFirst()
                            diceShuffled.append(element)
                        }
                    }
                    
                    //Filling faces in materials array
                    for index in 0...5 {
                        let material = SCNMaterial()
                        material.diffuse.contents = UIImage(named: diceShuffled[index])
                        materials.append(material)
                        if index == 4 {
                            print(diceShuffled[index])
                        }
                    }
                    
                    twoDiceMaterials.append(materials)
                    print(diceShuffled)
                }

                // set the material to the 3d object geometry
                box1.geometry?.materials = twoDiceMaterials[0]
                box2.geometry?.materials = twoDiceMaterials[1]
            }
            
            box1.runAction(SCNAction.move(to: positionDice1, duration: durationOfReturn))
            box2.runAction(SCNAction.move(to: positionDice2, duration: durationOfReturn))
            
            box1.physicsBody?.clearAllForces()
            box2.physicsBody?.clearAllForces()
            
            isDiceHitten = false
            isRollValid = false
            light.light?.color = UIColor.white
        }
    }
}
