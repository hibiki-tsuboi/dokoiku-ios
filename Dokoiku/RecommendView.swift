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
    @State private var heroVisible = false
    @State private var burstVisible = false
    @State private var contentVisible = false

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
                    VStack(spacing: 2) {
                        Text("今日のおすすめは")
                            .font(.subheadline.weight(.semibold))
                            .foregroundColor(.secondary)
                        Text("ここ！")
                            .font(.system(size: 48, weight: .black, design: .rounded))
                            .foregroundColor(.primary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.top, 16)
                    .opacity(heroVisible ? 1 : 0)
                    .scaleEffect(heroVisible ? 1 : 0.85)

                    mainCard(for: item, showBurst: burstVisible)
                        .padding(.horizontal, 20)
                        .opacity(heroVisible ? 1 : 0)
                        .scaleEffect(heroVisible ? 1 : 0.92)

                    if !subItems.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("その他の候補")
                                .font(.headline)
                                .padding(.horizontal, 24)

                            VStack(spacing: 10) {
                                ForEach(subItems) { sub in
                                    subItemRow(for: sub)
                                }
                            }
                            .padding(.horizontal, 20)
                        }
                        .padding(.top, 8)
                        .opacity(contentVisible ? 1 : 0)
                        .offset(y: contentVisible ? 0 : 12)
                    }
                }
                .padding(.bottom, 24)
            }

            VStack(spacing: 6) {
                Button {
                    selectItem(item)
                } label: {
                    Text("ここにする")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding(.vertical, 18)
                        .frame(maxWidth: .infinity)
                        .background(
                            Capsule()
                                .fill(Color.brandTeal)
                        )
                        .shadow(color: Color.brandTeal.opacity(0.3), radius: 14, x: 0, y: 6)
                }

                Button {
                    startReveal()
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: "arrow.clockwise")
                            .font(.subheadline.weight(.semibold))
                        Text("もう一回")
                            .font(.subheadline.weight(.semibold))
                    }
                    .foregroundColor(.brandTeal)
                    .padding(.vertical, 12)
                    .frame(maxWidth: .infinity)
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 12)
            .opacity(contentVisible ? 1 : 0)
        }
        .onAppear {
            heroVisible = false
            burstVisible = false
            contentVisible = false

            withAnimation(.spring(response: 0.55, dampingFraction: 0.65)) {
                heroVisible = true
            }

            Task {
                try? await Task.sleep(for: .milliseconds(120))
                burstVisible = true
                try? await Task.sleep(for: .milliseconds(1100))
                burstVisible = false
            }

            withAnimation(.easeOut(duration: 0.45).delay(0.35)) {
                contentVisible = true
            }
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

    private func mainCard(for item: Item, showBurst: Bool = false) -> some View {
        let categoryColor: Color = item.category == .food ? .brandOrange : .brandGreen
        let categoryIcon = item.category == .food ? "fork.knife" : "figure.walk"

        return VStack(spacing: 18) {
            ZStack {
                if showBurst {
                    SparkleBurst(color: categoryColor)
                        .frame(width: 220, height: 220)
                        .allowsHitTesting(false)
                }
                Circle()
                    .fill(categoryColor)
                    .frame(width: 96, height: 96)
                    .shadow(color: categoryColor.opacity(0.35), radius: 18, x: 0, y: 8)
                Image(systemName: categoryIcon)
                    .font(.system(size: 40, weight: .semibold))
                    .foregroundColor(.white)
            }
            .padding(.top, 4)

            VStack(spacing: 8) {
                Text(item.name)
                    .font(.system(size: 32, weight: .black, design: .rounded))
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 8)

                if !item.area.isEmpty {
                    Text(item.area)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }

            if !item.memo.isEmpty {
                Text(item.memo)
                    .font(.body)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(16)
                    .background(
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .fill(Color.brandBackground.opacity(0.7))
                    )
            }

            VStack(alignment: .leading, spacing: 6) {
                Text("おすすめ理由")
                    .font(.caption.weight(.bold))
                    .foregroundColor(categoryColor)
                Text(recommendationReason(for: item))
                    .font(.subheadline)
                    .foregroundColor(.primary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(28)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(Color.cardBackground)
        )
        .shadow(color: Color.black.opacity(0.07), radius: 18, x: 0, y: 6)
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
        let categoryColor: Color = item.category == .food ? .brandOrange : .brandGreen
        let categoryIcon = item.category == .food ? "fork.knife" : "figure.walk"

        return Button {
            selectItem(item)
        } label: {
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
                        .font(.subheadline.weight(.semibold))
                        .foregroundColor(.primary)
                    if !item.area.isEmpty {
                        Text(item.area)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                Spacer()
                Image(systemName: "arrow.right.circle.fill")
                    .font(.title3)
                    .foregroundColor(.brandTeal)
            }
            .padding(14)
            .background(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(Color.cardBackground)
            )
        }
        .buttonStyle(.plain)
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

private struct SparkleBurst: View {
    let color: Color

    @State private var animate = false

    private struct Sparkle {
        let angle: Double
        let distance: CGFloat
        let size: CGFloat
        let delay: Double
    }

    private let sparkles: [Sparkle] = [
        Sparkle(angle: -80,  distance: 95,  size: 22, delay: 0.00),
        Sparkle(angle: -40,  distance: 105, size: 18, delay: 0.05),
        Sparkle(angle:   0,  distance: 90,  size: 24, delay: 0.02),
        Sparkle(angle:  40,  distance: 100, size: 20, delay: 0.08),
        Sparkle(angle:  80,  distance: 85,  size: 16, delay: 0.04),
        Sparkle(angle: 130,  distance: 95,  size: 18, delay: 0.06),
        Sparkle(angle: 180,  distance: 80,  size: 20, delay: 0.03),
        Sparkle(angle: -130, distance: 90,  size: 22, delay: 0.07)
    ]

    var body: some View {
        ZStack {
            ForEach(0..<sparkles.count, id: \.self) { i in
                let s = sparkles[i]
                Image(systemName: "sparkle")
                    .font(.system(size: s.size, weight: .bold))
                    .foregroundColor(color)
                    .offset(
                        x: animate ? CGFloat(cos(.pi * s.angle / 180)) * s.distance : 0,
                        y: animate ? CGFloat(sin(.pi * s.angle / 180)) * s.distance : 0
                    )
                    .opacity(animate ? 0 : 1)
                    .scaleEffect(animate ? 1.3 : 0.3)
                    .animation(.easeOut(duration: 0.9).delay(s.delay), value: animate)
            }
        }
        .onAppear {
            animate = true
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
