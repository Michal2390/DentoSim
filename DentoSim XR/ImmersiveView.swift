//
//  ImmersiveView.swift
//  DentoSim XR
//
//  Created by Michal Fereniec on 17/11/2025.
//

import SwiftUI
import RealityKit
import RealityKitContent
import UIKit

struct ImmersiveView: View {
    @Environment(AppModel.self) var appModel
    @State private var teethEntities: [Int: ToothEntity] = [:]
    
    var body: some View {
        RealityView { content in
            if let immersiveContentEntity = try? await Entity(named: "Immersive", in: realityKitContentBundle) {
                content.add(immersiveContentEntity)
            }
            
            let jawEntity = await createJawModel()
            jawEntity.position = [0, 0.8, -1.8]
            content.add(jawEntity)
            
        } update: { content in
            updateToothHighlights()
        }
        .gesture(
            SpatialTapGesture()
                .targetedToAnyEntity()
                .onEnded { value in
                    handleTap(on: value.entity)
                }
        )
        .overlay(alignment: .leading) {
            SessionInfoPanel()
                .padding(.leading, 60)
        }
        .overlay(alignment: .trailing) {
            if appModel.showInstructions {
                InstructionOverlay()
                    .padding(.trailing, 60)
            }
        }
        .overlay(alignment: .bottom) {
            ToolPalette()
        }
    }
    
    private func createJawModel() async -> Entity {
        let jawParent = Entity()
        jawParent.name = "JawModel"
        
        let upperJaw = await createArchEntity(isUpper: true)
        let lowerJaw = await createArchEntity(isUpper: false)
        
        jawParent.addChild(upperJaw)
        jawParent.addChild(lowerJaw)
        
        // Position jaw at eye level, in front of user
        jawParent.position = [0, 1.5, -0.8] // Higher Y (eye level), closer Z
        
        return jawParent
    }
    
    private func createArchEntity(isUpper: Bool) async -> Entity {
        let arch = Entity()
        arch.name = isUpper ? "UpperArch" : "LowerArch"
        
        // Realistic vertical separation between upper and lower jaws
        // In normal occlusion, teeth are ~2-3mm apart
        let yOffset: Float = isUpper ? 0.025 : -0.025
        arch.position = [0, yOffset, 0]
        
        let toothNumbers = isUpper ? Array(1...16) : Array(17...32)
        
        for toothNumber in toothNumbers {
            let tooth = await createToothEntity(number: toothNumber, isUpper: isUpper)
            arch.addChild(tooth)
            teethEntities[toothNumber] = tooth
        }
        
        return arch
    }
    
    private func createToothEntity(number: Int, isUpper: Bool) async -> ToothEntity {
        let definition = ToothFactory.definition(for: number, in: appModel.sessionData.currentModule)
        let tooth = await ToothFactory.makeToothEntity(definition: definition)
        
        // Get anatomically correct position for this tooth
        let position = toothPosition(for: number, isUpper: isUpper)
        tooth.position = position.position
        tooth.orientation = position.rotation
        
        return tooth
    }
    
