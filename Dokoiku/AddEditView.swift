//
//  AddEditView.swift
//  Dokoiku
//

import SwiftUI
import SwiftData

struct AddEditView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @State private var name: String = ""
    @State private var category: Category = .food
    @State private var area: String = ""
    @State private var memo: String = ""
    @State private var desireLevel: Int = 3
    @State private var priceLevel: PriceLevel = .normal
    @State private var visitCount: Int = 0
    @State private var lastVisitedDate: Date = Date()
    
    let item: Item?
    
    init(item: Item?) {
        self.item = item
        if let item = item {
            _name = State(initialValue: item.name)
            _category = State(initialValue: item.category)
            _area = State(initialValue: item.area)
            _memo = State(initialValue: item.memo)
            _desireLevel = State(initialValue: item.desireLevel)
            _priceLevel = State(initialValue: item.priceLevel)
            _visitCount = State(initialValue: item.visitCount)
            if let lastDate = item.lastVisited {
                _lastVisitedDate = State(initialValue: lastDate)
            }
        }
    }
    
    var body: some View {
        Form {
            Section(header: Text("基本情報")) {
                TextField("名前", text: $name)
                Picker("カテゴリ", selection: $category) {
                    ForEach(Category.allCases) { cat in
                        Text(cat.rawValue).tag(cat)
                    }
                }
                TextField("エリア", text: $area)
            }
            
            Section(header: Text("詳細")) {
                Picker("行きたい度", selection: $desireLevel) {
                    ForEach(1...5, id: \.self) { level in
                        Text("\(level)").tag(level)
                    }
                }
                Picker("価格帯", selection: $priceLevel) {
                    ForEach(PriceLevel.allCases) { price in
                        Text(price.rawValue).tag(price)
                    }
                }
                TextField("メモ", text: $memo)
            }
            
            Section(header: Text("履歴")) {
                Stepper("行った回数: \(visitCount)回", value: $visitCount, in: 0...999)
                if visitCount > 0 {
                    DatePicker("最後に訪れた日", selection: $lastVisitedDate, displayedComponents: .date)
                }
            }
        }
        .navigationTitle(item == nil ? "候補を追加" : "候補を編集")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button("キャンセル") {
                    dismiss()
                }
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("保存") {
                    save()
                }
                .disabled(name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
        }
    }
    
    private func save() {
        let finalLastVisited = visitCount > 0 ? lastVisitedDate : nil
        if let item = item {
            item.name = name
            item.category = category
            item.area = area
            item.memo = memo
            item.desireLevel = desireLevel
            item.priceLevel = priceLevel
            item.visitCount = visitCount
            item.lastVisited = finalLastVisited
        } else {
            let newItem = Item(name: name, category: category, area: area, memo: memo, desireLevel: desireLevel, lastVisited: finalLastVisited, priceLevel: priceLevel, visitCount: visitCount)
            modelContext.insert(newItem)
        }
        dismiss()
    }
}
