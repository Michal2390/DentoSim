//
//  ImmersiveView.swift
//  DentoSim XR
//
//  Created by Michal Fereniec on 17/11/2025.
//

import SwiftUI
import RealityKit
import UIKit

struct ImmersiveView: View {
    @Environment(AppModel.self) var appModel
    @Environment(AIManager.self) var aiManager
    @State private var teethEntities: [Int: ToothEntity] = [:]
    
    var body: some View {
        RealityView { content, attachments in
            // Create jaw model
            let jawEntity = await createJawModel()
            // Position at eye level, comfortable distance
            jawEntity.position = [0, 1.5, -0.8]
            
            // Tilt jaw slightly for better view
            let tiltRotation = simd_quatf(angle: .pi / 24, axis: [1, 0, 0])
            jawEntity.orientation = tiltRotation
            
            content.add(jawEntity)
            
            // Add UI attachments in 3D space - positioned much higher and further away
            
            // Session info panel - left side at eye level
            if let sessionPanel = attachments.entity(for: "sessionPanel") {
                sessionPanel.position = [-50, 50, -50]
                content.add(sessionPanel)
            }
            
            // Instructions panel - right side at eye level
            if let instructionsPanel = attachments.entity(for: "instructionsPanel") {
                instructionsPanel.position = [50, 50, -50]
                content.add(instructionsPanel)
            }
            
            // Chat panel - floating near teeth, right side
            if let chatPanel = attachments.entity(for: "chatPanel") {
                chatPanel.position = [40, 50, -40]
                content.add(chatPanel)
            }
            
            // Tool palette - below teeth, centered
            if let toolPalette = attachments.entity(for: "toolPalette") {
                toolPalette.position = [0, 30, -40]
                content.add(toolPalette)
            }
            
            // Control buttons - above teeth, centered
            if let controlButtons = attachments.entity(for: "controlButtons") {
                controlButtons.position = [0, 70, -40]
                content.add(controlButtons)
            }
            
        } update: { content, attachments in
            updateToothHighlights()
            
            // Update attachment visibility
            if let instructionsPanel = attachments.entity(for: "instructionsPanel") {
                instructionsPanel.isEnabled = appModel.showInstructions
            }
            
            if let chatPanel = attachments.entity(for: "chatPanel") {
                chatPanel.isEnabled = appModel.showChat
            }
            
        } attachments: {
            // Session info panel
            Attachment(id: "sessionPanel") {
                SessionInfoPanel()
            }
            
            // Instructions panel
            Attachment(id: "instructionsPanel") {
                InstructionOverlay()
            }
            
            // Chat panel - new floating chat near teeth
            Attachment(id: "chatPanel") {
                CompactChatPanel()
            }
            
            // Tool palette
            Attachment(id: "toolPalette") {
                ToolPalette()
            }
            
            // Control buttons
            Attachment(id: "controlButtons") {
                ControlButtonsPanel()
            }
        }
        .gesture(
            SpatialTapGesture()
                .targetedToAnyEntity()
                .onEnded { value in
                    handleTap(on: value.entity)
                }
        )
    }
    
    private func createJawModel() async -> Entity {
        let jawParent = Entity()
        jawParent.name = "JawModel"
        
        let upperJaw = await createArchEntity(isUpper: true)
        let lowerJaw = await createArchEntity(isUpper: false)
        
        jawParent.addChild(upperJaw)
        jawParent.addChild(lowerJaw)
        
        return jawParent
    }
    
    private func createArchEntity(isUpper: Bool) async -> Entity {
        let arch = Entity()
        arch.name = isUpper ? "UpperArch" : "LowerArch"
        
        // Vertical separation between arches
        let yOffset: Float = isUpper ? 0.02 : -0.02
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
        
        let position = toothPosition(for: number, isUpper: isUpper)
        tooth.position = position.position
        tooth.orientation = position.rotation
        
        return tooth
    }
    
