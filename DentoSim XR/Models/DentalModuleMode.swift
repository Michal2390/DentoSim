//
//  DentalModuleMode.swift
//  DentoSim XR
//
//  Created by Alex (AI Copilot) on 17/11/2025.
//


import Foundation

enum DentalModuleMode: Equatable {
    case exploration
    case dentalExam
    case wisdomExtraction
    case cavityPreparation
    case rootCanal

    init(module: ProcedureModule?) {
        guard let module else {
            self = .exploration
            return
        }
        switch module.id {
        case "exam_basic": self = .dentalExam
        case "extraction_wisdom": self = .wisdomExtraction
        case "cavity_class1": self = .cavityPreparation
        case "endo_basic": self = .rootCanal
        default: self = .exploration
        }
    }
}
