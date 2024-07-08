//
//  RecentTransactionList.swift
//  ExpenseTracker
//
//  Created by Shiv Vyas on 7/8/24.
//

import SwiftUI
import SwiftUIFontIcon

struct RecentTransactionList: View {
    @EnvironmentObject var transactionListVM: TransactionListViewModel
    
    var body: some View {
        VStack{
            HStack{
                Text("Recent Transactions").bold()
                Spacer()
                NavigationLink{
                } label: {
                    HStack(spacing: 4){
                        Text("See All")
                        Image(systemName:"chevron.right")
                    }
                    .foregroundColor(Color.text)
                }
            }
            .padding(.top)
            
            //Recent Transaction lists
            
            ForEach(Array(transactionListVM.transcations.prefix(5).enumerated()), id: \.element)
                { index,transactions in
                TransactionRow(transaction: transactions)
                
                
                    Divider().opacity(index == 4 ? 0 : 1)
            }
        }
        .padding()
        .background(Color.systemBackgorund)
        .clipShape(RoundedRectangle(cornerRadius:20 , style: .continuous))
        .shadow(color: Color.primary.opacity(0.2),radius: 10, x: 0, y: 5)
        
      
    }
}

struct RecentTransactionList_Previews: PreviewProvider {
    static let transactionListVM: TransactionListViewModel = {
        let transactionListVM = TransactionListViewModel()
        transactionListVM.transcations = transactionListPreviewData
        return transactionListVM
    }()
    static var previews: some View{
        RecentTransactionList().environmentObject(transactionListVM)
    }

}
