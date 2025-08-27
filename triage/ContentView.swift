//
//  ContentView.swift
//  triage
//
//  Created by Gilang Banyu Biru Erassunu on 22/08/25.
//

import SwiftUI

struct ContentView: View {
    @Environment(DataManager.self) private var dataManager
    @Environment(QuickReplyManager.self) private var quickReplyManager
    
    @State private var orderListViewModel: OrderListViewModel?
    
    var body: some View {
        TabView {
            if let orderListViewModel = orderListViewModel {
                OrderListView()
                    .environment(orderListViewModel)
                    .tabItem {
                        Image(systemName: "list.bullet")
                        Text("Orders")
                    }
            }
            
            if let orderListViewModel = orderListViewModel {
                AnalyticsView()
                    .environment(orderListViewModel)
                    .tabItem {
                        Image(systemName: "chart.bar")
                        Text("Analytics")
                    }
            }
            
            SettingsView()
                .tabItem {
                    Image(systemName: "gear")
                    Text("Settings")
                }
        }
        .onAppear {
            if orderListViewModel == nil {
                orderListViewModel = OrderListViewModel(dataManager: dataManager)
            }
        }
    }
}

#Preview {
    ContentView()
        .environment(DataManager.shared)
        .environment(QuickReplyManager.shared)
}
