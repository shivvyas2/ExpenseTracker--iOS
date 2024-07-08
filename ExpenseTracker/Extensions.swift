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
        formatter.dateFormat = "MM/DD/YYYY"
        
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
