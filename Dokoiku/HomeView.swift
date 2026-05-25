//
//  HomeView.swift
//  Dokoiku
//

import SwiftUI
import SwiftData

struct HomeView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var items: [Item]
    @State private var showingAddSheet = false
    @State private var selectedArea: String? = nil

    private var availableAreas: [String] {
        let set = Set(
            items
                .filter { !$0.area.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
                .map { $0.area }
        )
        return set.sorted()
    }

    var body: some View {
        NavigationStack {
            Group {
                if items.isEmpty {
                    emptyState
                } else {
                    modeSelection
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background {
                Image("AppBackground")
                    .resizable()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .ignoresSafeArea()
            }
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(.hidden, for: .navigationBar)
            .task {
                seedVisitsIfNeeded()
            }
            .toolbar {
                ToolbarItemGroup(placement: .navigationBarTrailing) {
                    NavigationLink {
                        HistoryView()
                    } label: {
                        Image(systemName: "clock.arrow.circlepath")
                    }
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

    private var emptyState: some View {
        VStack(spacing: 28) {
            ZStack {
                Circle()
                    .fill(Color.brandTeal.opacity(0.15))
                    .frame(width: 140, height: 140)
                Image(systemName: "map")
                    .font(.system(size: 60, weight: .light))
                    .foregroundColor(.brandTeal)
            }

            VStack(spacing: 10) {
                Text("候補がありません")
                    .font(.title2.weight(.bold))
                Text("まずは行きたい場所やお店を追加してください。")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }

            Button {
                showingAddSheet = true
            } label: {
                Text("候補を追加する")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding(.vertical, 16)
                    .frame(maxWidth: .infinity)
                    .background(Color.brandTeal)
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                    .padding(.horizontal, 40)
            }
            .padding(.top, 8)
        }
    }

    private var modeSelection: some View {
        VStack(spacing: 32) {
            VStack(alignment: .leading, spacing: 6) {
                Text("今日は")
                    .font(.title3.weight(.semibold))
                    .foregroundColor(.secondary)
                Text("どこ行く？")
                    .font(.system(size: 56, weight: .black, design: .rounded))
                    .foregroundColor(.primary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.6)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 24)
            .padding(.top, 8)

            if !availableAreas.isEmpty {
                areaSelector
                    .padding(.horizontal, 20)
            }

            VStack(spacing: 14) {
                ModeButton(title: "ごはん", icon: "fork.knife", color: .brandOrange, area: selectedArea)
                ModeButton(title: "おでかけ", icon: "figure.walk", color: .brandGreen, area: selectedArea)
                ModeButton(title: "おまかせ", icon: "sparkles", color: .brandTeal, area: selectedArea)
            }
            .padding(.horizontal, 20)

            Spacer(minLength: 0)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
    }

    private var areaSelector: some View {
        Menu {
            Picker("エリア", selection: $selectedArea) {
                Text("すべてのエリア").tag(String?.none)
                ForEach(availableAreas, id: \.self) { area in
                    Text(area).tag(String?.some(area))
                }
            }
        } label: {
            HStack(spacing: 10) {
                Image(systemName: "mappin.and.ellipse")
                    .font(.headline)
                    .foregroundColor(.brandTeal)
                Text(selectedArea ?? "すべてのエリア")
                    .font(.subheadline.weight(.semibold))
                    .foregroundColor(.primary)
                Spacer()
                Image(systemName: "chevron.up.chevron.down")
                    .font(.caption.weight(.semibold))
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal, 18)
            .padding(.vertical, 14)
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(Color.cardBackground)
            )
            .shadow(color: Color.black.opacity(0.06), radius: 10, x: 0, y: 4)
        }
    }

    private func seedVisitsIfNeeded() {
        var didSeed = false
        for item in items {
            guard let lastVisited = item.lastVisited, item.visits.isEmpty else { continue }
            let visit = Visit(visitedAt: lastVisited, item: item)
            modelContext.insert(visit)
            didSeed = true
        }
        if didSeed {
            try? modelContext.save()
        }
    }
}

struct ModeButton: View {
    let title: String
    let icon: String
    let color: Color
    var area: String? = nil

    var body: some View {
        NavigationLink {
            RecommendView(mode: title == "ごはん" ? .food : (title == "おでかけ" ? .outing : nil), area: area)
        } label: {
            HStack(spacing: 16) {
                ZStack {
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(color)
                        .frame(width: 56, height: 56)
                    Image(systemName: icon)
                        .font(.title2.weight(.semibold))
                        .foregroundColor(.white)
                }
                Text(title)
                    .font(.title3.weight(.semibold))
                    .foregroundColor(.primary)
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.subheadline.weight(.semibold))
                    .foregroundColor(.secondary)
            }
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(Color.cardBackground)
            )
            .shadow(color: Color.black.opacity(0.06), radius: 10, x: 0, y: 4)
        }
    }
}
