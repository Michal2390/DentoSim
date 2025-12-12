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
    @State private var aiManager: AIManager
    
    init() {
        let service = OpenAIService(apiKey: APIConfiguration.openAIKey)
        _aiManager = State(initialValue: AIManager(service: service))
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(appModel)
                .environment(aiManager)
                .onAppear {
                    aiManager.initializeSystemMessage(for: appModel.sessionData.currentModule)
                }
        }
        .windowStyle(.automatic)
        
        ImmersiveSpace(id: appModel.immersiveSpaceID) {
            ImmersiveView()
                .environment(appModel)
                .environment(aiManager)
                .onAppear {
                    appModel.immersiveSpaceState = .open
                    aiManager.initializeSystemMessage(for: appModel.sessionData.currentModule)
                }
                .onDisappear {
                    appModel.immersiveSpaceState = .closed
                }
        }
        .immersionStyle(selection: .constant(.full), in: .full)
    }
}