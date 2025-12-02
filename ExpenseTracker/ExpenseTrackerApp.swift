//
//  ExpenseTrackerApp.swift
//  ExpenseTracker
//
//  Created by Shiv Vyas on 7/5/24.
//

import SwiftUI

@main
struct ExpenseTrackerApp: App {
    @StateObject var authViewModel = AuthenticationViewModel()
    
    var body: some Scene {
        WindowGroup {
            Group {
                if authViewModel.isAuthenticated {
                    AuthenticatedView(authViewModel: authViewModel)
                } else {
                    LoginView(authViewModel: authViewModel)
                }
            }
            .onOpenURL { url in
                handleOktaCallback(url: url)
            }
        }
    }
    
    private func handleOktaCallback(url: URL) {
        authViewModel.handleCallback(url: url)
    }
}