    // Anatomically correct tooth positions based on Universal Numbering System
    private func toothPosition(for number: Int, isUpper: Bool) -> (position: SIMD3<Float>, rotation: simd_quatf) {
        // Convert real dental measurements from mm to meters
        // Based on adult human dental arch anatomy research
        
        // Upper arch measurements (maxillary)
        let maxInterMolarWidth: Float = 0.064 // 64mm
        let maxInterCanineWidth: Float = 0.036 // 36mm
        let maxArchDepth: Float = 0.044 // 44mm
        
        // Lower arch measurements (mandibular) - slightly smaller
        let mandInterMolarWidth: Float = 0.056 // 56mm
        let mandInterCanineWidth: Float = 0.035 // 35mm
        let mandArchDepth: Float = 0.040 // 40mm
        
        // Individual tooth widths (approximate average)
        let centralIncisorWidth: Float = 0.0085
        let lateralIncisorWidth: Float = 0.0065
        let canineWidth: Float = 0.0075
        let premolarWidth: Float = 0.0070
        let molarWidth: Float = 0.0105
        
        var x: Float = 0
        var z: Float = 0
        var rotationY: Float = 0
        
        if isUpper {
            // Upper arch (teeth 1-16) - parabolic curve
            let canineX = maxInterCanineWidth / 2
            let molarX = maxInterMolarWidth / 2
            let frontZ: Float = -0.008 // Incisors slightly forward
            
            switch number {
            // RIGHT SIDE (1-8)
            case 1: // Upper Right Third Molar (wisdom)
                x = molarX; z = maxArchDepth * 0.95; rotationY = -.pi/5
            case 2: // Upper Right Second Molar
                x = molarX * 0.90; z = maxArchDepth * 0.75; rotationY = -.pi/6
            case 3: // Upper Right First Molar
                x = molarX * 0.78; z = maxArchDepth * 0.55; rotationY = -.pi/8
            case 4: // Upper Right Second Premolar
                x = (molarX * 0.78 + canineX) / 2; z = maxArchDepth * 0.30; rotationY = -.pi/10
            case 5: // Upper Right First Premolar
                x = (canineX + molarX * 0.78) / 2 - premolarWidth; z = maxArchDepth * 0.15; rotationY = -.pi/12
            case 6: // Upper Right Canine
                x = canineX; z = 0.002; rotationY = -.pi/16
            case 7: // Upper Right Lateral Incisor
                x = centralIncisorWidth + lateralIncisorWidth / 2; z = frontZ; rotationY = -.pi/24
            case 8: // Upper Right Central Incisor
                x = centralIncisorWidth / 2; z = frontZ - 0.002; rotationY = 0
                
            // LEFT SIDE (9-16)
            case 9: // Upper Left Central Incisor
                x = -centralIncisorWidth / 2; z = frontZ - 0.002; rotationY = 0
            case 10: // Upper Left Lateral Incisor
                x = -(centralIncisorWidth + lateralIncisorWidth / 2); z = frontZ; rotationY = .pi/24
            case 11: // Upper Left Canine
                x = -canineX; z = 0.002; rotationY = .pi/16
            case 12: // Upper Left First Premolar
                x = -(canineX + molarX * 0.78) / 2 + premolarWidth; z = maxArchDepth * 0.15; rotationY = .pi/12
            case 13: // Upper Left Second Premolar
                x = -(molarX * 0.78 + canineX) / 2; z = maxArchDepth * 0.30; rotationY = .pi/10
            case 14: // Upper Left First Molar
                x = -molarX * 0.78; z = maxArchDepth * 0.55; rotationY = .pi/8
            case 15: // Upper Left Second Molar
                x = -molarX * 0.90; z = maxArchDepth * 0.75; rotationY = .pi/6
            case 16: // Upper Left Third Molar (wisdom)
                x = -molarX; z = maxArchDepth * 0.95; rotationY = .pi/5
                
            default:
                break
            }
        } else {
            // Lower arch (teeth 17-32) - slightly smaller parabolic curve
            let canineX = mandInterCanineWidth / 2
            let molarX = mandInterMolarWidth / 2
            let frontZ: Float = -0.008
            
            switch number {
            // LEFT SIDE (17-24)
            case 17: // Lower Left Third Molar (wisdom)
                x = -molarX; z = mandArchDepth * 0.95; rotationY = .pi/5
            case 18: // Lower Left Second Molar
                x = -molarX * 0.90; z = mandArchDepth * 0.75; rotationY = .pi/6
            case 19: // Lower Left First Molar
                x = -molarX * 0.78; z = mandArchDepth * 0.55; rotationY = .pi/8
            case 20: // Lower Left Second Premolar
                x = -(molarX * 0.78 + canineX) / 2; z = mandArchDepth * 0.30; rotationY = .pi/10
            case 21: // Lower Left First Premolar
                x = -(canineX + molarX * 0.78) / 2 + premolarWidth; z = mandArchDepth * 0.15; rotationY = .pi/12
            case 22: // Lower Left Canine
                x = -canineX; z = 0.002; rotationY = .pi/16
            case 23: // Lower Left Lateral Incisor
                x = -(centralIncisorWidth + lateralIncisorWidth / 2); z = frontZ; rotationY = .pi/24
            case 24: // Lower Left Central Incisor
                x = -centralIncisorWidth / 2; z = frontZ - 0.002; rotationY = 0
                
            // RIGHT SIDE (25-32)
            case 25: // Lower Right Central Incisor
                x = centralIncisorWidth / 2; z = frontZ - 0.002; rotationY = 0
            case 26: // Lower Right Lateral Incisor
                x = centralIncisorWidth + lateralIncisorWidth / 2; z = frontZ; rotationY = -.pi/24
            case 27: // Lower Right Canine
                x = canineX; z = 0.002; rotationY = -.pi/16
            case 28: // Lower Right First Premolar
                x = (canineX + molarX * 0.78) / 2 - premolarWidth; z = mandArchDepth * 0.15; rotationY = -.pi/12
            case 29: // Lower Right Second Premolar
                x = (molarX * 0.78 + canineX) / 2; z = mandArchDepth * 0.30; rotationY = -.pi/10
            case 30: // Lower Right First Molar
                x = molarX * 0.78; z = mandArchDepth * 0.55; rotationY = -.pi/8
            case 31: // Lower Right Second Molar
                x = molarX * 0.90; z = mandArchDepth * 0.75; rotationY = -.pi/6
            case 32: // Lower Right Third Molar (wisdom)
                x = molarX; z = mandArchDepth * 0.95; rotationY = -.pi/5
                
            default:
                break
            }
        }
        
        let rotation = simd_quatf(angle: rotationY, axis: [0, 1, 0])
        return (position: SIMD3<Float>(x, 0, z), rotation: rotation)
    }
    
