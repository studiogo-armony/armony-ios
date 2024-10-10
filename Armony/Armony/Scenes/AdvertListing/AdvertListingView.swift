//
//  AdvertListingView.swift
//  Armony
//
//  Created by KORAY YILDIZ on 17/09/2024.
//

import SwiftUI

private struct Constants {
    static let gridViewVerticalPadding = 10.0
    static let cardHorizontalPadding = 20.0
    static let cardHeight = 186.0
}

struct AdvertListingView: View {

    @ObservedObject var viewModel: AdvertListingViewModel

    private let columns = [
        GridItem(.flexible())
    ]

    init(viewModel: AdvertListingViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        ScrollView(.vertical) {
            gridView
        }
        .background(Color(.armonyBlack))
        .task {
            await viewModel.fetchAdverts()
        }
    }

    private var gridView: some View {
        LazyVGrid(columns: columns, content: {
            ForEach(viewModel.cards) { item in
                cardView(item)
                    .onTapGesture {
                        ZuhalAcademyAdvertAdjustEvent().send()
                        let eventLabel = item.skillsPresentation.skills.map { $0.title.string }.joined(separator: .comma)
                        ZuhalAcademyAdvertFirebaseEvent(label: eventLabel).send()
                        viewModel.coordinator.advert(id: item.id, colorCode: item.colorCode)
                    }
            }
        })
        .padding(.vertical, Constants.gridViewVerticalPadding)
    }

    private func cardView(_ item: CardPresentation) -> some View {
        return SwiftUICardView(presentation: item)
            .frame(height: Constants.cardHeight)
            .padding(.horizontal, Constants.cardHorizontalPadding)
    }
}

private struct ZuhalAcademyAdvertAdjustEvent: AdjustEvent {
    var token: String = "scd9hx"
}

private struct ZuhalAcademyAdvertFirebaseEvent: FirebaseEvent {
    var name: String = "click_card"
    var category: String = "Zuhal Akademi"
    var action: String = "Click Card"
    var label: String
}

// MARK: - Preview
#Preview {
    AdvertListingView(viewModel: .init())
}
