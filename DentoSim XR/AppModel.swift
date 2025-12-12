//
//  AppModel.swift
//  DentoSim XR
//
//  Created by Michal Fereniec on 17/11/2025.
//

import SwiftUI

@MainActor
@Observable
class AppModel {
    let immersiveSpaceID = "ImmersiveSpace"
    
    enum ImmersiveSpaceState {
        case closed
        case inTransition
        case open
    }
    
    var immersiveSpaceState = ImmersiveSpaceState.closed
    var sessionData = SessionData()
    var selectedTool: DentalTool = .mirror
    var isTrainingMode: Bool = true
    var showInstructions: Bool = true
    var selectedToothID: Int? = nil
    var showChat: Bool = false
    
    func startProcedure(_ module: ProcedureModule) {
        sessionData.currentModule = module
        sessionData.startTime = Date()
        sessionData.reset()
        selectedToothID = module.targetTooth
    }
    
    func completeCurrentStep() {
        sessionData.nextStep()
    }
    
    func recordError(_ description: String, severity: SessionError.Severity) {
        let error = SessionError(
            timestamp: Date(),
            description: description,
            severity: severity
        )
        sessionData.errors.append(error)
    }
    
    func endProcedure() {
        sessionData.completed = true
    }
    
    func resetSession() {
        sessionData = SessionData()
        selectedTool = .mirror
        selectedToothID = nil
    }
    
    var performanceScore: Int {
        guard sessionData.completed else { return 0 }
        guard let module = sessionData.currentModule else { return 0 }
        
        let errorPenalty = sessionData.errors.reduce(0) { sum, error in
            switch error.severity {
            case .minor: return sum + 2
            case .moderate: return sum + 5
            case .critical: return sum + 10
            }
        }
        
        let timePenalty = max(0, Int(sessionData.elapsedTime / 60) - module.estimatedTime)
        
        let baseScore = 100
        return max(0, baseScore - errorPenalty - timePenalty)
    }
}