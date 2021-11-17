//
//  Metadata.swift
//  NativePlex
//
//  Created by Philippe Weidmann on 09.06.21.
//

import Foundation

class Metadata: Codable {
    let title: String?
    let ratingKey: String?
    let key: String?
    let year: Int?
    let art: String?
    let type: MediaType?
    let thumb: String?
    let summary: String?
    let duration: Int?
    let childCount: Int?
    let leafCount: Int?
    let medias: [Media]?
    let genres: [Genre]?
    let roles: [Role]?
    let index: Int?

    enum CodingKeys: String, CodingKey {
        case title
        case type
        case ratingKey
        case key
        case year
        case art
        case thumb
        case summary
        case childCount
        case leafCount
        case duration
        case index
        case medias = "Media"
        case genres = "Genre"
        case roles = "Role"
    }

}
