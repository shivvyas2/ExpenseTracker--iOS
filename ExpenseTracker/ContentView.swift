//
//  ContentView.swift
//  ExpenseTracker
//
//  Created by Shiv Vyas on 7/5/24.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        NavigationView {
            ScrollView{
                VStack(alignment: .leading, spacing: 20){
                    Text("Overview").font(.title).bold()
                }.padding().frame(maxWidth: .infinity)
                
                
            }.background(Color.Background).navigationBarTitleDisplayMode(.inline).toolbar{ToolbarItem{
                Image(systemName: "bell.badge").symbolRenderingMode(.palette).foregroundColor(Color.Icon)
            }}
            
        }.navigationViewStyle(.stack)
    }
}

#Preview {
    ContentView()
}
