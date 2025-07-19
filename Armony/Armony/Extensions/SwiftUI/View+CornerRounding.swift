//
//  View+CornerRounding.swift
//  Armony
//
//  Created by KORAY YILDIZ on 19.07.2025.
//

import SwiftUI

private struct CornerRounding: ViewModifier {

    private let radius: AppTheme.Radius

    init(radius: AppTheme.Radius) {
        self.radius = radius
    }

    func body(content: Content) -> some View {
        content
            .clipShape(
                RoundedRectangle(cornerRadius: radius.rawValue)
            )
    }
}

public extension View {
    func cornerRadius(radius: AppTheme.Radius) -> some View {
        modifier(CornerRounding(radius: radius))
    }
}
