//
//  AIChatModel.swift
//  DentoSim XR
//
//  Created by Michal Fereniec on 17/11/2025.
//

import Foundation

struct AIChatModel: Codable, Identifiable, Hashable {
    let id: String
    let role: AIChatRole
    let message: String
    let timestamp: Date
    
    init(id: String = UUID().uuidString, role: AIChatRole, content: String, timestamp: Date = Date()) {
        self.id = id
        self.role = role
        self.message = content
        self.timestamp = timestamp
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case role
        case message
        case timestamp
    }
}

enum AIChatRole: String, Codable {
    case user
    case assistant
    case system
    case tool
}