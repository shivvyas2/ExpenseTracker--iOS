//
//  AuthenticatedView.swift
//  ExpenseTracker
//

import SwiftUI

struct AuthenticatedView: View {
    @ObservedObject var authViewModel: AuthenticationViewModel
    
    var body: some View {
        MainTabView(authViewModel: authViewModel)
            .onAppear {
                authViewModel.validateSession()
            }
    }
}

