//
//  PreviewData.swift
//  ExpenseTracker
//
//  Created by Shiv Vyas on 7/8/24.
//

import Foundation


var transactionPreviewData = Transaction(id: 1, date: "02/09/2001", institution: "Pace", account: "Chase", merchant: "Apple", amount: 140.29, type: "debit", categoryId: 901, category: "Software", isPending: false, isTransfer: false, isExpense: true, isEdited: false)


var transactionListPreviewData = [Transaction](repeating: transactionPreviewData, count:10)

