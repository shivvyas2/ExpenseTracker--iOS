//
//  OktaConfig.swift
//  ExpenseTracker
//

import Foundation

struct OktaConfig {
    static let issuer = "https://YOUR_OKTA_DOMAIN.okta.com/oauth2/default"
    static let clientId = "YOUR_CLIENT_ID"
    static let redirectUri = "com.okta.ios:/callback"
    static let scopes = "openid profile email"
    
    static var redirectURI: String {
        let bundleId = Bundle.main.bundleIdentifier ?? "shivvyas.ExpenseTracker"
        return "\(bundleId):/callback"
    }
}

