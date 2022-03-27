//
//  ContentView.swift
//  MrDicey
//
//  Created by MIKE LAND on 1/10/22.
//

import SwiftUI
import SceneKit

struct ContentView: View {
    @State var message: String
    @State var color: Color
    
    let scene = SCNScene(named: "MainScene.scn")

    var body: some View {
        VStack{
            Text("Mr. Dicey")
                .font(.headline)
                .padding()
            
            ZStack {
                SceneView(message: $message, color: $color, scene: scene)
                VStack{
                    if !message.isEmpty {
                        Text(message)
                            .font(.title3)
                            .foregroundColor(color)
                            .padding()
                            .background(Color.white)
                            .clipShape(Capsule())
                            .padding(50)
                    }
                    Spacer()
                }
            }
        }
    }
}
