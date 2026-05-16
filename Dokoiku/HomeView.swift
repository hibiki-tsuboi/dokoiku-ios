//
//  HomeView.swift
//  Dokoiku
//

import SwiftUI
import SwiftData

struct HomeView: View {
    @Query private var items: [Item]
    @State private var showingAddSheet = false

    var body: some View {
        NavigationStack {
            VStack {
                if items.isEmpty {
                    VStack(spacing: 20) {
                        Image(systemName: "map")
                            .font(.system(size: 60))
                            .foregroundColor(.gray)
                        Text("候補がありません")
                            .font(.title2)
                            .bold()
                        Text("まずは行きたい場所やお店を追加してください。")
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)

                        Button {
                            showingAddSheet = true
                        } label: {
                            Text("候補を追加する")
                                .font(.headline)
                                .foregroundColor(.white)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color.blue)
                                .cornerRadius(10)
                                .padding(.horizontal, 40)
                        }
                    }
                } else {
                    VStack(spacing: 24) {
                        Text("迷ったら、行き先をおまかせ。")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .padding(.bottom, 20)
                        
                        ModeButton(title: "ごはん", icon: "fork.knife", color: .orange)
                        
                        ModeButton(title: "おでかけ", icon: "figure.walk", color: .green)
                        
                        ModeButton(title: "どちらでも", icon: "sparkles", color: .purple)
                    }
                    .padding(.horizontal, 32)
                }
            }
            .navigationTitle("どこいく")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    NavigationLink {
                        HistoryView()
                    } label: {
                        Image(systemName: "clock.arrow.circlepath")
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink {
                        ListView()
                    } label: {
                        Image(systemName: "list.bullet")
                    }
                }
            }
            .sheet(isPresented: $showingAddSheet) {
                NavigationStack {
                    AddEditView(item: nil)
                }
            }
        }
    }
}

struct ModeButton: View {
    let title: String
    let icon: String
    let color: Color
    
    var body: some View {
        NavigationLink {
            RecommendView(mode: title == "ごはん" ? .food : (title == "おでかけ" ? .outing : nil))
        } label: {
            HStack {
                Image(systemName: icon)
                    .font(.title2)
                    .frame(width: 30)
                Text(title)
                    .font(.title3)
                    .bold()
            }
            .foregroundColor(.white)
            .padding()
            .frame(maxWidth: .infinity)
            .background(color)
            .cornerRadius(12)
        }
    }
}
