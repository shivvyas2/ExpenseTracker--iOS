//
//  ExpenseTrackerApp.swift
//  ExpenseTracker
//
//  Created by Shiv Vyas on 7/5/24.
//

import SwiftUI
import os.log

extension Logger {
    private static var subsystem = Bundle.main.bundleIdentifier!
    static let app = Logger(subsystem: subsystem, category: "App")
}

@main
struct ExpenseTrackerApp: App {
    @StateObject var authViewModel = AuthenticationViewModel()
    
    init() {
        Logger.app.info("🚀 ExpenseTracker App Starting")
        Logger.app.info("📱 Bundle ID: \(Bundle.main.bundleIdentifier ?? "unknown")")
    }
    
    var body: some Scene {
        WindowGroup {
            Group {
                if authViewModel.isAuthenticated {
                    AuthenticatedView(authViewModel: authViewModel)
                        .onAppear {
                            Logger.app.info("✅ Showing AuthenticatedView")
                        }
                } else {
                    LoginView(authViewModel: authViewModel)
                        .onAppear {
                            Logger.app.info("🔐 Showing LoginView")
                        }
                }
            }
            .onAppear {
                Logger.app.info("🔐 Authentication Status: \(authViewModel.isAuthenticated ? "✅ Authenticated" : "❌ Not Authenticated")")
            }
            .onOpenURL { url in
                Logger.app.info("📞 App received URL: \(url.absoluteString)")
                handleOktaCallback(url: url)
            }
        }
    }
    
    private func handleOktaCallback(url: URL) {
        Logger.app.info("🔗 Processing Okta callback URL")
        Logger.app.info("   - Scheme: \(url.scheme ?? "nil")")
        Logger.app.info("   - Host: \(url.host ?? "nil")")
        Logger.app.info("   - Path: \(url.path)")
        authViewModel.handleCallback(url: url)
    }
}

