//
//  View+Additions.swift
//  Armony
//
//  Created by KORAY YILDIZ on 19.07.2025.
//

import SwiftUI

public extension View {
    func frame(size: CGSize) -> some View {
        frame(width: size.width, height: size.width)
    }

    func padding(_ edges: Edge.Set, spacing: AppTheme.Spacing) -> some View {
        padding(edges, spacing.rawValue)
    }
}

// MARK: - VStack

extension VStack where Content: View {
    init(alignment: HorizontalAlignment = .center, distance: AppTheme.Spacing?, @ViewBuilder content: () -> Content) {
        self.init(alignment: alignment, spacing: distance.zeroIfNil(), content: content)
    }
}

// MARK: Optional + AppTheme.Spacing

private extension Optional where Wrapped == AppTheme.Spacing {
    func zeroIfNil() -> CGFloat {
        self?.rawValue ?? .zero
    }
}