    private func updateToothHighlights() {
        for (number, tooth) in teethEntities {
            // Highlight selected tooth
            if appModel.selectedToothID == number {
                addHighlightGlow(to: tooth)
            } else {
                removeHighlightGlow(from: tooth)
            }
            
            // Update appearance based on condition
            InteractionSystem.updateToothAppearance(tooth: tooth, modelEntity: tooth.crownEntity)
        }
    }
    
    private func addHighlightGlow(to tooth: ToothEntity) {
        if tooth.children.contains(where: { $0.name == "Highlight" }) { return }
        
        let highlightMesh = MeshResource.generateSphere(radius: 0.03)
        var highlightMaterial = UnlitMaterial()
        highlightMaterial.color = .init(tint: .yellow.withAlphaComponent(0.3))
        
        let highlight = ModelEntity(mesh: highlightMesh, materials: [highlightMaterial])
        highlight.name = "Highlight"
        highlight.position = [0, 0, 0]
        tooth.addChild(highlight)
    }
    
    private func removeHighlightGlow(from tooth: ToothEntity) {
        tooth.children.first(where: { $0.name == "Highlight" })?.removeFromParent()
    }
    
    private func handleTap(on entity: Entity) {
        // Find the tooth entity by traversing up the hierarchy
        var currentEntity: Entity? = entity
        var toothEntity: ToothEntity?
        
        while currentEntity != nil {
            if let tooth = currentEntity as? ToothEntity {
                toothEntity = tooth
                break
            }
            currentEntity = currentEntity?.parent
        }
        
        guard let tooth = toothEntity else { return }
        
        appModel.selectedToothID = tooth.toothNumber
        
        let result = InteractionSystem.handleToolInteraction(
            tooth: tooth,
            tool: appModel.selectedTool,
            currentStep: appModel.sessionData.currentStep,
            appModel: appModel
        )
        
        handleInteractionResult(result, tooth: tooth)
    }
    
