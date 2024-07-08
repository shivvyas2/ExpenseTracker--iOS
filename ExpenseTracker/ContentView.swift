//
//  ContentView.swift
//  ExpenseTracker
//
//  Created by Shiv Vyas on 7/5/24.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var transactionListVM: TransactionListViewModel
    var body: some View {
        NavigationView {
            ScrollView{
                VStack(alignment: .leading, spacing: 20){
                    Text("Overview").font(.title).bold()
                    RecentTransactionList()
                }.padding().frame(maxWidth: .infinity)
                
                
            }.background(Color.Background).navigationBarTitleDisplayMode(.inline).toolbar{ToolbarItem{
                Image(systemName: "bell.badge").symbolRenderingMode(.palette).foregroundColor(Color.Icon)
            }}
            
        }.navigationViewStyle(.stack)
    }
}

struct ContentView_Previews: PreviewProvider {
    static let transactionListVM: TransactionListViewModel = {
        let transactionListVM = TransactionListViewModel()
        transactionListVM.transcations = transactionListPreviewData
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
