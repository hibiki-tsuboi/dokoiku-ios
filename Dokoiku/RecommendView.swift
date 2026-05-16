//
//  RecommendView.swift
//  Dokoiku
//

import SwiftUI
import SwiftData
import UIKit

struct RecommendView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Query private var allItems: [Item]

    let mode: Category?

    @State private var mainItem: Item?
    @State private var subItems: [Item] = []
    @State private var showingConfirmation = false
    @State private var selectedItem: Item?
    @State private var isShuffling = true
    @State private var shuffleItem: Item?
    @State private var shuffleTask: Task<Void, Never>?
    @State private var revealPulse = false

    var body: some View {
        ZStack {
            Color.brandBackground.ignoresSafeArea()

            if isShuffling, let shuffleItem {
                shufflingView(for: shuffleItem)
            } else if let mainItem {
                resultView(for: mainItem)
            } else {
                emptyState
            }
        }
        .navigationTitle("おすすめ")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(Color.brandBackground, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .onAppear {
            startReveal()
        }
        .onDisappear {
            shuffleTask?.cancel()
        }
        .fullScreenCover(item: $selectedItem) { item in
            DecisionScreen(item: item) {
                item.lastVisited = Date()
                item.visitCount += 1
                selectedItem = nil
                dismiss()
            }
        }
    }

    private func shufflingView(for item: Item) -> some View {
        VStack(spacing: 28) {
            Spacer()

            Text("選んでるよ…")
                .font(.title3.weight(.bold))
                .foregroundColor(.secondary)

            VStack(spacing: 18) {
                categoryBadge(for: item.category)

                Text(item.name)
                    .font(.system(size: 30, weight: .black, design: .rounded))
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .minimumScaleFactor(0.7)
                    .frame(maxWidth: .infinity, minHeight: 84)
                    .padding(.horizontal, 16)
            }
            .padding(.vertical, 32)
            .padding(.horizontal, 20)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .fill(Color.cardBackground)
            )
            .shadow(color: Color.black.opacity(0.08), radius: 18, x: 0, y: 8)
            .padding(.horizontal, 24)
            .scaleEffect(revealPulse ? 1.0 : 0.98)
            .animation(.easeInOut(duration: 0.35).repeatForever(autoreverses: true), value: revealPulse)

            Spacer()
        }
        .onAppear { revealPulse = true }
    }

    private func resultView(for item: Item) -> some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(spacing: 20) {
                    Text("今日のおすすめ")
                        .font(.subheadline.weight(.semibold))
                        .foregroundColor(.secondary)
                        .padding(.top, 8)

                    mainCard(for: item)
                        .padding(.horizontal)

                    if !subItems.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("その他の候補")
                                .font(.headline)
                                .padding(.horizontal)

                            VStack(spacing: 10) {
                                ForEach(subItems) { sub in
                                    subItemRow(for: sub)
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
                    selectItem(item)
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
                    startReveal()
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
        }
    }

    private var emptyState: some View {
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
            Button("ここにする") {
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

    private func startReveal() {
        shuffleTask?.cancel()

        let candidates: [Item]
        if let mode = mode {
            candidates = allItems.filter { $0.category == mode }
        } else {
            candidates = allItems
        }

        guard !candidates.isEmpty else {
            mainItem = nil
            subItems = []
            shuffleItem = nil
            isShuffling = false
            return
        }

        let result = RecommendLogic.recommend(from: allItems, mode: mode)

        isShuffling = true
        mainItem = nil
        subItems = []
        shuffleItem = candidates.randomElement()

        let selectionHaptic = UISelectionFeedbackGenerator()
        selectionHaptic.prepare()

        shuffleTask = Task { @MainActor in
            let totalDuration: Double = 1.3
            let startInterval: Double = 0.06
            let endInterval: Double = 0.22
            var elapsed: Double = 0
            var tickCounter = 0
            var lastID: UUID? = shuffleItem?.id

            while elapsed < totalDuration && !Task.isCancelled {
                let progress = elapsed / totalDuration
                let interval = startInterval + (endInterval - startInterval) * progress * progress

                var next = candidates.randomElement()
                if candidates.count > 1 {
                    while next?.id == lastID {
                        next = candidates.randomElement()
                    }
                }
                lastID = next?.id
                shuffleItem = next

                tickCounter += 1
                if tickCounter % 2 == 0 {
                    selectionHaptic.selectionChanged()
                    selectionHaptic.prepare()
                }

                try? await Task.sleep(for: .seconds(interval))
                elapsed += interval
            }

            guard !Task.isCancelled else { return }

            shuffleItem = result.main
            try? await Task.sleep(for: .milliseconds(260))

            guard !Task.isCancelled else { return }

            UINotificationFeedbackGenerator().notificationOccurred(.success)

            withAnimation(.spring(response: 0.55, dampingFraction: 0.65)) {
                mainItem = result.main
                subItems = result.sub
                isShuffling = false
            }
        }
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

private struct DecisionScreen: View {
    let item: Item
    let onConfirm: () -> Void

    @State private var heroVisible = false
    @State private var contentVisible = false

    private var categoryColor: Color {
        item.category == .food ? .brandOrange : .brandGreen
    }

    private var categoryIcon: String {
        item.category == .food ? "fork.knife" : "figure.walk"
    }

    var body: some View {
        ZStack {
            Color.brandBackground.ignoresSafeArea()

            RadialGradient(
                colors: [categoryColor.opacity(0.22), Color.brandBackground.opacity(0)],
                center: .center,
                startRadius: 0,
                endRadius: 360
            )
            .ignoresSafeArea()

            DecorativeSparkles(color: categoryColor)

            VStack(spacing: 32) {
                Spacer()

                ZStack {
                    Circle()
                        .fill(categoryColor)
                        .frame(width: 140, height: 140)
                        .shadow(color: categoryColor.opacity(0.35), radius: 28, x: 0, y: 14)
                    Image(systemName: categoryIcon)
                        .font(.system(size: 56, weight: .semibold))
                        .foregroundColor(.white)
                }
                .scaleEffect(heroVisible ? 1 : 0.5)
                .opacity(heroVisible ? 1 : 0)

                VStack(spacing: 14) {
                    Text("ここに決まり！")
                        .font(.subheadline.weight(.bold))
                        .foregroundColor(categoryColor)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 6)
                        .background(
                            Capsule()
                                .fill(categoryColor.opacity(0.15))
                        )

                    Text(item.name)
                        .font(.system(size: 34, weight: .black, design: .rounded))
                        .foregroundColor(.primary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 32)

                    if !item.area.isEmpty {
                        Text(item.area)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
                .opacity(contentVisible ? 1 : 0)
                .offset(y: contentVisible ? 0 : 16)

                Spacer()

                Button {
                    onConfirm()
                } label: {
                    Text("楽しんできてね！")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding(.vertical, 18)
                        .frame(maxWidth: .infinity)
                        .background(
                            Capsule()
                                .fill(Color.brandTeal)
                        )
                        .shadow(color: Color.brandTeal.opacity(0.3), radius: 14, x: 0, y: 6)
                        .padding(.horizontal, 32)
                }
                .padding(.bottom, 40)
                .opacity(contentVisible ? 1 : 0)
            }
        }
        .onAppear {
            withAnimation(.spring(response: 0.55, dampingFraction: 0.65)) {
                heroVisible = true
            }
            withAnimation(.easeOut(duration: 0.45).delay(0.18)) {
                contentVisible = true
            }
        }
    }
}

private struct DecorativeSparkles: View {
    let color: Color

    private let positions: [(x: CGFloat, y: CGFloat, size: CGFloat, opacity: Double)] = [
        (0.18, 0.20, 22, 0.55),
        (0.78, 0.16, 16, 0.45),
        (0.88, 0.38, 24, 0.50),
        (0.10, 0.42, 14, 0.40),
        (0.25, 0.62, 18, 0.50),
        (0.72, 0.64, 16, 0.40),
        (0.16, 0.78, 12, 0.35),
        (0.82, 0.82, 20, 0.45)
    ]

    var body: some View {
        GeometryReader { geo in
            ForEach(0..<positions.count, id: \.self) { i in
                let p = positions[i]
                Image(systemName: "sparkle")
                    .font(.system(size: p.size, weight: .semibold))
                    .foregroundColor(color.opacity(p.opacity))
                    .position(x: geo.size.width * p.x, y: geo.size.height * p.y)
            }
        }
        .ignoresSafeArea()
    }
}