    // Improved tooth positioning with proper U-shaped dental arch
    private func toothPosition(for number: Int, isUpper: Bool) -> (position: SIMD3<Float>, rotation: simd_quatf) {
        // Dental arch parameters (in meters)
        let archWidth: Float = 0.065        // Width between molars
        let archDepth: Float = 0.045        // Depth of arch curve
        let canineWidth: Float = 0.035      // Width at canines
        
        var x: Float = 0
        var z: Float = 0
        var angleY: Float = 0
        var angleX: Float = 0
        var angleZ: Float = 0  // Add roll rotation
        
        // Determine which tooth position (0-15 for each arch)
        let toothIndex: Int
        if number <= 16 {
            // Upper arch: 1-8 is right side, 9-16 is left side
            toothIndex = number - 1
        } else {
            // Lower arch: 17-24 is left side, 25-32 is right side
            toothIndex = number - 17
        }
        
        // Determine if right or left side
        let isRightSide: Bool
        if number <= 16 {
            isRightSide = number <= 8
        } else {
            isRightSide = number >= 25
        }
        
        // Get position within half-arch (0-7)
        let halfArchPos: Int
        if isRightSide {
            halfArchPos = number <= 16 ? (8 - number) : (32 - number)
        } else {
            halfArchPos = number <= 16 ? (number - 9) : (number - 17)
        }
        
        let sideFactor: Float = isRightSide ? 1.0 : -1.0
        
        // Create smooth parabolic arch
        let t = Float(halfArchPos) / 7.0  // 0.0 at front, 1.0 at back
        
        // X position (width) - wider at back
        switch halfArchPos {
        case 0: x = sideFactor * 0.004      // Central incisor
        case 1: x = sideFactor * 0.012      // Lateral incisor
        case 2: x = sideFactor * 0.020      // Canine
        case 3: x = sideFactor * 0.028      // First premolar
        case 4: x = sideFactor * 0.036      // Second premolar
        case 5: x = sideFactor * 0.044      // First molar
        case 6: x = sideFactor * 0.052      // Second molar
        case 7: x = sideFactor * 0.058      // Third molar
        default: x = 0
        }
        
        // Z position (depth) - parabolic curve
        switch halfArchPos {
        case 0: z = -0.006                  // Front incisors forward
        case 1: z = -0.004
        case 2: z = 0.000                   // Canine at curve start
        case 3: z = 0.008
        case 4: z = 0.018
        case 5: z = 0.028
        case 6: z = 0.036
        case 7: z = 0.042                   // Back molars deepest
        default: z = 0
        }
        
        // Rotation Y (following arch curve)
        switch halfArchPos {
        case 0: angleY = 0
        case 1: angleY = sideFactor * .pi / 24
        case 2: angleY = sideFactor * .pi / 12
        case 3: angleY = sideFactor * .pi / 8
        case 4: angleY = sideFactor * .pi / 6
        case 5: angleY = sideFactor * .pi / 5
        case 6: angleY = sideFactor * .pi / 4
        case 7: angleY = sideFactor * .pi / 3.5
        default: angleY = 0
        }
        
        // Rotation X (tooth tilt) - MORE AGGRESSIVE TILT
        if isUpper {
            // Upper teeth tilt DOWN and OUT (visible from below)
            switch halfArchPos {
            case 0...1: angleX = .pi / 6      // Front teeth tilt down more
            case 2: angleX = .pi / 5
            case 3...4: angleX = .pi / 4.5
            case 5...7: angleX = .pi / 4      // Back teeth tilt down significantly
            default: angleX = .pi / 6
            }
        } else {
            // Lower teeth tilt UP and IN (visible from below)
            switch halfArchPos {
            case 0...1: angleX = -.pi / 6
            case 2: angleX = -.pi / 5
            case 3...4: angleX = -.pi / 4.5
            case 5...7: angleX = -.pi / 4
            default: angleX = -.pi / 6
            }
        }
        
        // Rotation Z (roll) - teeth lean slightly inward toward tongue
        angleZ = sideFactor * (.pi / 32 * Float(halfArchPos / 2))
        
        // Combine all three rotations for realistic tooth orientation
        let rotY = simd_quatf(angle: angleY, axis: [0, 1, 0])
        let rotX = simd_quatf(angle: angleX, axis: [1, 0, 0])
        let rotZ = simd_quatf(angle: angleZ, axis: [0, 0, 1])
        let combinedRotation = rotY * rotX * rotZ
        
        return (position: SIMD3<Float>(x, 0, z), rotation: combinedRotation)
    }
    
    private func updateToothHighlights() {
        for (number, tooth) in teethEntities {
            if appModel.selectedToothID == number {
                addHighlightGlow(to: tooth)
            } else {
                removeHighlightGlow(from: tooth)
            }
            
            InteractionSystem.updateToothAppearance(tooth: tooth, modelEntity: tooth.crownEntity)
        }
    }
    
    private func addHighlightGlow(to tooth: ToothEntity) {
        if tooth.children.contains(where: { $0.name == "Highlight" }) { return }
        
        let highlightMesh = MeshResource.generateSphere(radius: 0.025)
        var highlightMaterial = UnlitMaterial()
        highlightMaterial.color = .init(tint: .yellow.withAlphaComponent(0.4))
        
        let highlight = ModelEntity(mesh: highlightMesh, materials: [highlightMaterial])
        highlight.name = "Highlight"
        highlight.position = [0, 0, 0]
        tooth.addChild(highlight)
    }
    
