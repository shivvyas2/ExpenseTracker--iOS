//
//  AuthenticationViewModel.swift
//  ExpenseTracker
//

import Foundation
import Combine
import SwiftUI

@MainActor
class AuthenticationViewModel: ObservableObject {
    @Published var isAuthenticated = false
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var userInfo: UserInfo?
    
    private var cancellables = Set<AnyCancellable>()
    
    private let accessTokenKey = "okta_access_token"
    private let refreshTokenKey = "okta_refresh_token"
    private let idTokenKey = "okta_id_token"
    private let tokenExpiryKey = "okta_token_expiry"
    
    init() {
        checkAuthenticationStatus()
    }
    
    // MARK: - Authentication Status
    
    func checkAuthenticationStatus() {
        if let accessToken = getStoredAccessToken(), !isTokenExpired() {
            isAuthenticated = true
            loadUserInfo()
        } else {
            isAuthenticated = false
            clearStoredTokens()
        }
    }
    
    // MARK: - Login
    
    func login() {
        isLoading = true
        errorMessage = nil
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            self?.handleLoginSuccess(
                accessToken: "sample_access_token",
                refreshToken: "sample_refresh_token",
                idToken: "sample_id_token",
                expiresIn: 3600
            )
        }
    }
    
    private func handleLoginSuccess(accessToken: String, refreshToken: String, idToken: String, expiresIn: Int) {
        storeTokens(accessToken: accessToken, refreshToken: refreshToken, idToken: idToken, expiresIn: expiresIn)
        isAuthenticated = true
        isLoading = false
        loadUserInfo()
    }
    
    // MARK: - Logout
    
    func logout() {
        isLoading = true
        clearStoredTokens()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            self?.isAuthenticated = false
            self?.userInfo = nil
            self?.isLoading = false
        }
    }
    
    // MARK: - Token Management
    
    private func storeTokens(accessToken: String, refreshToken: String, idToken: String, expiresIn: Int) {
        let defaults = UserDefaults.standard
        defaults.set(accessToken, forKey: accessTokenKey)
        defaults.set(refreshToken, forKey: refreshTokenKey)
        defaults.set(idToken, forKey: idTokenKey)
        
        let expiryDate = Date().addingTimeInterval(TimeInterval(expiresIn))
        defaults.set(expiryDate, forKey: tokenExpiryKey)
    }
    
    private func getStoredAccessToken() -> String? {
        return UserDefaults.standard.string(forKey: accessTokenKey)
    }
    
    private func getStoredRefreshToken() -> String? {
        return UserDefaults.standard.string(forKey: refreshTokenKey)
    }
    
    private func isTokenExpired() -> Bool {
        guard let expiryDate = UserDefaults.standard.object(forKey: tokenExpiryKey) as? Date else {
            return true
        }
        return expiryDate < Date()
    }
    
    private func clearStoredTokens() {
        let defaults = UserDefaults.standard
        defaults.removeObject(forKey: accessTokenKey)
        defaults.removeObject(forKey: refreshTokenKey)
        defaults.removeObject(forKey: idTokenKey)
        defaults.removeObject(forKey: tokenExpiryKey)
    }
    
    // MARK: - Token Refresh
    
    func refreshTokenIfNeeded() async {
        guard isTokenExpired(), let refreshToken = getStoredRefreshToken() else {
            return
        }
        
        print("Refreshing token...")
    }
    
    // MARK: - User Info
    
    private func loadUserInfo() {
        userInfo = UserInfo(
            email: "user@example.com",
            name: "User Name",
            sub: "user123"
        )
    }
    
    // MARK: - Session Management
    
    func validateSession() {
        if isTokenExpired() {
            Task {
                await refreshTokenIfNeeded()
                if isTokenExpired() {
                    logout()
                }
            }
        }
    }
    
    // MARK: - Handle Callback
    
    func handleCallback(url: URL) {
        print("Received callback URL: \(url)")
        
        if url.scheme == "shivvyas.ExpenseTracker" || url.scheme == "com.okta.ios" {
            handleLoginSuccess(
                accessToken: "sample_access_token",
                refreshToken: "sample_refresh_token",
                idToken: "sample_id_token",
                expiresIn: 3600
            )
        }
    }
}

// MARK: - User Info Model

struct UserInfo: Codable {
    let email: String
    let name: String
    let sub: String
}

