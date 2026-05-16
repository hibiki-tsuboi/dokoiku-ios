//
//  HistoryView.swift
//  Dokoiku
//

import SwiftUI
import SwiftData

struct HistoryView: View {
    @Query(sort: \Item.lastVisited, order: .reverse) private var items: [Item]
    
    var visitedItems: [Item] {
        items.filter { $0.lastVisited != nil }
    }
    
    var body: some View {
        List {
            if visitedItems.isEmpty {
                Text("まだ履歴がありません")
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .listRowBackground(Color.clear)
            } else {
                ForEach(visitedItems) { item in
                    NavigationLink {
                        DetailView(item: item)
                    } label: {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(item.name)
                                    .font(.headline)
                                HStack {
                                    Text(item.category.rawValue)
                                    if !item.area.isEmpty {
                                        Text("-")
                                        Text(item.area)
                                    }
                                }
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            }
                            Spacer()
                            if let date = item.lastVisited {
                                Text(date, format: .dateTime.year().month().day())
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                }
            }
        }
        .navigationTitle("履歴")
    }
}