    private func removeHighlightGlow(from tooth: ToothEntity) {
        tooth.children.first(where: { $0.name == "Highlight" })?.removeFromParent()
    }
    
    private func handleTap(on entity: Entity) {
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
            playSuccessAnimation(on: tooth)
        case .wrongTool:
            playErrorAnimation(on: tooth)
        case .wrongTarget:
            playErrorAnimation(on: tooth)
        case .wrongSequence:
            playErrorAnimation(on: tooth)
        case .inProgress(let progress):
            updateProgressFeedback(on: tooth, progress: progress)
        case .extracted:
            playExtractionAnimation(on: tooth)
        case .exploratory:
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

// MARK: - Control Buttons Panel

struct ControlButtonsPanel: View {
    @Environment(AppModel.self) private var appModel
    
    var body: some View {
        HStack(spacing: 20) {
            Button {
                appModel.showInstructions.toggle()
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: appModel.showInstructions ? "eye.slash.fill" : "eye.fill")
                    Text(appModel.showInstructions ? "Hide Steps" : "Show Steps")
                }
                .font(.callout)
                .fontWeight(.semibold)
                .padding(.horizontal, 20)
                .padding(.vertical, 12)
                .background(.regularMaterial)
                .clipShape(Capsule())
            }
            .buttonStyle(.plain)
            
            Button {
                appModel.showChat.toggle()
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "bubble.left.and.text.bubble.right.fill")
                    Text(appModel.showChat ? "Hide Chat" : "Ask AI")
                }
                .font(.callout)
                .fontWeight(.semibold)
                .padding(.horizontal, 20)
                .padding(.vertical, 12)
                .background(.regularMaterial)
                .clipShape(Capsule())
            }
            .buttonStyle(.plain)
        }
    }
}

// MARK: - Compact Chat Panel (Floating near teeth)

struct CompactChatPanel: View {
    @Environment(AIManager.self) private var aiManager
    @State private var messageText: String = ""
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Image(systemName: "brain.head.profile")
                    .font(.headline)
                    .foregroundStyle(.blue)
                
                Text("Dental AI Assistant")
                    .font(.headline)
                
                Spacer()
            }
            .padding()
            .background(.ultraThinMaterial)
            
            Divider()
            
            // Chat messages
            ScrollView {
                VStack(spacing: 10) {
                    ForEach(aiManager.chatHistory.filter { $0.role != .system }) { message in
                        ChatMessageRow(message: message)
                    }
                    
                    if aiManager.isLoading {
                        HStack {
                            ProgressView()
                                .scaleEffect(0.7)
                            Text("AI is thinking...")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        .padding(.vertical, 8)
                    }
                }
                .padding()
            }
            .frame(height: 300)
            
            Divider()
            
            // Input
            HStack(spacing: 10) {
                TextField("Ask about the procedure...", text: $messageText)
                    .textFieldStyle(.plain)
                    .padding(10)
                    .background(.quaternary.opacity(0.3), in: RoundedRectangle(cornerRadius: 10))
                
                Button {
                    sendMessage()
                } label: {
                    Image(systemName: "paperplane.fill")
                        .font(.title3)
                        .foregroundStyle(messageText.isEmpty ? .gray : .blue)
                }
                .buttonStyle(.plain)
                .disabled(messageText.isEmpty || aiManager.isLoading)
            }
            .padding()
            .background(.ultraThinMaterial)
        }
        .frame(width: 400)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 20))
        .shadow(radius: 15)
    }
    
    private func sendMessage() {
        let message = messageText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !message.isEmpty else { return }
        
        messageText = ""
        
        Task {
            await aiManager.sendMessage(message)
        }
    }
}

struct ChatMessageRow: View {
    let message: AIChatModel
    
    var isUser: Bool {
        message.role == .user
    }
    
    var body: some View {
        HStack {
            if isUser { Spacer(minLength: 40) }
            
            VStack(alignment: isUser ? .trailing : .leading, spacing: 4) {
                Text(message.message)
                    .font(.subheadline)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(isUser ? Color.blue : Color.gray.opacity(0.3))
                    .foregroundStyle(isUser ? .white : .primary)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                
                Text(message.timestamp, style: .time)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
            
            if !isUser { Spacer(minLength: 40) }
        }
    }
}

// MARK: - Instruction Overlay

struct InstructionOverlay: View {
    @Environment(AppModel.self) private var appModel
    
