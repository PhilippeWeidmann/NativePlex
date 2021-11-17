//
//  Server.swift
//  NativePlex
//
//  Created by Philippe Weidmann on 26.06.21.
//

import Foundation
import SwiftyXMLParser

class Server: XMLDecodable {

    let accessToken: String
    let name: String
    let scheme: String
    let address: String
    let localAddress: String
    let port: Int
    var directories = [Directory]()
    var baseUrl: URL? {
        var urlBuilder = URLComponents()
        urlBuilder.scheme = scheme
        urlBuilder.host = address
        urlBuilder.port = Int(port)
        return urlBuilder.url
    }

    required init(root: XML.Element) throws {
        if let accessToken = root.attributes["accessToken"],
            let name = root.attributes["name"],
            let scheme = root.attributes["scheme"],
            let address = root.attributes["address"],
            let localAddress = root.attributes["localAddresses"],
            let rawPort = root.attributes["port"],
            let port = Int(rawPort) {
            self.accessToken = accessToken
            self.name = name
            self.scheme = scheme
            self.address = address
            self.localAddress = localAddress
            self.port = port
        } else {
            throw(XMLError.accessError(description: "Missing attribute"))
        }
    }

}
