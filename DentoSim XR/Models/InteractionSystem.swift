//
//  InteractionSystem.swift
//  DentoSim XR
//
//  Created by Michal Fereniec on 17/11/2025.
//

import Foundation
import RealityKit
import UIKit

@MainActor
class InteractionSystem {
    static func handleToolInteraction(
        tooth: ToothEntity,
        tool: DentalTool,
        currentStep: ProcedureStep?,
        appModel: AppModel
    ) -> InteractionResult {
        guard let step = currentStep else {
            return .exploratory
        }
        
        // Check if correct tool
        guard tool == step.tool else {
            appModel.recordError("Wrong tool selected. Use \(step.tool.rawValue)", severity: .moderate)
            return .wrongTool
        }
        
        // Check if correct tooth
        if let targetTooth = appModel.sessionData.currentModule?.targetTooth {
            guard tooth.toothNumber == targetTooth else {
                appModel.recordError("Wrong tooth selected. Target is tooth #\(targetTooth)", severity: .moderate)
                return .wrongTarget
            }
        }
        
        // Perform tool-specific action
        switch tool {
        case .mirror, .explorer:
            // Inspection tools - instant completion
            appModel.completeCurrentStep()
            return .success
            
        case .syringe:
            // Anesthesia
            tooth.condition = .anesthetized
            appModel.completeCurrentStep()
            return .success
            
        case .elevator:
            // Loosening tooth
            tooth.workProgress += 0.34
            if tooth.workProgress >= 1.0 {
                tooth.condition = .loosened
                appModel.completeCurrentStep()
                tooth.workProgress = 0
                return .success
            }
            return .inProgress(tooth.workProgress)
            
        case .forceps:
            // Extraction
            if tooth.condition == .loosened {
                tooth.workProgress += 0.5
                if tooth.workProgress >= 1.0 {
                    tooth.condition = .extracted
                    appModel.completeCurrentStep()
                    tooth.workProgress = 0
                    return .extracted
                }
                return .inProgress(tooth.workProgress)
            } else {
                appModel.recordError("Tooth must be loosened first with elevator", severity: .moderate)
                return .wrongSequence
            }
            
        case .excavator:
            // Removing decay
            tooth.workProgress += 0.25
            if tooth.workProgress >= 1.0 {
                tooth.condition = .prepared
                appModel.completeCurrentStep()
                tooth.workProgress = 0
                return .success
            }
            return .inProgress(tooth.workProgress)
            
        case .drill:
            // Cavity preparation
            tooth.workProgress += 0.2
            if tooth.workProgress >= 1.0 {
                tooth.condition = .prepared
                appModel.completeCurrentStep()
                tooth.workProgress = 0
                return .success
            }
            return .inProgress(tooth.workProgress)
            
        case .scaler:
            // Cleaning
            tooth.workProgress += 0.3
            if tooth.workProgress >= 1.0 {
                appModel.completeCurrentStep()
                tooth.workProgress = 0
                return .success
            }
            return .inProgress(tooth.workProgress)
        }
    }
    
    static func updateToothAppearance(tooth: ToothEntity, modelEntity: ModelEntity) {
        var material = SimpleMaterial()
        
        switch tooth.condition {
        case .healthy:
            material.color = .init(tint: .white.withAlphaComponent(0.95))
        case .cavity:
            material.color = .init(tint: UIColor(red: 0.9, green: 0.85, blue: 0.7, alpha: 0.95))
        case .decayed:
            material.color = .init(tint: UIColor(red: 0.6, green: 0.5, blue: 0.3, alpha: 0.95))
        case .prepared:
            material.color = .init(tint: UIColor(red: 0.95, green: 0.9, blue: 0.85, alpha: 0.95))
        case .extracted:
            material.color = .init(tint: .red.withAlphaComponent(0.3))
        case .loosened:
            material.color = .init(tint: UIColor(red: 1.0, green: 0.9, blue: 0.9, alpha: 0.95))
        case .anesthetized:
            material.color = .init(tint: UIColor(red: 0.9, green: 0.95, blue: 1.0, alpha: 0.95))
        case .cleaned:
            material.color = .init(tint: UIColor(red: 0.8, green: 0.8, blue: 0.8, alpha: 0.95))
        }
        
        modelEntity.model?.materials = [material]
        
        // Scale down extracted teeth
        if tooth.condition == .extracted {
            modelEntity.scale = [0.3, 0.3, 0.3]
            tooth.position.y -= 0.1
        }
    }
}

enum InteractionResult {
    case success
    case wrongTool
    case wrongTarget
    case wrongSequence
    case inProgress(Float)
    case extracted
    case exploratory
}
