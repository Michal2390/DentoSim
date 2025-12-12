//
//  APIConfiguration.swift
//  DentoSim XR
//
//  Created by Michal Fereniec on 17/11/2025.
//

import Foundation

struct APIConfiguration {
    
    /// SECURITY WARNING:
    /// This API key is currently hardcoded and should NOT be used in production.
    ///
    /// For production apps, consider:
    /// 1. Environment variables (via Xcode schemes or .xcconfig files)
    /// 2. Secure backend API that proxies OpenAI requests
    /// 3. Keychain storage for user-provided keys
    /// 4. Server-side API key management
    ///
    /// Hardcoded keys in source code can be:
    /// - Extracted from compiled binaries
    /// - Exposed in version control
    /// - Used by unauthorized parties if the app is decompiled
    ///
    /// IMPORTANT: Regenerate this key before deploying to TestFlight or App Store!
    static let openAIKey = "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"
}