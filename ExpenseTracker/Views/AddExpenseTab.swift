//
//  AddExpenseTab.swift
//  ExpenseTracker
//

import SwiftUI

struct AddExpenseTab: View {
    @EnvironmentObject var transactionListVM: TransactionListViewModel
    @State private var amount: String = ""
    @State private var merchant: String = ""
    @State private var selectedCategoryId: Int = Category.foodAndDining.id
    @State private var transactionType: TransactionType = .debit
    @State private var date = Date()
    @State private var showingSuccess = false
    
    var body: some View {
        NavigationView {
            Form {
                Section("Transaction Details") {
                    TextField("Amount", text: $amount)
                        .keyboardType(.decimalPad)
                    
                    TextField("Merchant", text: $merchant)
                    
                    Picker("Category", selection: $selectedCategoryId) {
                        ForEach(Category.categories, id: \.id) { category in
                            Text(category.name).tag(category.id)
                        }
                    }
                    
                    Picker("Type", selection: $transactionType) {
                        Text("Expense").tag(TransactionType.debit)
                        Text("Income").tag(TransactionType.credit)
                    }
                    
                    DatePicker("Date", selection: $date, displayedComponents: .date)
                }
                
                Section {
                    Button(action: addTransaction) {
                        HStack {
                            Spacer()
                            Text("Add Transaction")
                                .fontWeight(.semibold)
                            Spacer()
                        }
                    }
                    .disabled(amount.isEmpty || merchant.isEmpty)
                }
            }
            .navigationTitle("Add Expense")
            .alert("Success", isPresented: $showingSuccess) {
                Button("OK", role: .cancel) {
                    resetForm()
                }
            } message: {
                Text("Transaction added successfully!")
            }
        }
    }
    
    private var selectedCategory: Category {
        Category.categories.first(where: { $0.id == selectedCategoryId }) ?? .foodAndDining
    }
    
    private func addTransaction() {
        guard let amountValue = Double(amount), !merchant.isEmpty else { return }
        
        let newTransaction = Transaction(
            id: Int.random(in: 1000...9999),
            date: date.formatted(.dateTime.month().day().year()),
            institution: "Manual Entry",
            account: "Cash",
            merchant: merchant,
            amount: amountValue,
            type: transactionType.rawValue,
            categoryId: selectedCategory.id,
            category: selectedCategory.name,
            isPending: false,
            isTransfer: false,
            isExpense: transactionType == .debit,
            isEdited: false
        )
        
        transactionListVM.transactions.insert(newTransaction, at: 0)
        showingSuccess = true
    }
    
    private func resetForm() {
        amount = ""
        merchant = ""
        selectedCategoryId = Category.foodAndDining.id
        transactionType = .debit
        date = Date()
    }
}