    var body: some View {
        VStack(spacing: 12) {
            if let step = appModel.sessionData.currentStep {
                VStack(alignment: .leading, spacing: 10) {
                    HStack {
                        Text("Step \(appModel.sessionData.currentStepIndex + 1)/\(appModel.sessionData.currentModule?.steps.count ?? 0)")
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
                        .font(.subheadline)
                        .fontWeight(.semibold)
                    
                    Text("Target: \(step.targetArea)")
                        .font(.caption)
                        .foregroundStyle(.blue)
                    
                    if let tip = step.tip {
                        HStack(spacing: 6) {
                            Image(systemName: "lightbulb.fill")
                                .font(.caption)
                                .foregroundStyle(.yellow)
                            Text(tip)
                                .font(.caption)
                        }
                        .padding(8)
                        .background(.yellow.opacity(0.15), in: RoundedRectangle(cornerRadius: 8))
                    }
                    
                    ProgressView(value: appModel.sessionData.progress)
                        .tint(.blue)
                }
                .padding()
                .frame(width: 350)
                .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16))
                .shadow(radius: 10)
            } else {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Image(systemName: "eye.fill")
                            .foregroundStyle(.green)
                        Text("Exploration Mode")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                    }
                    
                    Text("Tap teeth to select and use tools to explore.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .padding()
                .frame(width: 350)
                .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16))
                .shadow(radius: 10)
            }
        }
    }
}

// MARK: - Tool Palette

struct ToolPalette: View {
    @Environment(AppModel.self) private var appModel
    
    var body: some View {
        HStack(spacing: 10) {
            ForEach(DentalTool.allCases, id: \.self) { tool in
                ToolButton(tool: tool, isSelected: appModel.selectedTool == tool) {
                    appModel.selectedTool = tool
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 18))
        .shadow(radius: 10)
    }
}

struct ToolButton: View {
    let tool: DentalTool
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(systemName: tool.iconName)
                    .font(.title3)
                Text(tool.rawValue)
                    .font(.caption2)
            }
            .frame(width: 60, height: 60)
            .background(isSelected ? Color.blue : Color.clear)
            .foregroundStyle(isSelected ? .white : .primary)
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(isSelected ? Color.clear : Color.gray.opacity(0.3), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Session Info Panel

struct SessionInfoPanel: View {
    @Environment(AppModel.self) private var appModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            if let module = appModel.sessionData.currentModule {
                Text(module.title)
                    .font(.subheadline)
                    .fontWeight(.bold)
                
                Divider()
                
                HStack(spacing: 6) {
                    Image(systemName: "clock")
                        .font(.caption)
                    Text(formatTime(appModel.sessionData.elapsedTime))
                        .font(.caption)
                        .monospacedDigit()
                }
                
                HStack(spacing: 6) {
                    Image(systemName: "exclamationmark.triangle")
                        .font(.caption)
                    Text("\(appModel.sessionData.errors.count) errors")
                        .font(.caption)
                }
                .foregroundStyle(appModel.sessionData.errors.isEmpty ? .secondary : Color.orange)
                
                if let toothID = appModel.selectedToothID {
                    Divider()
                    HStack(spacing: 6) {
                        Image(systemName: "tooth.fill")
                            .font(.caption)
                        Text("Tooth #\(toothID)")
                            .font(.caption)
                    }
                    .foregroundStyle(.blue)
                }
                
                HStack(spacing: 6) {
                    Image(systemName: "hand.tap.fill")
                        .font(.caption)
                    Text(appModel.selectedTool.rawValue)
                        .font(.caption)
                }
                .foregroundStyle(.purple)
                
                if appModel.sessionData.completed {
                    Divider()
                    
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Complete!")
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundStyle(.green)
                        
                        HStack(spacing: 4) {
                            Image(systemName: "star.fill")
                                .font(.caption2)
                            Text("Score: \(appModel.performanceScore)")
                                .font(.caption)
                        }
                        .foregroundStyle(.yellow)
                    }
                }
            } else {
                Text("Exploration")
                    .font(.subheadline)
                    .fontWeight(.bold)
                
                Divider()
                
                if let toothID = appModel.selectedToothID {
                    HStack(spacing: 6) {
                        Image(systemName: "tooth.fill")
                            .font(.caption)
                        Text("Tooth #\(toothID)")
                            .font(.caption)
                    }
                    .foregroundStyle(.blue)
                }
                
                HStack(spacing: 6) {
                    Image(systemName: "hand.tap.fill")
                        .font(.caption)
                    Text(appModel.selectedTool.rawValue)
                        .font(.caption)
                }
                .foregroundStyle(.purple)
            }
        }
        .padding()
        .frame(width: 220)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16))
        .shadow(radius: 10)
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
        .environment(AIManager(service: OpenAIService(apiKey: "preview")))
}