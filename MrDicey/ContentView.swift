//
//  ContentView.swift
//  MrDicey
//
//  Created by MIKE LAND on 1/10/22.
//

import SwiftUI
import SceneKit

struct ContentView: View {
    let scene = SCNScene(named: "MainScene.scn")

    var body: some View {
        VStack{
            Text("Mr. Dicey")
                .padding()
            
            Spacer()
            
            SceneView(scene: scene, options: [])
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
