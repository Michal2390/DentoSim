//
//  ToothFactory.swift
//  DentoSim XR
//
//  Created by Alex (AI Copilot) on 17/11/2025.
//

import Foundation
import RealityKit
import UIKit

struct ToothFactory {
    static func definition(for number: Int, in module: ProcedureModule?) -> ToothDefinition {
        let type = ToothType.forToothNumber(number)
        let isUpper = number <= 16
        let initialCondition: ToothCondition

        if let module = module {
            switch module.id {
            case "cavity_class1":
                initialCondition = number == 19 ? .cavity : .healthy
            case "extraction_wisdom":
                initialCondition = number == 18 ? .healthy : .healthy
            case "endo_basic":
                initialCondition = number == 3 ? .decayed : .healthy
            case "exam_basic":
                initialCondition = .healthy
            default:
                initialCondition = .healthy
            }
        } else {
            initialCondition = .healthy
        }

        return ToothDefinition(number: number, type: type, isUpper: isUpper, initialCondition: initialCondition)
    }

    @MainActor
    static func makeToothEntity(definition: ToothDefinition) async -> ToothEntity {
        // Try to load realistic USDZ model
        if let loadedModel = await loadRealisticToothModel(for: definition.type, isUpper: definition.isUpper) {
            return await createToothEntityFromModel(loadedModel, definition: definition)
        }
        
        // Fallback to procedural geometry if model fails to load
        return await createProceduralToothEntity(definition: definition)
    }
    
    @MainActor
    private static func loadRealisticToothModel(for type: ToothType, isUpper: Bool) async -> ModelEntity? {
        let fileName = toothModelFileName(for: type, isUpper: isUpper)
        
        // Try multiple paths to find the USDZ file
        var url: URL?
        
        // First try: subdirectory
        url = Bundle.main.url(forResource: fileName, withExtension: "usdz", subdirectory: "Teeth-Permanent")
        
        // Second try: main bundle
        if url == nil {
            url = Bundle.main.url(forResource: fileName, withExtension: "usdz")
        }
        
        // Third try: Resources folder
        if url == nil {
            url = Bundle.main.url(forResource: fileName, withExtension: "usdz", subdirectory: "Resources/Teeth-Permanent")
        }
        
        // Fourth try: direct path construction
        if url == nil {
            if let bundlePath = Bundle.main.resourcePath {
                let potentialPath = "\(bundlePath)/Teeth-Permanent/\(fileName).usdz"
                if FileManager.default.fileExists(atPath: potentialPath) {
                    url = URL(fileURLWithPath: potentialPath)
                }
            }
        }
        
        guard let fileURL = url else {
            print("⚠️ Could not find tooth model: \(fileName).usdz in any location")
            print("   Bundle path: \(Bundle.main.bundlePath)")
            print("   Resource path: \(Bundle.main.resourcePath ?? "nil")")
            return nil
        }
        
        print("✅ Found tooth model at: \(fileURL.path)")
        
        do {
            let entity = try await ModelEntity(contentsOf: fileURL)
            print("✅ Successfully loaded: \(fileName)")
            return entity
        } catch {
            print("❌ Failed to load tooth model \(fileName): \(error)")
            return nil
        }
    }
    
    private static func toothModelFileName(for type: ToothType, isUpper: Bool) -> String {
        let prefix = isUpper ? "Maxillary" : "Mandibular"
        
        switch type {
        case .centralIncisor:
            return isUpper ? "\(prefix)_Left_Central_Incisor" : "\(prefix)_Left_Central_Incisor"
        case .lateralIncisor:
            return isUpper ? "\(prefix)_Lateral_Incisor" : "\(prefix)_Left_Lateral_Incisor"
        case .canine:
            return isUpper ? "\(prefix)_Canine" : "\(prefix)_Left_Canine"
        case .firstPremolar:
            return "\(prefix)_First_Premolar"
        case .secondPremolar:
            return isUpper ? "\(prefix)_Second_Premolar" : "\(prefix)_Left_Second_Premolar"
        case .firstMolar:
            return "\(prefix)_First_Molar"
        case .secondMolar:
            return "\(prefix)_Second_Molar"
        case .thirdMolar:
            return "\(prefix)_Third_Molar"
        }
    }
    
