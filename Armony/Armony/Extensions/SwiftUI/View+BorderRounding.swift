//
//  View+BorderRounding.swift
//  Armony
//
//  Created by KORAY YILDIZ on 19.07.2025.
//

import SwiftUI

private struct BorderRounding: ViewModifier {

    private let border: AppTheme.Border
    private let color: Color
    private let radius: AppTheme.Radius

    init(border: AppTheme.Border, color: Color, radius: AppTheme.Radius) {
        self.border = border
        self.color = color
        self.radius = radius
    }

    func body(content: Content) -> some View {
        content
            .background(
                Color(.clear)
            )
            .cornerRadius(radius: radius)
            .overlay {
                RoundedRectangle(cornerRadius: radius.rawValue)
                    .stroke(color, lineWidth: border.rawValue)
            }
    }
}

public extension View {
    func border(border: AppTheme.Border = .default, color: Color, radius: AppTheme.Radius) -> some View {
        modifier(BorderRounding(border: border, color: color, radius: radius))
    }

    func border(border: AppTheme.Border = .default, color: UIColor, radius: AppTheme.Radius) -> some View {
        modifier(BorderRounding(border: border, color: color.swiftUIColor, radius: radius))
    }
}
