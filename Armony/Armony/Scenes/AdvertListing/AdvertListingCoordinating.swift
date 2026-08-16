//
//  AdvertListingCoordinating.swift
//  Armony
//
//  Created by Koray Yildiz on 16.08.26.
//

import Foundation

protocol AdvertListingCoordinating: CoordinatorInterface {
    func advert(id: Int, colorCode: String)
}
