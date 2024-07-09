//
//  ContentView.swift
//  ExpenseTracker
//
//  Created by Shiv Vyas on 7/5/24.
//

import SwiftUI
import SwiftUICharts

struct ContentView: View {
    
    @EnvironmentObject var transactionListVM: TransactionListViewModel
    //var DemoData: [Double] = [8,2,4,5,7,9,12,2]
    var body: some View {
        NavigationView {
            ScrollView{
                VStack(alignment: .leading, spacing: 20){
                    Text("Overview").font(.title).bold()
                    let data = transactionListVM.accumulateTransaction()
                    
                    //Chart
                    if !data.isEmpty{
                        let totalExpenses = data.last?.1 ?? 0
                        
                        CardView {
                            VStack(alignment: .leading){
                                ChartLabel(totalExpenses.formatted(.currency(code: "USD")) ,type: .title, format: "$%.02f")
                                LineChart()
                            }.background(Color.systemBackgorund)
                                
                            }.data(data).chartStyle(ChartStyle(backgroundColor: Color.systemBackgorund, foregroundColor: ColorGradient(Color.icon.opacity(0.5), Color.icon))).frame(height: 300)
                        
                        
                    }
                  
                    // Transactions List
                    RecentTransactionList()
                }.padding().frame(maxWidth: .infinity)
                
                
            }.background(Color.Background).navigationBarTitleDisplayMode(.inline).toolbar{ToolbarItem{
                Image(systemName: "bell.badge").symbolRenderingMode(.palette).foregroundColor(Color.Icon)
            }}
            
        }.navigationViewStyle(.stack).accentColor(.primary)
    }
}

struct ContentView_Previews: PreviewProvider {
    static let transactionListVM: TransactionListViewModel = {
        let transactionListVM = TransactionListViewModel()
        transactionListVM.transactions = transactionListPreviewData
        return transactionListVM
    }()
    static var previews: some View{
        Group {
            ContentView()
            ContentView().preferredColorScheme(.dark)
        }
        .environmentObject(transactionListVM)
    }

}
