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
        VStack {
            Picker("カテゴリ", selection: $selectedCategory) {
                Text("すべて").tag(Category?.none)
                ForEach(Category.allCases) { cat in
                    Text(cat.rawValue).tag(Category?.some(cat))
                }
            }
            .pickerStyle(.segmented)
            .padding(.horizontal)
            .padding(.top, 8)
            
            List {
                ForEach(filteredItems) { item in
                    NavigationLink {
                        DetailView(item: item)
                    } label: {
                        VStack(alignment: .leading) {
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
                    }
                }
                .onDelete(perform: deleteItems)
            }
            .searchable(text: $searchText, prompt: "名前で検索")
        }
        .navigationTitle("候補一覧")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                NavigationLink {
                    AddEditView(item: nil)
                } label: {
                    Image(systemName: "plus")
                }
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
