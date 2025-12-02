//
//  AuthenticationViewModelWithOkta.swift
//  ExpenseTracker
//

import Foundation
import Combine
import SwiftUI
// import OktaOidc

@MainActor
class AuthenticationViewModel: ObservableObject {
    @Published var isAuthenticated = false
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var userInfo: UserInfo?
    
    private var cancellables = Set<AnyCancellable>()
    private var stateManager: OktaOidcStateManager?
    
    private let accessTokenKey = "okta_access_token"
    private let refreshTokenKey = "okta_refresh_token"
    private let idTokenKey = "okta_id_token"
    private let tokenExpiryKey = "okta_token_expiry"
    
    init() {
        checkAuthenticationStatus()
    }
    
    // MARK: - Authentication Status
    
    func checkAuthenticationStatus() {
        if let stateManager = OktaOidcStateManager.readFromSecureStorage() {
            self.stateManager = stateManager
            
            if let idToken = stateManager.idToken, !isTokenExpired(idToken: idToken) {
                isAuthenticated = true
                decodeUserInfo(from: idToken)
            } else {
                Task {
                    await refreshTokenIfNeeded()
                }
            }
        } else {
            isAuthenticated = false
            clearStoredTokens()
        }
    }
    
    // MARK: - Login
    
    func login() {
        isLoading = true
        errorMessage = nil
        
        let config = OktaOidcConfig(
            issuer: OktaConfig.issuer,
            clientId: OktaConfig.clientId,
            redirectUri: OktaConfig.redirectURI,
            scopes: OktaConfig.scopes
        )
        
        OktaOidc.default().signIn(with: config) { [weak self] stateManager, error in
            DispatchQueue.main.async {
                guard let self = self else { return }
                
                if let error = error {
                    self.errorMessage = error.localizedDescription
                    self.isLoading = false
                } else if let stateManager = stateManager {
                    self.handleLoginSuccess(stateManager: stateManager)
                }
            }
        }
    }
    
    private func handleLoginSuccess(stateManager: OktaOidcStateManager) {
        self.stateManager = stateManager
        stateManager.writeToSecureStorage()
        
        if let accessToken = stateManager.accessToken {
            storeTokens(
                accessToken: accessToken,
                refreshToken: stateManager.refreshToken ?? "",
                idToken: stateManager.idToken ?? "",
                expiresIn: Int(stateManager.tokenManager.expiresIn)
            )
        }
        
        if let idToken = stateManager.idToken {
            decodeUserInfo(from: idToken)
        }
        
        isAuthenticated = true
        isLoading = false
    }
    
    // MARK: - Logout
    
    func logout() {
        isLoading = true
        
        if let stateManager = stateManager ?? OktaOidcStateManager.readFromSecureStorage() {
            OktaOidc.default().signOutOfOkta(with: stateManager) { [weak self] error in
                DispatchQueue.main.async {
                    guard let self = self else { return }
                    
                    if let error = error {
                        print("Error signing out: \(error.localizedDescription)")
                    }
                    
                    stateManager.clear()
                    self.clearStoredTokens()
                    self.isAuthenticated = false
                    self.userInfo = nil
                    self.stateManager = nil
                    self.isLoading = false
                }
            }
        } else {
            clearStoredTokens()
            isAuthenticated = false
            userInfo = nil
            stateManager = nil
            isLoading = false
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
    
    private func isTokenExpired(idToken: String) -> Bool {
        if let expiryDate = UserDefaults.standard.object(forKey: tokenExpiryKey) as? Date {
            return expiryDate < Date()
        }
        return true
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
        guard let stateManager = stateManager ?? OktaOidcStateManager.readFromSecureStorage() else {
            return
        }
        
        if stateManager.tokenManager.shouldRefresh() {
            do {
                try await stateManager.renew()
                stateManager.writeToSecureStorage()
                
                if let idToken = stateManager.idToken {
                    decodeUserInfo(from: idToken)
                }
            } catch {
                print("Error refreshing token: \(error.localizedDescription)")
                await MainActor.run {
                    logout()
                }
            }
        }
    }
    
    // MARK: - User Info
    
    private func decodeUserInfo(from idToken: String) {
        let parts = idToken.components(separatedBy: ".")
        guard parts.count == 3 else { return }
        
        if let payloadData = Data(base64Encoded: parts[1], options: .ignoreUnknownCharacters),
           let payload = try? JSONSerialization.jsonObject(with: payloadData) as? [String: Any] {
            
            let email = payload["email"] as? String ?? ""
            let name = payload["name"] as? String ?? (payload["preferred_username"] as? String ?? "")
            let sub = payload["sub"] as? String ?? ""
            
            userInfo = UserInfo(email: email, name: name, sub: sub)
        }
    }
    
    // MARK: - Session Management
    
    func validateSession() {
        guard let stateManager = stateManager ?? OktaOidcStateManager.readFromSecureStorage() else {
            logout()
            return
        }
        
        if stateManager.tokenManager.shouldRefresh() {
            Task {
                await refreshTokenIfNeeded()
            }
        }
    }
    
    // MARK: - Handle Callback
    
    func handleCallback(url: URL) {
        OktaOidc.default().receiveRedirect(url) { [weak self] stateManager, error in
            DispatchQueue.main.async {
                guard let self = self else { return }
                
                if let error = error {
                    self.errorMessage = error.localizedDescription
                    self.isLoading = false
                } else if let stateManager = stateManager {
                    self.handleLoginSuccess(stateManager: stateManager)
                }
            }
        }
    }
}

// MARK: - User Info Model

struct UserInfo: Codable {
    let email: String
    let name: String
    let sub: String
}

