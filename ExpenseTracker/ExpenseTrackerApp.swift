//
//  ExpenseTrackerApp.swift
//  ExpenseTracker
//
//  Created by Shiv Vyas on 7/5/24.
//

import SwiftUI

@main
struct ExpenseTrackerApp: App {
    @StateObject var transcationListVM = TransactionListViewModel()
    
    var body: some Scene {
        WindowGroup {
            ContentView().environmentObject(transcationListVM)
            
        }
    }
}
