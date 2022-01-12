//
//  ContentView.swift
//  MrDicey
//
//  Created by MIKE LAND on 1/10/22.
//

import SwiftUI
import SceneKit

struct ContentView: View {
    static func makeScene() -> SCNScene? {
      let scene = SCNScene(named: "MainScene.scn")
      return scene
    }
    var scene = makeScene()

    var body: some View {
        GeometryReader { geo in
            VStack{
                Text("Mr. Dicey")
                    .padding()
                    .frame(width: geo.size.width)
                
                Spacer()
                
                SceneView(
                  // 1
                  scene: scene,
                  // 2
                  pointOfView: setUpCamera(),
                  // 3
                  options: []
                )
                .background(Color.secondary)
                .edgesIgnoringSafeArea(.all)
            }
        }
    }
    
    func setUpCamera() -> SCNNode? {
      let cameraNode = scene?.rootNode
        .childNode(withName: "camera", recursively: false)
      return cameraNode
    }
    
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
