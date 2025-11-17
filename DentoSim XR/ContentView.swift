//
//  ContentView.swift
//  DentoSim XR
//
//  Created by Michal Fereniec on 17/11/2025.
//

import SwiftUI
import RealityKit

struct ContentView: View {

    var body: some View {
        VStack {
            ToggleImmersiveSpaceButton()
        }
    }
}

#Preview(windowStyle: .automatic) {
    ContentView()
        .environment(AppModel())
}
