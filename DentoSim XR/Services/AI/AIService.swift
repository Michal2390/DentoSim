//
//  AIService.swift
//  DentoSim XR
//
//  Created by Michal Fereniec on 17/11/2025.
//

import Foundation

protocol AIService: Sendable {
    func generateText(chats: [AIChatModel]) async throws -> AIChatModel
}