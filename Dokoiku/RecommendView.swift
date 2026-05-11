//
//  RecommendView.swift
//  Dokoiku
//

import SwiftUI
import SwiftData

struct RecommendView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Query private var allItems: [Item]
    
    let mode: Category
    
    @State private var mainItem: Item?
    @State private var subItems: [Item] = []
    @State private var showingConfirmation = false
    @State private var selectedItem: Item?
    
    var body: some View {
        VStack {
            if let mainItem = mainItem {
                ScrollView {
                    VStack(spacing: 24) {
                        Text("今日のおすすめ")
                            .font(.headline)
                            .foregroundColor(.secondary)
                            .padding(.top)
                        
                        VStack(spacing: 12) {
                            Text(mainItem.name)
                                .font(.system(size: 36, weight: .bold))
                                .multilineTextAlignment(.center)
                            
                            HStack {
                                Text(mainItem.category.rawValue)
                                if !mainItem.area.isEmpty {
                                    Text("-")
                                    Text(mainItem.area)
                                }
                                Text("-")
                                Text(mainItem.priceLevel.rawValue)
                            }
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            
                            if !mainItem.memo.isEmpty {
                                Text(mainItem.memo)
                                    .font(.body)
                                    .padding()
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .background(Color(UIColor.secondarySystemBackground))
                                    .cornerRadius(8)
                            }
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text("おすすめ理由")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                Text(recommendationReason(for: mainItem))
                                    .font(.subheadline)
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.top, 8)
                        }
                        .padding()
                        .background(Color(UIColor.systemBackground))
                        .cornerRadius(16)
                        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
                        .padding(.horizontal)
                        
                        if !subItems.isEmpty {
                            VStack(alignment: .leading) {
                                Text("その他の候補")
                                    .font(.headline)
                                    .padding(.horizontal)
                                
                                ForEach(subItems) { item in
                                    HStack {
                                        VStack(alignment: .leading) {
                                            Text(item.name).font(.subheadline).bold()
                                            Text(item.area).font(.caption).foregroundColor(.secondary)
                                        }
                                        Spacer()
                                        Button("これにする") {
                                            selectItem(item)
                                        }
                                        .buttonStyle(.bordered)
                                    }
                                    .padding(.horizontal)
                                    .padding(.vertical, 4)
                                }
                            }
                            .padding(.top, 16)
                        }
                    }
                }
                
                VStack(spacing: 16) {
                    Button(action: {
                        selectItem(mainItem)
                    }) {
                        Text("ここにする")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.blue)
                            .cornerRadius(12)
                    }
                    
                    Button(action: {
                        recommend()
                    }) {
                        Text("もう一回")
                            .font(.headline)
                            .foregroundColor(.blue)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.blue.opacity(0.1))
                            .cornerRadius(12)
                    }
                }
                .padding()
            } else {
                VStack {
                    Text("候補が見つかりません")
                    Text("もっと候補を追加してください")
                }
            }
        }
        .navigationTitle("おすすめ")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            recommend()
        }
        .fullScreenCover(isPresented: $showingConfirmation) {
            if let item = selectedItem {
                ZStack {
                    // 背景
                    Color.white.ignoresSafeArea()
                    
                    RadialGradient(gradient: Gradient(colors: [Color.blue.opacity(0.2), Color.white]), center: .center, startRadius: 10, endRadius: 600)
                        .ignoresSafeArea()
                    
                    // コンテンツ
                    VStack(spacing: 40) {
                        Spacer()
                        
                        Text("🎉")
                            .font(.system(size: 100))
                            .shadow(radius: 10)
                        
                        VStack(spacing: 20) {
                            Text("ここで決定したよ！")
                                .font(.title3)
                                .fontWeight(.bold)
                                .foregroundColor(.gray)
                            
                            Text(item.name)
                                .font(.system(size: 54, weight: .black))
                                .foregroundColor(.black)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal)
                                .shadow(color: .blue.opacity(0.3), radius: 5, x: 0, y: 5)
                        }
                        
                        Text("楽しんできてね！")
                            .font(.title)
                            .fontWeight(.black)
                            .foregroundColor(.blue)
                        
                        Spacer()
                        
                        Button(action: {
                            item.lastVisited = Date()
                            item.visitCount += 1
                            showingConfirmation = false
                            dismiss()
                        }) {
                            Text("わかった！")
                                .font(.title3)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                                .padding(.vertical, 20)
                                .frame(maxWidth: .infinity)
                                .background(
                                    Capsule()
                                        .fill(Color.blue)
                                        .shadow(radius: 10)
                                )
                                .padding(.horizontal, 50)
                        }
                        .padding(.bottom, 50)
                    }
                }
                .preferredColorScheme(.light)
            }
        }
    }
    
    private func recommend() {
        let result = RecommendLogic.recommend(from: allItems, mode: mode)
        mainItem = result.main
        subItems = result.sub
    }
    
    private func recommendationReason(for item: Item) -> String {
        if item.visitCount == 0 {
            return "まだ一度も行っていないため"
        } else if let lastVisited = item.lastVisited {
            let daysSince = Calendar.current.dateComponents([.day], from: lastVisited, to: Date()).day ?? 0
            if daysSince > 30 {
                return "最近行っていなくて、行きたい度が高いため"
            }
        }
        return "今の気分にぴったりなため"
    }
    
    private func selectItem(_ item: Item) {
        selectedItem = item
        showingConfirmation = true
    }
}
