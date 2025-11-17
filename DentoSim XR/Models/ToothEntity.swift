//
//  ToothEntity.swift
//  DentoSim XR
//
//  Created by Alex (AI Copilot) on 17/11/2025.
//

import Foundation
import RealityKit

@MainActor
final class ToothEntity: Entity, HasModel, HasPhysics {
    let toothNumber: Int
    let toothType: ToothType
    var condition: ToothCondition
    var workProgress: Float = 0
    private(set) var crownEntity: ModelEntity
    private(set) var rootEntity: ModelEntity

    init(number: Int, type: ToothType, condition: ToothCondition, crown: ModelEntity, root: ModelEntity) async {
        self.toothNumber = number
        self.toothType = type
        self.condition = condition
        self.crownEntity = crown
        self.rootEntity = root
        super.init()
        name = "Tooth_\(number)"
        addChild(crownEntity)
        addChild(rootEntity)
        components.set(InputTargetComponent())
        await updateCollision()
    }

    required init() {
        fatalError("init() has not been implemented")
    }

    func updateCollision() async {
        var shapes: [ShapeResource] = []
        
        // Generate collision shape from crown
        if let crownModel = crownEntity.model {
            if let crownShape = try? await ShapeResource.generateStaticMesh(from: crownModel.mesh) {
                shapes.append(crownShape)
            }
        } else {
            // If crown doesn't have a direct model, check children
            for child in crownEntity.children {
                if let childModel = child as? ModelEntity, let model = childModel.model {
                    if let shape = try? await ShapeResource.generateStaticMesh(from: model.mesh) {
                        shapes.append(shape)
                    }
                }
            }
        }
        
        // Generate collision shape from root
        if let rootModel = rootEntity.model {
            if let rootShape = try? await ShapeResource.generateStaticMesh(from: rootModel.mesh) {
                shapes.append(rootShape)
            }
        }
        
        // If no shapes were generated, use a simple box collider as fallback
        if shapes.isEmpty {
            let fallbackShape = ShapeResource.generateBox(size: [0.012, 0.016, 0.010])
            shapes.append(fallbackShape)
        }
        
        components.set(CollisionComponent(shapes: shapes))
        physicsBody = PhysicsBodyComponent(mode: .static)
        physicsMotion = PhysicsMotionComponent()
    }
}