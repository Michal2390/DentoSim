//
//  ToothType.swift
//  DentoSim XR
//
//  Created by Alex (AI Copilot) on 17/11/2025.
//


import Foundation

enum ToothType: String, CaseIterable {
    case centralIncisor
    case lateralIncisor
    case canine
    case firstPremolar
    case secondPremolar
    case firstMolar
    case secondMolar
    case thirdMolar

    static func forToothNumber(_ number: Int) -> ToothType {
        let index = (number - 1) % 16
        switch index {
        case 0: return .centralIncisor
        case 1: return .lateralIncisor
        case 2: return .canine
        case 3: return .firstPremolar
        case 4: return .secondPremolar
        case 5: return .firstMolar
        case 6: return .secondMolar
        case 7: return .thirdMolar
        case 8: return .centralIncisor
        case 9: return .lateralIncisor
        case 10: return .canine
        case 11: return .firstPremolar
        case 12: return .secondPremolar
        case 13: return .firstMolar
        case 14: return .secondMolar
        case 15: return .thirdMolar
        default: return .firstMolar
        }
    }
}
