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

    let mode: Category?

    @State private var mainItem: Item?
    @State private var subItems: [Item] = []
    @State private var showingConfirmation = false
    @State private var selectedItem: Item?

    var body: some View {
        ZStack {
            Color.brandBackground.ignoresSafeArea()

            VStack(spacing: 0) {
                if let mainItem = mainItem {
                    ScrollView {
                        VStack(spacing: 20) {
                            Text("今日のおすすめ")
                                .font(.subheadline.weight(.semibold))
                                .foregroundColor(.secondary)
                                .padding(.top, 8)

                            mainCard(for: mainItem)
                                .padding(.horizontal)

                            if !subItems.isEmpty {
                                VStack(alignment: .leading, spacing: 12) {
                                    Text("その他の候補")
                                        .font(.headline)
                                        .padding(.horizontal)

                                    VStack(spacing: 10) {
                                        ForEach(subItems) { item in
                                            subItemRow(for: item)
                                        }
                                    }
                                    .padding(.horizontal)
                                }
                                .padding(.top, 8)
                            }
                        }
                        .padding(.bottom, 16)
                    }

                    VStack(spacing: 12) {
                        Button {
                            selectItem(mainItem)
                        } label: {
                            Text("ここにする")
                                .font(.headline)
                                .foregroundColor(.white)
                                .padding(.vertical, 16)
                                .frame(maxWidth: .infinity)
                                .background(Color.brandTeal)
                                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                        }

                        Button {
                            recommend()
                        } label: {
                            Text("もう一回")
                                .font(.headline)
                                .foregroundColor(.brandTeal)
                                .padding(.vertical, 16)
                                .frame(maxWidth: .infinity)
                                .background(Color.brandTeal.opacity(0.12))
                                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                        }
                    }
                    .padding()
                } else {
                    VStack(spacing: 12) {
                        Image(systemName: "tray")
                            .font(.system(size: 48, weight: .light))
                            .foregroundColor(.secondary)
                        Text("候補が見つかりません")
                            .font(.headline)
                        Text("もっと候補を追加してください")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            }
        }
        .navigationTitle("おすすめ")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(Color.brandBackground, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .onAppear {
            recommend()
        }
        .fullScreenCover(item: $selectedItem) { item in
            decisionScreen(for: item)
        }
    }

    private func mainCard(for item: Item) -> some View {
        VStack(spacing: 12) {
            categoryBadge(for: item.category)
                .padding(.top, 4)

            Text(item.name)
                .font(.system(size: 32, weight: .bold))
                .multilineTextAlignment(.center)

            HStack(spacing: 8) {
                Text(item.category.rawValue)
                if !item.area.isEmpty {
                    Text("·")
                    Text(item.area)
                }
                Text("·")
                Text(item.priceLevel.rawValue)
            }
            .font(.subheadline)
            .foregroundColor(.secondary)

            if !item.memo.isEmpty {
                Text(item.memo)
                    .font(.body)
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.brandBackground)
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                    .padding(.top, 4)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text("おすすめ理由")
                    .font(.caption.weight(.semibold))
                    .foregroundColor(.secondary)
                Text(recommendationReason(for: item))
                    .font(.subheadline)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.top, 4)
        }
        .padding(20)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(Color.cardBackground)
        )
        .shadow(color: Color.black.opacity(0.06), radius: 12, x: 0, y: 4)
    }

    private func categoryBadge(for category: Category) -> some View {
        let color: Color = category == .food ? .brandOrange : .brandGreen
        let icon = category == .food ? "fork.knife" : "figure.walk"
        return ZStack {
            Circle()
                .fill(color.opacity(0.15))
                .frame(width: 56, height: 56)
            Image(systemName: icon)
                .font(.title2.weight(.semibold))
                .foregroundColor(color)
        }
    }

    private func subItemRow(for item: Item) -> some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 2) {
                Text(item.name)
                    .font(.subheadline.weight(.semibold))
                if !item.area.isEmpty {
                    Text(item.area)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            Spacer()
            Button("これにする") {
                selectItem(item)
            }
            .buttonStyle(.bordered)
            .tint(.brandTeal)
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(Color.cardBackground)
        )
    }

    private func decisionScreen(for item: Item) -> some View {
        ZStack {
            Color.brandBackground.ignoresSafeArea()

            RadialGradient(
                gradient: Gradient(colors: [Color.brandTeal.opacity(0.25), Color.brandBackground]),
                center: .center,
                startRadius: 10,
                endRadius: 600
            )
            .ignoresSafeArea()

            VStack(spacing: 36) {
                Spacer()

                Text("🎉")
                    .font(.system(size: 100))
                    .shadow(radius: 10)

                VStack(spacing: 20) {
                    Text("ここで決定したよ！")
                        .font(.title3.weight(.bold))
                        .foregroundColor(.secondary)

                    Text(item.name)
                        .font(.system(size: 48, weight: .black))
                        .foregroundColor(.primary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                        .shadow(color: Color.brandTeal.opacity(0.3), radius: 5, x: 0, y: 5)
                }

                Text("楽しんできてね！")
                    .font(.title.weight(.black))
                    .foregroundColor(.brandTeal)

                Spacer()

                Button {
                    item.lastVisited = Date()
                    item.visitCount += 1
                    selectedItem = nil
                    dismiss()
                } label: {
                    Text("わかった！")
                        .font(.title3.weight(.bold))
                        .foregroundColor(.white)
                        .padding(.vertical, 20)
                        .frame(maxWidth: .infinity)
                        .background(
                            Capsule()
                                .fill(Color.brandTeal)
                                .shadow(radius: 10)
                        )
                        .padding(.horizontal, 50)
                }
                .padding(.bottom, 50)
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
    }
}
