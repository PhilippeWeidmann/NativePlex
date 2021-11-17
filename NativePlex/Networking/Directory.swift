//
//  Section.swift
//  NativePlex
//
//  Created by Philippe Weidmann on 11.06.21.
//

import Foundation
import UIKit

enum MediaType: String, Codable {
    case show
    case movie
    case season
    case episode
    case photo

    var icon: UIImage {
        switch self {
        case .show:
            return UIImage(systemName: "tv")!
        case .movie:
            return UIImage(systemName: "film")!
        default:
            return UIImage(systemName: "film")!
        }
    }
}

class Directory: Codable {
    let key: String
    let title: String
    let type: MediaType
}
