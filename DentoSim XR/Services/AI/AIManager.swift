//
//  AIManager.swift
//  DentoSim XR
//
//  Created by Michal Fereniec on 17/11/2025.
//

import Foundation

@MainActor
@Observable
class AIManager {
    
    private let service: AIService
    var chatHistory: [AIChatModel] = []
    var isLoading: Bool = false
    var errorMessage: String?
    
    init(service: AIService) {
        self.service = service
    }
    
    func initializeSystemMessage(for module: ProcedureModule?) {
        chatHistory.removeAll()
        
        let systemPrompt: String
        
        if let module = module {
            systemPrompt = """
            You are an expert dental instructor assisting with the "\(module.title)" training module.
            
            Module Description: \(module.description)
            Difficulty: \(module.difficulty.rawValue)
            Estimated Time: \(module.estimatedTime) minutes
            
            Steps:
            \(module.steps.enumerated().map { index, step in
                "\(index + 1). \(step.instruction) (Tool: \(step.tool.rawValue))"
            }.joined(separator: "\n"))
            
            Your role is to:
            - Answer questions about the procedure steps
            - Explain proper techniques and best practices
            - Provide tips for safe and effective execution
            - Clarify anatomical references
            - Guide students through challenges they encounter
            
            Be clear, concise, and educational. Focus on practical guidance and safety.
            """
        } else {
            systemPrompt = """
            You are an expert dental instructor helping students explore dental anatomy and procedures.
            
            Your role is to:
            - Explain dental anatomy and terminology
            - Describe various dental procedures and tools
            - Answer questions about oral health and dentistry
            - Provide educational guidance for dental students
            
            Be clear, concise, and educational.
            """
        }
        
        let systemMessage = AIChatModel(
            role: .system,
            content: systemPrompt
        )
        
        chatHistory.append(systemMessage)
    }
    
    func sendMessage(_ content: String) async {
        guard !content.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        
        let userMessage = AIChatModel(role: .user, content: content)
        chatHistory.append(userMessage)
        
        isLoading = true
        errorMessage = nil
        
        do {
            let response = try await service.generateText(chats: chatHistory)
            chatHistory.append(response)
        } catch {
            errorMessage = error.localizedDescription
            print("AI Error: \(error)")
        }
        
        isLoading = false
    }
    
    func clearChat() {
        chatHistory.removeAll()
        errorMessage = nil
    }
}