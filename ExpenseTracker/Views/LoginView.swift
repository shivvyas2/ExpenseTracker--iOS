//
//  LoginView.swift
//  ExpenseTracker
//

import SwiftUI

struct LoginView: View {
    @ObservedObject var authViewModel: AuthenticationViewModel
    @State private var showingError = false
    
    var body: some View {
        ZStack {
            Color.Background
                .ignoresSafeArea()
            
            VStack(spacing: 30) {
                VStack(spacing: 10) {
                    Image(systemName: "dollarsign.circle.fill")
                        .resizable()
                        .frame(width: 80, height: 80)
                        .foregroundColor(.accentColor)
                    
                    Text("Expense Tracker")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.Text)
                    
                    Text("Sign in to continue")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding(.bottom, 40)
                
                Button(action: {
                    authViewModel.login()
                }) {
                    HStack {
                        if authViewModel.isLoading {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        } else {
                            Text("Sign In with Okta")
                                .fontWeight(.semibold)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.accentColor)
                    .foregroundColor(.white)
                    .cornerRadius(12)
                }
                .disabled(authViewModel.isLoading)
                .padding(.horizontal, 40)
                
                if let errorMessage = authViewModel.errorMessage {
                    Text(errorMessage)
                        .font(.caption)
                        .foregroundColor(.red)
                        .padding(.horizontal, 40)
                }
                
                Spacer()
                
                VStack(spacing: 5) {
                    Text("Secure authentication powered by Okta")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding(.bottom, 20)
            }
            .padding()
        }
        .onChange(of: authViewModel.errorMessage) { error in
            if error != nil {
                showingError = true
            }
        }
        .alert("Authentication Error", isPresented: $showingError) {
            Button("OK", role: .cancel) {
                authViewModel.errorMessage = nil
            }
        } message: {
            if let error = authViewModel.errorMessage {
                Text(error)
            }
        }
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView(authViewModel: AuthenticationViewModel())
    }
}

