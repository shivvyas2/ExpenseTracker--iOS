//
//  MainTabView.swift
//  ExpenseTracker
//

import SwiftUI

struct MainTabView: View {
    @ObservedObject var authViewModel: AuthenticationViewModel
    @StateObject var transactionListVM = TransactionListViewModel()
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            DashboardTab()
                .environmentObject(transactionListVM)
                .tabItem {
                    Label("Dashboard", systemImage: selectedTab == 0 ? "chart.bar.fill" : "chart.bar")
                }
                .tag(0)
            
            AddExpenseTab()
                .environmentObject(transactionListVM)
                .tabItem {
                    Label("Add", systemImage: selectedTab == 1 ? "plus.circle.fill" : "plus.circle")
                }
                .tag(1)
            
            ProfileTab(authViewModel: authViewModel)
                .tabItem {
                    Label("Profile", systemImage: selectedTab == 2 ? "person.fill" : "person")
                }
                .tag(2)
        }
        .onAppear {
            setupTabBarAppearance()
        }
    }
    
    private func setupTabBarAppearance() {
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        
        appearance.backgroundEffect = UIBlurEffect(style: .systemMaterial)
        appearance.backgroundColor = UIColor.systemBackground.withAlphaComponent(0.8)
        
        appearance.shadowColor = UIColor.clear
        
        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
    }
}

