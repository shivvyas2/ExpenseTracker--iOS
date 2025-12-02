//
//  AuthenticatedView.swift
//  ExpenseTracker
//

import SwiftUI

struct AuthenticatedView: View {
    @ObservedObject var authViewModel: AuthenticationViewModel
    @StateObject var transactionListVM = TransactionListViewModel()
    
    var body: some View {
        NavigationView {
            ContentView()
                .environmentObject(transactionListVM)
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Menu {
                            if let userInfo = authViewModel.userInfo {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(userInfo.name)
                                        .font(.headline)
                                    Text(userInfo.email)
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                .padding(.vertical, 4)
                                
                                Divider()
                            }
                            
                            Button(action: {
                                authViewModel.logout()
                            }) {
                                Label("Sign Out", systemImage: "arrow.right.square")
                            }
                        } label: {
                            Image(systemName: "person.circle.fill")
                                .foregroundColor(.Icon)
                        }
                    }
                }
        }
        .navigationViewStyle(.stack)
        .onAppear {
            authViewModel.validateSession()
        }
    }
}

