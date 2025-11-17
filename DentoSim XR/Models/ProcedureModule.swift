//
//  ProcedureModule.swift
//  DentoSim XR
//
//  Created by Michal Fereniec on 17/11/2025.
//

import Foundation

struct ProcedureModule: Identifiable, Hashable {
    static func == (lhs: ProcedureModule, rhs: ProcedureModule) -> Bool {
        lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    let id: String
    let title: String
    let description: String
    let difficulty: Difficulty
    let estimatedTime: Int
    let steps: [ProcedureStep]
    let targetTooth: Int?
    
    enum Difficulty: String {
        case beginner = "Beginner"
        case intermediate = "Intermediate"
        case advanced = "Advanced"
    }
}

struct ProcedureStep: Identifiable, Hashable {
    let id: String
    let instruction: String
    let tool: DentalTool
    let targetArea: String
    let tip: String?
    let warningThreshold: Float?
}

enum DentalTool: String, CaseIterable {
    case mirror = "Mirror"
    case explorer = "Explorer"
    case excavator = "Excavator"
    case drill = "Drill"
    case forceps = "Forceps"
    case elevator = "Elevator"
    case syringe = "Syringe"
    case scaler = "Scaler"
    
    var iconName: String {
        switch self {
        case .mirror: return "circle.circle"
        case .explorer: return "wand.and.rays"
        case .excavator: return "hammer"
        case .drill: return "tornado"
        case .forceps: return "wrench.and.screwdriver"
        case .elevator: return "arrow.up.circle"
        case .syringe: return "syringe"
        case .scaler: return "paintbrush.pointed"
        }
    }
}