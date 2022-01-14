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
        
        /// Handle PanGesture for rotation and applyForce to dice
        /// - Parameter panGesture: panGesture parameter
        @objc func handlePan(_ panGesture: UIPanGestureRecognizer){
//            let p = panGesture.location(in: view)
//            let hitResults = view.hitTest(p, options: [:])
            
            guard let box = scene?.rootNode.childNode(withName: "dice", recursively: true) else { return }
            let translation = panGesture.translation(in: panGesture.view)
            let location = panGesture.location(in: self.view)
            
            switch panGesture.state {
            case .began:
                scene?.physicsWorld.gravity.y = 0
                guard let hitNodeResult = view.hitTest(location, options: nil).first else { return }
                lastPanLocation = hitNodeResult.worldCoordinates
                panStartZ = CGFloat(view.projectPoint(lastPanLocation).z)
                
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
                let x = Float(translation.x)
                let y = Float(translation.y)
                let anglePan = sqrt(pow(x,2)+pow(y,2))*(Float)(Double.pi)/180.0
                
                var rotationVector = SCNVector4()
                    rotationVector.x = y
                    rotationVector.y = -x
                    rotationVector.z = 0
                    rotationVector.w = anglePan
                
                
                box.rotation = rotationVector
                
            case .ended:
                let worldTouchPosition = view.unprojectPoint(SCNVector3(location.x, location.y, panStartZ))
                let movementVector = SCNVector3(
                    worldTouchPosition.x - lastPanLocation.x,
                    worldTouchPosition.y - lastPanLocation.y,
                    worldTouchPosition.z - lastPanLocation.z)
                box.physicsBody?.applyForce(movementVector, asImpulse: true)
                self.lastPanLocation = worldTouchPosition
                
                scene?.physicsWorld.gravity.y = -1
            default:
                break
            }
        }
    }
}
