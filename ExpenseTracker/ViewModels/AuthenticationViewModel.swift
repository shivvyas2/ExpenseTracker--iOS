//
//  AuthenticationViewModel.swift
//  ExpenseTracker
//

import Foundation
import Combine
import SwiftUI
import os.log

import okta-oidcios


extension Logger {
    private static var subsystem = Bundle.main.bundleIdentifier!
    static let auth = Logger(subsystem: subsystem, category: "Authentication")
}

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
    private var signupUserEmail: String?
    private var signupUserName: String?
    
    // Check if Okta SDK is available
    private var isOktaSDKAvailable: Bool {
        // Check if OktaOidc class is available at runtime
        // This will return true once Okta SDK package is added and imported
        let oktaClass = NSClassFromString("OktaOidc")
        return oktaClass != nil
    }
    
    init() {
        Logger.auth.info("🔐 AuthenticationViewModel initialized")
        Logger.auth.info("📦 Okta SDK Status: \(self.isOktaSDKAvailable ? "✅ AVAILABLE" : "❌ NOT AVAILABLE - Using placeholder")")
        Logger.auth.info("🔧 Okta Config - Issuer: \(OktaConfig.issuer)")
        Logger.auth.info("🔧 Okta Config - Client ID: \(OktaConfig.clientId)")
        Logger.auth.info("🔧 Okta Config - Redirect URI: \(OktaConfig.redirectURI)")
        checkAuthenticationStatus()
    }
    
    // MARK: - Authentication Status
    
    func checkAuthenticationStatus() {
        Logger.auth.info("🔍 Checking authentication status...")
        
        if isOktaSDKAvailable {
        // Try to restore state manager from secure storage
        Logger.auth.info("📦 Attempting to restore Okta state manager from secure storage...")
        if let stateManager = OktaOidcStateManager.readFromSecureStorage() {
            Logger.auth.info("✅ Okta state manager found in secure storage")
            self.stateManager = stateManager
            
                if let idToken = stateManager.idToken {
                    // Check if token is expired using tokenManager
                    let expiresIn = stateManager.tokenManager.expiresIn
                    let isExpired = expiresIn <= 0 || Date().timeIntervalSince1970 >= expiresIn
                    
                    if !isExpired {
                Logger.auth.info("✅ Valid ID token found - User is authenticated")
                isAuthenticated = true
                decodeUserInfo(from: idToken)
            } else {
                Logger.auth.info("⚠️ Token expired or invalid - Attempting refresh...")
                Task {
                    await refreshTokenIfNeeded()
                }
                    }
                } else {
                    Logger.auth.info("❌ No ID token found")
                    isAuthenticated = false
                    clearStoredTokens()
            }
        } else {
            Logger.auth.info("❌ No Okta state manager found - User not authenticated")
            isAuthenticated = false
            clearStoredTokens()
        }
        } else {
        // Placeholder check for now
        Logger.auth.info("🔧 Using PLACEHOLDER authentication check (Okta SDK not available)")
        if let accessToken = getStoredAccessToken(), !isTokenExpired() {
            Logger.auth.info("✅ Placeholder token found - User authenticated (PLACEHOLDER MODE)")
            isAuthenticated = true
            loadUserInfo()
        } else {
            Logger.auth.info("❌ No valid token found - User not authenticated")
            isAuthenticated = false
            clearStoredTokens()
            }
        }
    }
    
    // MARK: - Login
    
    func login() {
        Logger.auth.info("🚀 Login initiated")
        Logger.auth.info("📦 Okta SDK Status: \(self.isOktaSDKAvailable ? "✅ Using Okta SDK" : "❌ Using PLACEHOLDER")")
        isLoading = true
        errorMessage = nil
        
        if isOktaSDKAvailable {
        Logger.auth.info("🔧 Creating Okta OIDC configuration...")
        Logger.auth.info("   - Issuer: \(OktaConfig.issuer)")
        Logger.auth.info("   - Client ID: \(OktaConfig.clientId)")
        Logger.auth.info("   - Redirect URI: \(OktaConfig.redirectURI)")
        Logger.auth.info("   - Scopes: \(OktaConfig.scopes)")
        
        let config = OktaOidcConfig(
            issuer: OktaConfig.issuer,
            clientId: OktaConfig.clientId,
            redirectUri: OktaConfig.redirectURI,
            scopes: OktaConfig.scopes
        )
        
        Logger.auth.info("🔐 Initiating Okta sign-in flow...")
        OktaOidc.default().signIn(with: config) { [weak self] stateManager, error in
            DispatchQueue.main.async {
                guard let self = self else { return }
                
                if let error = error {
                    Logger.auth.error("❌ Okta login failed: \(error.localizedDescription)")
                    self.errorMessage = error.localizedDescription
                    self.isLoading = false
                } else if let stateManager = stateManager {
                    Logger.auth.info("✅ Okta login successful - State manager received")
                    self.handleLoginSuccess(stateManager: stateManager)
                }
            }
        }
        } else {
        // Placeholder for now - will be replaced with Okta SDK
        Logger.auth.warning("⚠️ Using PLACEHOLDER login (Okta SDK not available)")
        Logger.auth.info("   Simulating login delay...")
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            Logger.auth.info("✅ PLACEHOLDER login successful (not using Okta)")
            self?.handleLoginSuccess(
                accessToken: "sample_access_token",
                refreshToken: "sample_refresh_token",
                idToken: "sample_id_token",
                expiresIn: 3600
            )
            }
        }
    }
    
    #if canImport(OktaOidc)
    private func handleLoginSuccess(stateManager: OktaOidcStateManager) {
        Logger.auth.info("✅ Okta login success handler called")
        Logger.auth.info("   - Access token: \(stateManager.accessToken?.prefix(20) ?? "nil")...")
        Logger.auth.info("   - Refresh token: \(stateManager.refreshToken != nil ? "Present" : "Nil")")
        Logger.auth.info("   - ID token: \(stateManager.idToken?.prefix(20) ?? "nil")...")
        
        self.stateManager = stateManager
        stateManager.writeToSecureStorage()
        Logger.auth.info("✅ Tokens stored in secure storage")
        
        if let accessToken = stateManager.accessToken {
            let expiresIn = Int(stateManager.tokenManager.expiresIn)
            storeTokens(
                accessToken: accessToken,
                refreshToken: stateManager.refreshToken ?? "",
                idToken: stateManager.idToken ?? "",
                expiresIn: expiresIn
            )
        }
        
        if let idToken = stateManager.idToken {
            decodeUserInfo(from: idToken)
        }
        
        isAuthenticated = true
        isLoading = false
        Logger.auth.info("✅ User authenticated via Okta")
    }
    #endif
    
    private func handleLoginSuccess(accessToken: String, refreshToken: String, idToken: String, expiresIn: Int) {
        Logger.auth.info("✅ Login success handler called")
        Logger.auth.info("   - Access token length: \(accessToken.count) characters")
        Logger.auth.info("   - Refresh token length: \(refreshToken.count) characters")
        Logger.auth.info("   - ID token length: \(idToken.count) characters")
        Logger.auth.info("   - Token expires in: \(expiresIn) seconds")
        
        storeTokens(accessToken: accessToken, refreshToken: refreshToken, idToken: idToken, expiresIn: expiresIn)
        isAuthenticated = true
        isLoading = false
        Logger.auth.info("✅ User authenticated successfully")
        loadUserInfo()
    }
    
    // MARK: - Logout
    
    func logout() {
        Logger.auth.info("🚪 Logout initiated")
        Logger.auth.info("📦 Okta SDK Status: \(self.isOktaSDKAvailable ? "✅ Using Okta SDK" : "❌ Using PLACEHOLDER")")
        isLoading = true
        
        if isOktaSDKAvailable {
        Logger.auth.info("🔐 Attempting Okta sign-out...")
            if let stateManager = stateManager ?? OktaOidcStateManager.readFromSecureStorage() {
            Logger.auth.info("✅ Okta state manager found - Signing out from Okta")
            OktaOidc.default().signOutOfOkta(with: stateManager) { [weak self] error in
                DispatchQueue.main.async {
                    guard let self = self else { return }
                    
                    if let error = error {
                        Logger.auth.error("❌ Okta sign-out error: \(error.localizedDescription)")
                    } else {
                        Logger.auth.info("✅ Successfully signed out from Okta")
                    }
                    
                    stateManager.clear()
                    self.clearStoredTokens()
                    self.isAuthenticated = false
                    self.userInfo = nil
                    self.stateManager = nil
                    self.isLoading = false
                    Logger.auth.info("✅ Logout complete (Okta)")
                }
            }
        } else {
            Logger.auth.warning("⚠️ No Okta state manager found - Clearing local tokens only")
            clearStoredTokens()
            isAuthenticated = false
            userInfo = nil
            stateManager = nil
            isLoading = false
        }
        } else {
        // Placeholder for now
        Logger.auth.warning("⚠️ Using PLACEHOLDER logout (Okta SDK not available)")
        clearStoredTokens()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            Logger.auth.info("✅ PLACEHOLDER logout complete")
            self?.isAuthenticated = false
            self?.userInfo = nil
            self?.isLoading = false
            }
        }
    }
    
    // MARK: - Token Management
    
    private func storeTokens(accessToken: String, refreshToken: String, idToken: String, expiresIn: Int) {
        Logger.auth.info("💾 Storing tokens...")
        Logger.auth.info("   - Access token: \(accessToken.prefix(20))...")
        Logger.auth.info("   - Refresh token: \(refreshToken.isEmpty ? "Empty" : "\(refreshToken.prefix(20))...")")
        Logger.auth.info("   - ID token: \(idToken.prefix(20))...")
        Logger.auth.info("   - Expires in: \(expiresIn) seconds")
        
        let defaults = UserDefaults.standard
        defaults.set(accessToken, forKey: accessTokenKey)
        defaults.set(refreshToken, forKey: refreshTokenKey)
        defaults.set(idToken, forKey: idTokenKey)
        
        let expiryDate = Date().addingTimeInterval(TimeInterval(expiresIn))
        defaults.set(expiryDate, forKey: tokenExpiryKey)
        Logger.auth.info("✅ Tokens stored in UserDefaults")
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
        Logger.auth.info("🗑️ Clearing stored tokens...")
        let defaults = UserDefaults.standard
        defaults.removeObject(forKey: accessTokenKey)
        defaults.removeObject(forKey: refreshTokenKey)
        defaults.removeObject(forKey: idTokenKey)
        defaults.removeObject(forKey: tokenExpiryKey)
        Logger.auth.info("✅ Tokens cleared from UserDefaults")
    }
    
    // MARK: - Token Refresh
    
    func refreshTokenIfNeeded() async {
        guard isTokenExpired(), let refreshToken = getStoredRefreshToken() else {
            return
        }
        
        print("Refreshing token...")
    }
    
    // MARK: - User Info
    
    private func decodeUserInfo(from idToken: String) {
        Logger.auth.info("🔍 Decoding user info from ID token...")
        
        // Decode JWT token (basic implementation - in production, use a proper JWT library)
        let parts = idToken.components(separatedBy: ".")
        guard parts.count == 3 else {
            Logger.auth.warning("⚠️ Invalid ID token format")
            loadUserInfo() // Fallback to placeholder
            return
        }
        
        // Decode the payload (second part)
        var base64 = parts[1]
        // Add padding if needed
        let remainder = base64.count % 4
        if remainder > 0 {
            base64 = base64.padding(toLength: base64.count + 4 - remainder, withPad: "=", startingAt: 0)
        }
        
        guard let data = Data(base64Encoded: base64),
              let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            Logger.auth.warning("⚠️ Failed to decode ID token payload")
            loadUserInfo() // Fallback to placeholder
            return
        }
        
        let email = json["email"] as? String ?? json["sub"] as? String ?? signupUserEmail ?? "user@example.com"
        let name = (json["name"] as? String) ?? 
                   ((json["given_name"] as? String ?? "") + " " + (json["family_name"] as? String ?? "")).trimmingCharacters(in: .whitespaces) ??
                   signupUserName ?? "User Name"
        let sub = json["sub"] as? String ?? email.replacingOccurrences(of: "@", with: "_")
        
        userInfo = UserInfo(
            email: email,
            name: name.isEmpty ? "User" : name,
            sub: sub
        )
        
        Logger.auth.info("👤 User info decoded - Email: \(email), Name: \(name)")
    }
    
    private func loadUserInfo() {
        // Use signup data if available, otherwise use placeholder
        let email = signupUserEmail ?? "user@example.com"
        let name = signupUserName ?? "User Name"
        let sub = signupUserEmail?.replacingOccurrences(of: "@", with: "_") ?? "user123"
        
        userInfo = UserInfo(
            email: email,
            name: name,
            sub: sub
        )
        
        Logger.auth.info("👤 User info loaded - Email: \(email), Name: \(name)")
    }
    
    // MARK: - Session Management
    
    func validateSession() {
        Logger.auth.info("🔍 Validating session...")
        if isTokenExpired() {
            Logger.auth.warning("⚠️ Token expired - Attempting refresh...")
            Task {
                await refreshTokenIfNeeded()
                if isTokenExpired() {
                    Logger.auth.warning("⚠️ Token refresh failed - Logging out")
                    logout()
                } else {
                    Logger.auth.info("✅ Token refreshed successfully")
                }
            }
        } else {
            Logger.auth.info("✅ Session valid")
        }
    }
    
    // MARK: - Handle Callback
    
    func handleCallback(url: URL) {
        Logger.auth.info("📞 Callback received")
        Logger.auth.info("   - URL: \(url.absoluteString)")
        Logger.auth.info("   - Scheme: \(url.scheme ?? "nil")")
        Logger.auth.info("📦 Okta SDK Status: \(self.isOktaSDKAvailable ? "✅ Using Okta SDK" : "❌ Using PLACEHOLDER")")
        
        if isOktaSDKAvailable {
        Logger.auth.info("🔐 Processing Okta redirect callback...")
        OktaOidc.default().receiveRedirect(url) { [weak self] stateManager, error in
            DispatchQueue.main.async {
                guard let self = self else { return }
                
                if let error = error {
                    Logger.auth.error("❌ Okta callback error: \(error.localizedDescription)")
                    self.errorMessage = error.localizedDescription
                    self.isLoading = false
                } else if let stateManager = stateManager {
                    Logger.auth.info("✅ Okta callback successful - State manager received")
                    self.handleLoginSuccess(stateManager: stateManager)
                }
            }
        }
        } else {
        // Placeholder for now
        Logger.auth.warning("⚠️ Using PLACEHOLDER callback handler (Okta SDK not available)")
        
        if url.scheme == "shivvyas.ExpenseTracker" || url.scheme == "com.okta.ios" {
            Logger.auth.info("✅ Valid callback scheme - Processing placeholder login")
            handleLoginSuccess(
                accessToken: "sample_access_token",
                refreshToken: "sample_refresh_token",
                idToken: "sample_id_token",
                expiresIn: 3600
            )
        } else {
            Logger.auth.warning("⚠️ Invalid callback scheme: \(url.scheme ?? "nil")")
            }
        }
    }
    
    // MARK: - Social Login
    
    func loginWithGoogle() {
        Logger.auth.info("🔵 Google login initiated")
        Logger.auth.info("📦 Okta SDK Status: \(self.isOktaSDKAvailable ? "✅ Using Okta SDK" : "❌ Using PLACEHOLDER")")
        isLoading = true
        errorMessage = nil
        
        // Okta handles social login through the same OAuth flow
        // The user will be redirected to Google login via Okta
        if self.isOktaSDKAvailable {
            Logger.auth.info("🔐 Redirecting to Google via Okta OAuth flow...")
        } else {
            Logger.auth.warning("⚠️ Using PLACEHOLDER Google login (Okta SDK not available)")
        }
        login()
    }
    
    func loginWithApple() {
        Logger.auth.info("🍎 Apple login initiated")
        Logger.auth.info("📦 Okta SDK Status: \(self.isOktaSDKAvailable ? "✅ Using Okta SDK" : "❌ Using PLACEHOLDER")")
        isLoading = true
        errorMessage = nil
        
        // Okta handles social login through the same OAuth flow
        // The user will be redirected to Apple login via Okta
        if self.isOktaSDKAvailable {
            Logger.auth.info("🔐 Redirecting to Apple via Okta OAuth flow...")
        } else {
            Logger.auth.warning("⚠️ Using PLACEHOLDER Apple login (Okta SDK not available)")
        }
        login()
    }
    
    // MARK: - Signup
    
    func signup(firstName: String, lastName: String, email: String, password: String) {
        Logger.auth.info("📝 Signup initiated")
        Logger.auth.info("   - First Name: \(firstName)")
        Logger.auth.info("   - Last Name: \(lastName)")
        Logger.auth.info("   - Email: \(email)")
        Logger.auth.info("   - Password length: \(password.count) characters")
        Logger.auth.info("📦 Okta SDK Status: \(self.isOktaSDKAvailable ? "✅ Using Okta SDK" : "❌ Using PLACEHOLDER")")
        
        isLoading = true
        errorMessage = nil
        
        // Store user info for later use
        signupUserEmail = email
        signupUserName = "\(firstName) \(lastName)"
        
        if self.isOktaSDKAvailable {
            // Use Okta's self-service registration API
            Logger.auth.info("🔐 Initiating Okta user registration...")
            registerUserWithOkta(firstName: firstName, lastName: lastName, email: email, password: password)
        } else {
            // Placeholder fallback
        Logger.auth.warning("⚠️ Using PLACEHOLDER signup (Okta SDK not available)")
        Logger.auth.info("   Simulating signup process...")
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { [weak self] in
                guard let self = self else { return }
            Logger.auth.info("✅ PLACEHOLDER signup complete (not using Okta)")
                
                // Simulate successful signup and auto-login
                Logger.auth.info("🔄 Auto-logging in after successful signup...")
                self.handleLoginSuccess(
                    accessToken: "sample_access_token_\(email)",
                    refreshToken: "sample_refresh_token_\(email)",
                    idToken: "sample_id_token_\(email)",
                    expiresIn: 3600
                )
                Logger.auth.info("✅ Signup and auto-login successful")
            }
        }
    }
    
    private func registerUserWithOkta(firstName: String, lastName: String, email: String, password: String) {
        // Extract the Okta domain from the issuer URL
        // e.g., "https://eunos-integrator-2523748.okta.com/oauth2/default" -> "eunos-integrator-2523748.okta.com"
        guard let issuerURL = URL(string: OktaConfig.issuer),
              let host = issuerURL.host else {
            Logger.auth.error("❌ Invalid Okta issuer URL")
            errorMessage = "Invalid Okta configuration"
            isLoading = false
            return
        }
        
        let oktaDomain = host
        
        // Use Okta's self-service registration endpoint
        // Note: This requires self-service registration to be enabled in Okta admin console
        // Path: Security > API > Self-Service Registration
        let registrationURL = "https://\(oktaDomain)/api/v1/registration"
        
        Logger.auth.info("🔐 Creating user via Okta self-service registration...")
        Logger.auth.info("   - Registration URL: \(registrationURL)")
        Logger.auth.info("   - Client ID: \(OktaConfig.clientId)")
        
        guard let url = URL(string: registrationURL) else {
            Logger.auth.error("❌ Invalid registration URL")
            errorMessage = "Invalid registration URL"
            isLoading = false
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        
        // Okta self-service registration payload
        let registrationData: [String: Any] = [
            "registration": [
                "clientId": OktaConfig.clientId
            ],
            "userProfile": [
                "firstName": firstName,
                "lastName": lastName,
                "email": email,
                "login": email
            ],
            "credentials": [
                "password": [
                    "value": password
                ]
            ]
        ]
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: registrationData)
            Logger.auth.info("📤 Registration payload prepared")
        } catch {
            Logger.auth.error("❌ Failed to serialize registration data: \(error.localizedDescription)")
            errorMessage = "Failed to prepare registration data"
            isLoading = false
            return
        }
        
        Logger.auth.info("📤 Sending registration request to Okta...")
        
        URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            DispatchQueue.main.async {
                guard let self = self else { return }
                
                if let error = error {
                    Logger.auth.error("❌ Okta registration network error: \(error.localizedDescription)")
                    self.errorMessage = "Registration failed: \(error.localizedDescription)"
                    self.isLoading = false
                    return
                }
                
                guard let httpResponse = response as? HTTPURLResponse else {
                    Logger.auth.error("❌ Invalid response from Okta")
                    self.errorMessage = "Invalid response from server"
                    self.isLoading = false
                    return
                }
                
                Logger.auth.info("📥 Okta API response: \(httpResponse.statusCode)")
                
                // Log response body for debugging
                if let data = data, let responseString = String(data: data, encoding: .utf8) {
                    Logger.auth.info("📥 Response body: \(responseString)")
                }
                
                if httpResponse.statusCode == 200 || httpResponse.statusCode == 201 {
                    Logger.auth.info("✅ User registered successfully with Okta")
                    
                    // After successful registration, automatically log the user in
                    Logger.auth.info("🔄 Auto-logging in after successful registration...")
                    self.login()
                } else {
                    // Try to parse error message from response
                    var errorMsg = "Registration failed"
                    if let data = data {
                        if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
                            if let errorSummary = json["errorSummary"] as? String {
                                errorMsg = errorSummary
                            } else if let errorCauses = json["errorCauses"] as? [[String: Any]],
                                      let firstCause = errorCauses.first,
                                      let causeSummary = firstCause["errorSummary"] as? String {
                                errorMsg = causeSummary
                            } else if let errorString = String(data: data, encoding: .utf8) {
                                Logger.auth.info("📥 Full error response: \(errorString)")
                            }
                        } else if let errorString = String(data: data, encoding: .utf8) {
                            errorMsg = "Registration failed: \(errorString)"
                        }
                    }
                    
                    Logger.auth.error("❌ Okta registration failed (Status \(httpResponse.statusCode)): \(errorMsg)")
                    
                    // Provide helpful error message
                    if httpResponse.statusCode == 400 {
                        errorMsg = "Invalid registration data. Please check your information and try again."
                    } else if httpResponse.statusCode == 403 {
                        errorMsg = "Self-service registration is not enabled. Please contact support."
                    } else if httpResponse.statusCode == 409 {
                        errorMsg = "An account with this email already exists. Please sign in instead."
                    } else {
                        errorMsg = "Registration failed. Please try again later."
                    }
                    
                    self.errorMessage = errorMsg
                    self.isLoading = false
                }
            }
        }.resume()
    }
    
    func signupWithGoogle() {
        Logger.auth.info("📝 Google signup initiated")
        Logger.auth.info("📦 Okta SDK Status: \(self.isOktaSDKAvailable ? "✅ Using Okta SDK" : "❌ Using PLACEHOLDER")")
        isLoading = true
        errorMessage = nil
        
        // Okta handles social signup through the same OAuth flow
        // The user will be redirected to Google signup/login via Okta
        Logger.auth.info("🔐 Redirecting to Google via Okta...")
        loginWithGoogle()
    }
    
    func signupWithApple() {
        Logger.auth.info("📝 Apple signup initiated")
        Logger.auth.info("📦 Okta SDK Status: \(self.isOktaSDKAvailable ? "✅ Using Okta SDK" : "❌ Using PLACEHOLDER")")
        isLoading = true
        errorMessage = nil
        
        // Okta handles social signup through the same OAuth flow
        // The user will be redirected to Apple signup/login via Okta
        Logger.auth.info("🔐 Redirecting to Apple via Okta...")
        loginWithApple()
    }
}

// MARK: - User Info Model

struct UserInfo: Codable {
    let email: String
    let name: String
    let sub: String
}