    @MainActor
    private static func createToothEntityFromModel(_ modelEntity: ModelEntity, definition: ToothDefinition) async -> ToothEntity {
        // Scale the loaded model to appropriate size for VisionOS
        // University of Dundee models are in mm, converting to realistic VisionOS scale
        let scaleFactor: Float = 0.00012 // Adjusted for proper jaw size
        modelEntity.scale = [scaleFactor, scaleFactor, scaleFactor]
        
        // Most dental models face upward, rotate them to face forward
        // Upper teeth point down, lower teeth point up
        let initialRotation = simd_quatf(angle: .pi / 2, axis: [1, 0, 0])
        let flipRotation = definition.isUpper ? simd_quatf(angle: 0, axis: [0, 0, 1]) : simd_quatf(angle: .pi, axis: [0, 0, 1])
        modelEntity.orientation = initialRotation * flipRotation
        
        // Create a "crown" entity (upper part visible)
        let crownEntity = ModelEntity()
        crownEntity.addChild(modelEntity)
        crownEntity.position = [0, 0, 0]
        
        // Apply realistic tooth material
        applyRealisticToothMaterial(to: modelEntity, condition: definition.initialCondition)
        
        // Create a simple root (mostly hidden in gum)
        let rootMesh = MeshResource.generateCone(height: 0.010, radius: 0.002)
        var rootMaterial = SimpleMaterial()
        rootMaterial.color = .init(tint: UIColor(red: 0.85, green: 0.82, blue: 0.75, alpha: 0.8))
        rootMaterial.roughness = 0.6
        let rootEntity = ModelEntity(mesh: rootMesh, materials: [rootMaterial])
        rootEntity.position = [0, definition.isUpper ? -0.008 : 0.008, 0]
        
        let toothEntity = await ToothEntity(
            number: definition.number,
            type: definition.type,
            condition: definition.initialCondition,
            crown: crownEntity,
            root: rootEntity
        )
        
        toothEntity.scale = [1, 1, 1]
        
        return toothEntity
    }
    
    @MainActor
    private static func createProceduralToothEntity(definition: ToothDefinition) async -> ToothEntity {
        // Original box-based tooth as fallback
        let crownMesh = MeshResource.generateBox(width: 0.012, height: 0.016, depth: 0.010, cornerRadius: 0.002)
        var crownMaterial = SimpleMaterial()
        crownMaterial.color = .init(tint: UIColor(red: 0.94, green: 0.94, blue: 0.92, alpha: 1.0))
        crownMaterial.roughness = 0.25
        crownMaterial.metallic = 0.0
        let crownEntity = ModelEntity(mesh: crownMesh, materials: [crownMaterial])
        crownEntity.position = [0, 0.008, 0]

        let rootMesh = MeshResource.generateCone(height: 0.020, radius: 0.005)
        var rootMaterial = SimpleMaterial()
        rootMaterial.color = .init(tint: UIColor(red: 0.85, green: 0.82, blue: 0.75, alpha: 1.0))
        rootMaterial.roughness = 0.5
        let rootEntity = ModelEntity(mesh: rootMesh, materials: [rootMaterial])
        rootEntity.position = [0, -0.010, 0]

        let toothEntity = await ToothEntity(
            number: definition.number,
            type: definition.type,
            condition: definition.initialCondition,
            crown: crownEntity,
            root: rootEntity
        )

        toothEntity.scale = [1, 1, 1]

        return toothEntity
    }
    
    private static func applyRealisticToothMaterial(to entity: ModelEntity, condition: ToothCondition) {
        var material = PhysicallyBasedMaterial()
        
        switch condition {
        case .healthy:
            material.baseColor = .init(tint: UIColor(red: 0.95, green: 0.95, blue: 0.93, alpha: 1.0))
            material.roughness = .init(floatLiteral: 0.2)
            material.metallic = .init(floatLiteral: 0.0)
            material.clearcoat = .init(floatLiteral: 0.3)
            
        case .cavity:
            material.baseColor = .init(tint: UIColor(red: 0.6, green: 0.5, blue: 0.4, alpha: 1.0))
            material.roughness = .init(floatLiteral: 0.7)
            
        case .decayed:
            material.baseColor = .init(tint: UIColor(red: 0.5, green: 0.4, blue: 0.3, alpha: 1.0))
            material.roughness = .init(floatLiteral: 0.8)
            
        case .prepared:
            material.baseColor = .init(tint: UIColor(red: 0.9, green: 0.9, blue: 0.88, alpha: 1.0))
            material.roughness = .init(floatLiteral: 0.4)
            
        case .extracted:
            material.baseColor = .init(tint: .clear)
            
        case .anesthetized:
            material.baseColor = .init(tint: UIColor(red: 0.95, green: 0.95, blue: 0.93, alpha: 0.7))
            material.roughness = .init(floatLiteral: 0.2)
            
        case .cleaned:
            material.baseColor = .init(tint: UIColor(red: 0.98, green: 0.98, blue: 0.96, alpha: 1.0))
            material.roughness = .init(floatLiteral: 0.15)
            material.clearcoat = .init(floatLiteral: 0.5)
            
        case .loosened:
            material.baseColor = .init(tint: UIColor(red: 0.92, green: 0.88, blue: 0.85, alpha: 1.0))
            material.roughness = .init(floatLiteral: 0.3)
        }
        
        // Apply material to all model components recursively
        entity.model?.materials = [material]
        for child in entity.children {
            if let childModel = child as? ModelEntity {
                applyRealisticToothMaterial(to: childModel, condition: condition)
            }
        }
    }
}