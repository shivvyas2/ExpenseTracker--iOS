//
//  OktaConfig.swift
//  ExpenseTracker
//
//  IMPORTANT: Client IDs are PUBLIC and safe to include in mobile apps.
//  They cannot be used alone to access your system. PKCE provides the security.
//

import Foundation

struct OktaConfig {
    static let issuer = "https://integrator-2523748.okta.com/oauth2/default"
    
    static let clientId = "Ooaxzioxyr8HluG8U697"
    
    static let redirectUri = "com.okta.ios:/callback"
    static let scopes = "openid profile email"
    
    static var redirectURI: String {
        let bundleId = Bundle.main.bundleIdentifier ?? "shivvyas.ExpenseTracker"
        return "\(bundleId):/callback"
    }
}

