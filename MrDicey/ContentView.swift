//
//  ContentView.swift
//  MrDicey
//
//  Created by MIKE LAND on 1/10/22.
//

import SwiftUI

struct ContentView: View {
    @State var diceActual = Image("diceRoll5-6")
    @State private var dragOffset = CGSize.zero

    var body: some View {
        GeometryReader { metrics in
            VStack(content: {
                Text("Mr. Dicey")
                    .padding()
                    .frame(width: metrics.size.width)
                
                Spacer()
                
                diceActual
                    .resizable()
                    .scaledToFit()
                    .offset(dragOffset)
                    .gesture(
                        DragGesture()
                            .onChanged { gesture in
                                dragOffset = gesture.translation
                            }
                            .onEnded { gesture in
                                dragOffset = .zero
                            }
                    )
                    .frame(width: metrics.size.width * 0.25)

                Spacer()
            })
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
