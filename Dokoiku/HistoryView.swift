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
        ZStack {
            Color.brandBackground.ignoresSafeArea()

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
                            HistoryRow(item: item)
                        }
                        .listRowBackground(Color.cardBackground)
                    }
                }
            }
            .scrollContentBackground(.hidden)
        }
        .navigationTitle("履歴")
        .toolbarBackground(Color.brandBackground, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
    }
}

private struct HistoryRow: View {
    let item: Item

    private var categoryColor: Color {
        item.category == .food ? .brandOrange : .brandGreen
    }

    private var categoryIcon: String {
        item.category == .food ? "fork.knife" : "figure.walk"
    }

    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .fill(categoryColor)
                    .frame(width: 40, height: 40)
                Image(systemName: categoryIcon)
                    .font(.callout.weight(.semibold))
                    .foregroundColor(.white)
            }
            VStack(alignment: .leading, spacing: 2) {
                Text(item.name)
                    .font(.headline)
                if !item.area.isEmpty {
                    Text(item.area)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }
            Spacer()
            if let date = item.lastVisited {
                Text(date, format: Date.VerbatimFormatStyle(
                    format: "\(year: .defaultDigits)年\(month: .defaultDigits)月\(day: .defaultDigits)日",
                    timeZone: .current,
                    calendar: .current
                ))
                .font(.caption)
                .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 6)
    }
}
