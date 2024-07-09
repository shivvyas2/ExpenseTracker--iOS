//
//  Extensions.swift
//  ExpenseTracker
//
//  Created by Shiv Vyas on 7/5/24.
//

import Foundation
import SwiftUI

extension Color {
    static let Background = Color("Background")
    static let Icon = Color("Icon")
    static let Text = Color("Text")
    static let systemBackgorund = Color(uiColor: .systemBackground)
    
}

extension DateFormatter {
    static let allNumericUSA: DateFormatter = {
        print("Initializing DateFormatter")
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd/yyyy"
        
        return formatter
    }()
}


extension String {
    func dateParsed()-> Date {
        guard let parsedDate = DateFormatter.allNumericUSA.date(from:self) else{
            return Date()
        }
        return parsedDate
    }
}

extension Date {
    func formatted()-> String {
        return self.formatted(.dateTime.year().month().day())
    }
    }

extension Double{
        func roundedTo2Digits() -> Double{
            return (self * 100 ).rounded()/100
        }
}
