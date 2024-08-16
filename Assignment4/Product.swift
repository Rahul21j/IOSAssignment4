//
//  Product.swift
//  Assignment4
//
//  Created by Kishan Jayswal on 2024-08-12.
//

import Foundation
struct RatingObject: Decodable {
    let rate: Double
    let count: Int
}

struct Product: Decodable {
    let id: Int
    let title: String
    let price: Double
    let description: String
    let category: String
    let image: String
    let rating: RatingObject
}
