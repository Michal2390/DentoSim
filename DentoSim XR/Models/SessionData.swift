//
//  SessionData.swift
//  DentoSim XR
//
//  Created by Michal Fereniec on 17/11/2025.
//

import Foundation

struct SessionData {
    var currentModule: ProcedureModule?
    var currentStepIndex: Int = 0
    var startTime: Date?
    var errors: [SessionError] = []
    var completed: Bool = false
    
    var currentStep: ProcedureStep? {
        guard let module = currentModule,
              currentStepIndex < module.steps.count else {
            return nil
        }
        return module.steps[currentStepIndex]
    }
    
    var progress: Float {
        guard let module = currentModule else { return 0 }
        return Float(currentStepIndex) / Float(module.steps.count)
    }
    
    var elapsedTime: TimeInterval {
        guard let startTime = startTime else { return 0 }
        return Date().timeIntervalSince(startTime)
    }
    
    mutating func nextStep() {
        guard let module = currentModule else { return }
        if currentStepIndex < module.steps.count - 1 {
            currentStepIndex += 1
        } else {
            completed = true
        }
    }
    
    mutating func reset() {
        currentStepIndex = 0
        startTime = nil
        errors = []
        completed = false
    }
}

struct SessionError: Identifiable {
    let id = UUID()
    let timestamp: Date
    let description: String
    let severity: Severity
    
    enum Severity {
        case minor
        case moderate
        case critical
    }
}