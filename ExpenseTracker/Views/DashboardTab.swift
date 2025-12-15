//
//  DashboardTab.swift
//  ExpenseTracker
//

import SwiftUI
import SwiftUICharts

struct DashboardTab: View {
    @EnvironmentObject var transactionListVM: TransactionListViewModel
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Text("Overview")
                        .font(.title)
                        .bold()
                    
                    let data = transactionListVM.accumulateTransaction()
                    
                    if !data.isEmpty {
                        let totalExpenses = data.last?.1 ?? 0
                        
                        CardView {
                            VStack(alignment: .leading) {
                                ChartLabel(totalExpenses.formatted(.currency(code: "USD")), type: .title, format: "$%.02f")
                                LineChart()
                            }
                            .background(Color.systemBackgorund)
                        }
                        .data(data)
                        .chartStyle(ChartStyle(backgroundColor: Color.systemBackgorund, foregroundColor: ColorGradient(Color.Icon.opacity(0.5), Color.Icon)))
                        .frame(height: 300)
                    }
                    
                    RecentTransactionList()
                }
                .padding()
                .frame(maxWidth: .infinity)
            }
            .background(Color.Background)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Image(systemName: "bell.badge")
                        .symbolRenderingMode(.palette)
                        .foregroundColor(Color.Icon)
                }
            }
        }
        .navigationViewStyle(.stack)
        .accentColor(.primary)
    }
}

