//
//  DetailView.swift
//  Dokoiku
//

import SwiftUI
import SwiftData

struct DetailView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    let item: Item
    
    @State private var showingEditSheet = false
    @State private var showingDeleteConfirm = false
    
    var body: some View {
        List {
            Section(header: Text("基本情報")) {
                HStack {
                    Text("名前")
                        .foregroundColor(.secondary)
                    Spacer()
                    Text(item.name)
                        .bold()
                }
                
                HStack {
                    Text("カテゴリ")
                        .foregroundColor(.secondary)
                    Spacer()
                    Text(item.category.rawValue)
                }
                
                HStack {
                    Text("エリア")
                        .foregroundColor(.secondary)
                    Spacer()
                    Text(item.area)
                }
            }
            
            Section(header: Text("詳細")) {
                HStack {
                    Text("行きたい度")
                        .foregroundColor(.secondary)
                    Spacer()
                    Text("\(item.desireLevel) / 5")
                }
                
                HStack {
                    Text("価格帯")
                        .foregroundColor(.secondary)
                    Spacer()
                    Text(item.priceLevel.rawValue)
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("メモ")
                        .foregroundColor(.secondary)
                    Text(item.memo)
                }
                .padding(.vertical, 4)
            }
            
            Section(header: Text("履歴")) {
                HStack {
                    Text("行った回数")
                        .foregroundColor(.secondary)
                    Spacer()
                    Text("\(item.visitCount)回")
                }
                
                HStack {
                    Text("最後に訪れた日")
                        .foregroundColor(.secondary)
                    Spacer()
                    if let lastVisited = item.lastVisited {
                        Text(lastVisited, format: .dateTime.year().month().day())
                    } else {
                        Text("")
                    }
                }
            }
            
            Section {
                Button(role: .destructive) {
                    showingDeleteConfirm = true
                } label: {
                    HStack {
                        Spacer()
                        Text("この候補を削除")
                        Spacer()
                    }
                }
            }
        }
        .navigationTitle("候補の詳細")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("編集") {
                    showingEditSheet = true
                }
            }
        }
        .sheet(isPresented: $showingEditSheet) {
            NavigationStack {
                AddEditView(item: item)
            }
        }
        .alert("本当に削除しますか？", isPresented: $showingDeleteConfirm) {
            Button("キャンセル", role: .cancel) {}
            Button("削除", role: .destructive) {
                delete()
            }
        } message: {
            Text("この操作は取り消せません。")
        }
    }
    
    private func delete() {
        modelContext.delete(item)
        dismiss()
    }
}