    private func handleInteractionResult(_ result: InteractionResult, tooth: ToothEntity) {
        switch result {
        case .success:
            // Visual feedback for success
            playSuccessAnimation(on: tooth)
            
        case .wrongTool:
            playErrorAnimation(on: tooth)
            
        case .wrongTarget:
            playErrorAnimation(on: tooth)
            
        case .wrongSequence:
            playErrorAnimation(on: tooth)
            
        case .inProgress(let progress):
            // Show progress feedback
            updateProgressFeedback(on: tooth, progress: progress)
            
        case .extracted:
            playExtractionAnimation(on: tooth)
            
        case .exploratory:
            // Free exploration mode
            break
        }
    }
    
    private func playSuccessAnimation(on tooth: ToothEntity) {
        let originalScale = tooth.crownEntity.scale
        let scaleUp = Transform(scale: originalScale * 1.1)
        let scaleDown = Transform(scale: originalScale)
        
        tooth.crownEntity.move(to: scaleUp, relativeTo: tooth, duration: 0.1)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            tooth.crownEntity.move(to: scaleDown, relativeTo: tooth, duration: 0.1)
        }
    }
    
    private func playErrorAnimation(on tooth: ToothEntity) {
        let originalPosition = tooth.crownEntity.position
        
        for i in 0..<3 {
            let offset = i % 2 == 0 ? SIMD3<Float>(0.005, 0, 0) : SIMD3<Float>(-0.005, 0, 0)
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(i) * 0.05) {
                tooth.crownEntity.position = originalPosition + offset
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
            tooth.crownEntity.position = originalPosition
        }
    }
    
    private func updateProgressFeedback(on tooth: ToothEntity, progress: Float) {
        var material = SimpleMaterial()
        let intensity = 0.7 + (progress * 0.3)
        material.color = .init(tint: UIColor(red: 1.0, green: CGFloat(intensity), blue: CGFloat(intensity), alpha: 0.95))
        tooth.crownEntity.model?.materials = [material]
    }
    
    private func playExtractionAnimation(on tooth: ToothEntity) {
        let moveUp = Transform(
            scale: [0.5, 0.5, 0.5],
            rotation: simd_quatf(angle: .pi / 4, axis: [0, 0, 1]),
            translation: tooth.position + [0, 0.15, 0]
        )
        
        tooth.crownEntity.move(to: moveUp, relativeTo: tooth.parent, duration: 0.5)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            tooth.crownEntity.position.y -= 0.2
            var material = SimpleMaterial()
            material.color = .init(tint: .clear)
            tooth.crownEntity.model?.materials = [material]
        }
    }
}

struct InstructionOverlay: View {
    @Environment(AppModel.self) private var appModel
    
    var body: some View {
        VStack(spacing: 15) {
            if let step = appModel.sessionData.currentStep {
                VStack(alignment: .leading, spacing: 10) {
                    HStack {
                        Text("Step \(appModel.sessionData.currentStepIndex + 1) of \(appModel.sessionData.currentModule?.steps.count ?? 0)")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        
                        Spacer()
                        
                        Label(step.tool.rawValue, systemImage: step.tool.iconName)
                            .font(.caption)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(.blue.opacity(0.2))
                            .clipShape(Capsule())
                    }
                    
                    Text(step.instruction)
                        .font(.headline)
                    
                    Text("Target: \(step.targetArea)")
                        .font(.subheadline)
                        .foregroundStyle(.blue)
                    
                    if let tip = step.tip {
                        HStack(spacing: 8) {
                            Image(systemName: "lightbulb.fill")
                                .foregroundStyle(.yellow)
                            Text(tip)
                                .font(.subheadline)
                        }
                        .padding(8)
                        .background(.yellow.opacity(0.1), in: RoundedRectangle(cornerRadius: 8))
                    }
                    
                    ProgressView(value: appModel.sessionData.progress)
                        .tint(.blue)
                }
                .padding()
                .frame(width: 450)
                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 20))
                .shadow(radius: 10)
            } else {
                VStack(alignment: .leading, spacing: 10) {
                    HStack {
                        Image(systemName: "eye.fill")
                            .foregroundStyle(.green)
                        Text("Exploration Mode")
                            .font(.headline)
                    }
                    
                    Text("Tap on any tooth to select it and interact with different tools.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    
                    Text("Start a training module from the main menu to begin guided procedures.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .padding()
                .frame(width: 450)
                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 20))
                .shadow(radius: 10)
            }
        }
        .padding()
    }
}

