//
//  ServerResponse.swift
//  NativePlex
//
//  Created by Philippe Weidmann on 26.06.21.
//

import Foundation
import SwiftyXMLParser

class ServerResponse: XMLDecodable {

    let servers: [Server]

    required init(root: XML.Element) throws {
        var servers = [Server]()
        for rawServer in root.childElements {
            let server = try Server(root: rawServer)
            servers.append(server)
        }
        self.servers = servers
    }

}
