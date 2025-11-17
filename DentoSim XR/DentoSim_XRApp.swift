//
//  DentoSim_XRApp.swift
//  DentoSim XR
//
//  Created by Michal Fereniec on 17/11/2025.
//

import SwiftUI

@main
struct DentoSim_XRApp: App {
    @State private var appModel = AppModel()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(appModel)
        }
        .windowStyle(.automatic)
        
        ImmersiveSpace(id: appModel.immersiveSpaceID) {
            ImmersiveView()
                .environment(appModel)
                .onAppear {
                    appModel.immersiveSpaceState = .open
                }
                .onDisappear {
                    appModel.immersiveSpaceState = .closed
                }
        }
        .immersionStyle(selection: .constant(.full), in: .full)
    }
}