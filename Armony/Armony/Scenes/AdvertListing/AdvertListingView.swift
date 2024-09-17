//
//  AdvertListingView.swift
//  Armony
//
//  Created by KORAY YILDIZ on 17/09/2024.
//

import SwiftUI

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
                        viewModel.coordinator.advert(id: item.id, colorCode: item.colorCode)
                    }
            }
        })
        .padding(.vertical, 10)
    }

    private func cardView(_ item: CardPresentation) -> some View {
        return SwiftUICardView(presentation: item)
            .frame(height: 186)
            .padding(.horizontal, 10)
    }
}

#Preview {
    AdvertListingView(viewModel: .init())
}
