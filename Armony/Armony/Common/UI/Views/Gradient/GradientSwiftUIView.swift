//
//  GradientSwiftUIView.swift
//  Armony
//
//  Created by KORAY YILDIZ on 19.07.2025.
//

import SwiftUI

struct GradientSwiftUIView: View {

    private let colors: [Color]
    private let startPoint: UnitPoint
    private let endPoint: UnitPoint

    init(presentation: GradientPresentation) {
        colors = presentation.color.colors.compactMap {
            $0.swiftUIColor
        }
        startPoint = UnitPoint(
            x: presentation.orientation.startPoint.x,
            y: presentation.orientation.startPoint.y
        )
        endPoint = UnitPoint(
            x: presentation.orientation.endPoint.x,
            y: presentation.orientation.endPoint.y
        )
    }

    var body: some View {
        Color.clear
            .background(
                LinearGradient(
                    gradient: Gradient(colors: colors),
                    startPoint: startPoint,
                    endPoint: endPoint
                )
            )
    }
}

#Preview {
    GradientSwiftUIView(presentation: .separator)
        .frame(width: .infinity, height: 1)
        .background(.armonyDarkBlue)
}
