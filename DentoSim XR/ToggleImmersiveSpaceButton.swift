//
//  ToggleImmersiveSpaceButton.swift
//  DentoSim XR
//
//  Created by Michal Fereniec on 17/11/2025.
//

import SwiftUI

struct ToggleImmersiveSpaceButton: View {
    @Environment(AppModel.self) private var appModel
    @Environment(\.dismissImmersiveSpace) private var dismissImmersiveSpace
    @Environment(\.openImmersiveSpace) private var openImmersiveSpace
    
    let module: ProcedureModule?
    
    init(module: ProcedureModule? = nil) {
        self.module = module
    }
    
    var body: some View {
        Button {
            Task { @MainActor in
                switch appModel.immersiveSpaceState {
                case .open:
                    appModel.immersiveSpaceState = .inTransition
                    await dismissImmersiveSpace()
                    
                case .closed:
                    if let module = module {
                        appModel.startProcedure(module)
                    }
                    
                    appModel.immersiveSpaceState = .inTransition
                    switch await openImmersiveSpace(id: appModel.immersiveSpaceID) {
                    case .opened:
                        break
                        
                    case .userCancelled, .error:
                        fallthrough
                    @unknown default:
                        appModel.immersiveSpaceState = .closed
                    }
                    
                case .inTransition:
                    break
                }
            }
        } label: {
            HStack {
                Image(systemName: appModel.immersiveSpaceState == .open ? "xmark.circle.fill" : (module != nil ? "play.circle.fill" : "eye.circle.fill"))
                    .font(.title2)
                Text(appModel.immersiveSpaceState == .open ? "Exit Simulation" : (module != nil ? "Start Training" : "Explore 3D View"))
                    .font(.title3)
                    .fontWeight(.semibold)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(appModel.immersiveSpaceState == .open ? Color.red.gradient : (module != nil ? Color.blue.gradient : Color.green.gradient))
            .foregroundStyle(.white)
            .clipShape(RoundedRectangle(cornerRadius: 15))
        }
        .buttonStyle(.plain)
        .disabled(appModel.immersiveSpaceState == .inTransition)
    }
}