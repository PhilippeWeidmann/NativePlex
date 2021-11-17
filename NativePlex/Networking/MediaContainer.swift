//
//  MediaContainer.swift
//  NativePlex
//
//  Created by Philippe Weidmann on 09.06.21.
//

import Foundation

class MediaContainerResponse<Content: Codable>: Codable {
    let mediaContainer: MediaContainer<Content>

    enum CodingKeys: String, CodingKey {
        case mediaContainer = "MediaContainer"
    }

}

class MediaContainer<Content: Codable>: Codable {
    let content: [Content]

    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: ContentCodingKey.self)
        content = try values.decode([Content].self, forKey: ContentCodingKey(stringValue: String(describing: Content.self))!)
    }

    struct ContentCodingKey: CodingKey {
        var stringValue: String

        init?(stringValue: String) {
            self.stringValue = stringValue
        }

        var intValue: Int?

        init?(intValue: Int) {
            self.intValue = intValue
            stringValue = "\(intValue)"
        }
    }

}
