//
//  TagLayout.swift
//  Armony
//
//  Created by KORAY YILDIZ on 19.07.2025.
//

import SwiftUI

public struct TagLayout<Data: RandomAccessCollection, Content: View>: View where Data.Element: Hashable {

    let items: Data
    let content: (Data.Element) -> Content

    @State private var totalHeight = CGFloat.zero

    public var body: some View {
        GeometryReader { geometry in
            generateContent(in: geometry)
        }
        .frame(height: totalHeight)
    }

    private func generateContent(in proxy: GeometryProxy) -> some View {
        var width = CGFloat.zero
        var height = CGFloat.zero

        return ZStack(alignment: .topLeading) {
            ForEach(items, id: \.self) { tag in
                content(tag)
                    .alignmentGuide(.leading) { dimension in
                        if abs(width - dimension.width) > proxy.size.width {
                            width = .zero
                            height -= dimension.height
                        }
                        let result = width
                        if tag == items.last {
                            width = .zero
                        } else {
                            width -= dimension.width
                        }
                        return result
                    }
                    .alignmentGuide(.top) { _ in
                        let result = height
                        if tag == items.last {
                            height = .zero
                        }
                        return result
                    }
            }
        }
        .background(viewHeightReader($totalHeight))
    }

    private func viewHeightReader(_ binding: Binding<CGFloat>) -> some View {
        GeometryReader { geometry in
            Color.clear
                .preference(key: ViewHeightKey.self, value: geometry.size.height)
        }
        .onPreferenceChange(ViewHeightKey.self) {
            binding.wrappedValue = $0
        }
    }

    private struct ViewHeightKey: PreferenceKey {

        typealias Value = CGFloat

        static var defaultValue: CGFloat {
            .zero
        }

        static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
            value = max(value, nextValue())
        }
    }
}

