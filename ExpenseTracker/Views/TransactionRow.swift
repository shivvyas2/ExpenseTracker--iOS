//
//  TransactionRow.swift
//  ExpenseTracker
//
//  Created by Shiv Vyas on 7/8/24.
//

import SwiftUI
import SwiftUIFontIcon

struct TransactionRow: View {
    var transaction: Transaction
    
    var body: some View {
        HStack(spacing: 20){
            RoundedRectangle(cornerRadius: 30, style: .continuous).fill(Color.icon.opacity(0.3)).frame(width: 44, height: 44).overlay{
                FontIcon.text(.awesome5Solid(code: transaction.icon), fontsize: 24, color: Color.Icon)
            }
            VStack(alignment: .leading, spacing: 6){
                Text(transaction.merchant).font(.subheadline).bold().lineLimit(1)
                //Transaction Category
                Text(transaction.category).font(.footnote).opacity(0.7).lineLimit(1)
                //Date
                Text(transaction.dateParsed,format: .dateTime.year().month().day()).font(.footnote).foregroundColor(.secondary)
                
            }
            Spacer()
        //Transaction Amount
            Text(transaction.signedAmount, format: .currency(code: "USD")).bold().foregroundColor(transaction.type == TransactionType.credit.rawValue ? Color.text : .primary)
            
        }.padding([.top, .bottom], 8)
    }
}

#Preview {
    TransactionRow(transaction: transactionPreviewData)
}
