//
//  TransactionListViewModel.swift
//  ExpenseTracker
//
//  Created by Shiv Vyas on 7/8/24.
//
import Combine
import Foundation
import Collections

typealias TransactionGroup = OrderedDictionary<String, [Transaction]>
typealias TransactionPrefixSum = [(String, Double)]

class TransactionListViewModel: ObservableObject {
    @Published var transactions: [Transaction] = []
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        getTransactions()
        
    }
    
    func getTransactions() {
        guard let url = URL(string: "https://designcode.io/data/transactions.json") else{
            print("INVALID URL")
            return
        }
        
        URLSession.shared.dataTaskPublisher(for: url)
            .tryMap{ (data, response) -> Data in
                guard let httpResponse = response as? HTTPURLResponse , httpResponse.statusCode == 200 else {
                    dump(response)
                    throw URLError(.badServerResponse)
            }
            return data
                
        }
        .decode(type: [Transaction].self, decoder: JSONDecoder())
        .receive(on: DispatchQueue.main)
        .sink { completion in
            switch completion {
            case.failure(let error):
                print("Error fetching transcations: ", error.localizedDescription)
            case.finished:
                print("Finished fetching transcations")
            }
        
        } receiveValue: { [weak self] result in
            self?.transactions = result
        }
        .store(in: &cancellables)

    }
    
    func groupTransactionsByMonth() -> TransactionGroup {
        guard !transactions.isEmpty  else {return [:]}
        let groupedTransactions = TransactionGroup(grouping: transactions){ $0.month}
        return groupedTransactions
    }
}