struct ToolPalette: View {
    @Environment(AppModel.self) private var appModel
    
    var body: some View {
        HStack(spacing: 15) {
            ForEach(DentalTool.allCases, id: \.self) { tool in
                ToolButton(tool: tool, isSelected: appModel.selectedTool == tool) {
                    appModel.selectedTool = tool
                }
            }
        }
        .padding()
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 20))
        .padding(.bottom, 30)
    }
}

struct ToolButton: View {
    let tool: DentalTool
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: tool.iconName)
                    .font(.title2)
                Text(tool.rawValue)
                    .font(.caption)
            }
            .frame(width: 70, height: 70)
            .background(isSelected ? Color.blue : Color.clear)
            .foregroundStyle(isSelected ? .white : .primary)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? Color.clear : Color.gray.opacity(0.3), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }
}

struct SessionInfoPanel: View {
    @Environment(AppModel.self) private var appModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            if let module = appModel.sessionData.currentModule {
                Text(module.title)
                    .font(.headline)
                
                Divider()
                
                HStack {
                    Image(systemName: "clock")
                    Text(formatTime(appModel.sessionData.elapsedTime))
                        .monospacedDigit()
                }
                .font(.subheadline)
                
                HStack {
                    Image(systemName: "exclamationmark.triangle")
                    Text("\(appModel.sessionData.errors.count) errors")
                }
                .font(.subheadline)
                .foregroundStyle(appModel.sessionData.errors.isEmpty ? Color.secondary : Color.orange)
                
                if let toothID = appModel.selectedToothID {
                    HStack {
                        Image(systemName: "tooth")
                        Text("Tooth #\(toothID)")
                    }
                    .font(.subheadline)
                    .foregroundStyle(.blue)
                }
                
                HStack {
                    Image(systemName: "hand.tap")
                    Text("Tool: \(appModel.selectedTool.rawValue)")
                }
                .font(.subheadline)
                .foregroundStyle(.purple)
                
                if appModel.sessionData.completed {
                    Divider()
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Procedure Complete!")
                            .font(.headline)
                            .foregroundStyle(.green)
                        
                        HStack {
                            Image(systemName: "star.fill")
                            Text("Score: \(appModel.performanceScore)")
                                .fontWeight(.semibold)
                        }
                        .foregroundStyle(.yellow)
                    }
                }
            } else {
                Text("Exploration Mode")
                    .font(.headline)
                
                Divider()
                
                Text("Free Exploration")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                
                if let toothID = appModel.selectedToothID {
                    Divider()
                    
                    HStack {
                        Image(systemName: "tooth")
                        Text("Tooth #\(toothID)")
                    }
                    .font(.subheadline)
                    .foregroundStyle(.blue)
                }
                
                HStack {
                    Image(systemName: "hand.tap")
                    Text("Tool: \(appModel.selectedTool.rawValue)")
                }
                .font(.subheadline)
                .foregroundStyle(.purple)
                
                Divider()
                
                Text("Select a training module from the main menu to begin guided procedures.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding()
        .frame(width: 250)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 15))
        .padding()
    }
    
    private func formatTime(_ interval: TimeInterval) -> String {
        let minutes = Int(interval) / 60
        let seconds = Int(interval) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}

#Preview(immersionStyle: .full) {
    ImmersiveView()
        .environment(AppModel())
}
