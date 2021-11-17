//
//  XMLDecodable.swift
//  NativePlex
//
//  Created by Philippe Weidmann on 26.06.21.
//

import Foundation
import SwiftyXMLParser

protocol XMLDecodable {
    init(root: XML.Element) throws
}
