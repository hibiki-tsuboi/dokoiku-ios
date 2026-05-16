//
//  ListView.swift
//  Dokoiku
//

import SwiftUI
import SwiftData

struct ListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Item.createdAt, order: .reverse) private var items: [Item]

    @State private var searchText = ""
    @State private var selectedCategory: Category? = nil
    @State private var showingAddSheet = false

    var filteredItems: [Item] {
        var result = items

        if let category = selectedCategory {
            result = result.filter { $0.category == category }
        }

        if !searchText.isEmpty {
            result = result.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
        }

        return result
    }

    var body: some View {
        ZStack {
            Color.brandBackground.ignoresSafeArea()

            VStack(spacing: 0) {
                Picker("カテゴリ", selection: $selectedCategory) {
                    Text("すべて").tag(Category?.none)
                    ForEach(Category.allCases) { cat in
                        Text(cat.rawValue).tag(Category?.some(cat))
                    }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)
                .padding(.top, 8)
                .padding(.bottom, 4)

                List {
                    ForEach(filteredItems) { item in
                        NavigationLink {
                            DetailView(item: item)
                        } label: {
                            ItemRow(item: item)
                        }
                        .listRowBackground(Color.cardBackground)
                    }
                    .onDelete(perform: deleteItems)
                }
                .scrollContentBackground(.hidden)
                .searchable(text: $searchText, prompt: "名前で検索")
            }
        }
        .navigationTitle("候補一覧")
        .toolbarBackground(Color.brandBackground, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    showingAddSheet = true
                } label: {
                    Image(systemName: "plus")
                }
            }
        }
        .sheet(isPresented: $showingAddSheet) {
            NavigationStack {
                AddEditView(item: nil)
            }
        }
    }

    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                modelContext.delete(filteredItems[index])
            }
        }
    }
}

private struct ItemRow: View {
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
        }
        .padding(.vertical, 6)
    }
}
