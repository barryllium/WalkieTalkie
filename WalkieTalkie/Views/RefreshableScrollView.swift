// 
//  RefreshableScrollView.swift
//  WalkieTalkie
//
//  Created by Brett Keck on 11/1/21.
//

import SwiftUI

struct RefreshableScrollView<Content: View>: View {
    @State private var previousScrollOffset: CGFloat = 0
    @State private var scrollOffset: CGFloat = 0
    @State private var isFrozen: Bool = false
    @State private var rotation: Angle = .degrees(0)

    var threshold: CGFloat = 80
    @Binding var isRefreshing: Bool
    @Binding var canRefresh: Bool
    var startRefresh: () -> Void
    let content: Content

    init(height: CGFloat = 80,
         isRefreshing: Binding<Bool>,
         canRefresh: Binding<Bool>,
         startRefresh: @escaping () -> Void,
         @ViewBuilder content: () -> Content) {
        _isRefreshing = isRefreshing
        _canRefresh = canRefresh
        self.startRefresh = startRefresh
        self.threshold = height
        self.content = content()
    }

    var body: some View {
        VStack {
            ScrollView {
                ZStack(alignment: .top) {
                    MovingView()

                    VStack { self.content }.alignmentGuide(.top) { _ in (self.isRefreshing && self.isFrozen) ? -self.threshold : 0.0 }

                    SymbolView(height: self.threshold, loading: self.isRefreshing, frozen: self.isFrozen, rotation: self.rotation)
                }
            }
            .background(FixedView())
            .onPreferenceChange(RefreshableKeyTypes.PrefKey.self) { values in
                self.refreshLogic(values: values)
            }
        }
    }

    func refreshLogic(values: [RefreshableKeyTypes.PrefData]) {
        DispatchQueue.main.async {
            let movingBounds = values.first { $0.vType == .movingView }?.bounds ?? .zero
            let fixedBounds = values.first { $0.vType == .fixedView }?.bounds ?? .zero

            self.scrollOffset = movingBounds.minY - fixedBounds.minY

            self.rotation = self.symbolRotation(self.scrollOffset)

            if !self.isRefreshing && (self.scrollOffset > self.threshold && self.previousScrollOffset <= self.threshold) && canRefresh {
                startRefresh()
            }

            if self.isRefreshing {
                if self.previousScrollOffset > self.threshold && self.scrollOffset <= self.threshold {
                    self.isFrozen = true
                }
            } else {
                self.isFrozen = false
            }

            self.previousScrollOffset = self.scrollOffset
        }
    }

    func symbolRotation(_ scrollOffset: CGFloat) -> Angle {
        if scrollOffset < self.threshold * 0.60 {
            return .degrees(0)
        } else {
            let threshold = Double(self.threshold)
            let offset = Double(scrollOffset)
            let value = max(min(offset - (threshold * 0.6), threshold * 0.4), 0)
            return .degrees(180 * value / (threshold * 0.4))
        }
    }

    struct SymbolView: View {
        var height: CGFloat
        var loading: Bool
        var frozen: Bool
        var rotation: Angle

        var body: some View {
            Group {
                if self.loading {
                    VStack {
                        Spacer()
                        ActivityRep()
                        Spacer()
                    }.frame(height: height).fixedSize()
                        .offset(y: -height + (self.loading && self.frozen ? height : 0.0))
                } else {
                    Image(systemName: "arrow.down")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: height * 0.25, height: height * 0.25).fixedSize()
                        .padding(height * 0.375)
                        .rotationEffect(rotation)
                        .offset(y: -height + (loading && frozen ? +height : 0.0))
                }
            }
        }
    }

    struct MovingView: View {
        var body: some View {
            GeometryReader { proxy in
                Color.clear.preference(key: RefreshableKeyTypes.PrefKey.self, value: [RefreshableKeyTypes.PrefData(vType: .movingView, bounds: proxy.frame(in: .global))])
            }.frame(height: 0)
        }
    }

    struct FixedView: View {
        var body: some View {
            GeometryReader { proxy in
                Color.clear.preference(key: RefreshableKeyTypes.PrefKey.self, value: [RefreshableKeyTypes.PrefData(vType: .fixedView, bounds: proxy.frame(in: .global))])
            }
        }
    }
}

struct RefreshableKeyTypes {
    enum ViewType: Int {
        case movingView
        case fixedView
    }

    struct PrefData: Equatable {
        let vType: ViewType
        let bounds: CGRect
    }

    struct PrefKey: PreferenceKey {
        static var defaultValue: [PrefData] = []

        static func reduce(value: inout [PrefData], nextValue: () -> [PrefData]) {
            value.append(contentsOf: nextValue())
        }

        typealias Value = [PrefData]
    }
}

struct ActivityRep: UIViewRepresentable {
    func makeUIView(context: UIViewRepresentableContext<ActivityRep>) -> UIActivityIndicatorView {
        UIActivityIndicatorView()
    }

    func updateUIView(_ uiView: UIActivityIndicatorView, context: UIViewRepresentableContext<ActivityRep>) {
        uiView.startAnimating()
    }
}
