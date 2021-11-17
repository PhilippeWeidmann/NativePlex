//
//  ApiFetcher.swift
//  NativePlex
//
//  Created by Philippe Weidmann on 09.06.21.
//

import Foundation
import SwiftyXMLParser

enum NetworkError: Error {
    case networkError(underlyingError: Error?)
    case decodingError(underlyingError: Error?)
    case urlMalFormatted
    case bodyMalFormatted
    case serverError
    case apiError(details: ApiError)
}

enum ApiError: String, Error, Equatable {
    case unknown
}

enum HTTPMethod: String {
    case GET
    case POST
    case PUT
    case DELETE
}

class ApiFetcher {

    static let instance = ApiFetcher()
    private let decoder = JSONDecoder()
    private let encoder = JSONEncoder()

    private var headers = [String: String]()
    private var authenticatedHeaders: [String: String] {
        return headers.merging(["X-Plex-Token": SessionPreferences.shared.userToken ?? ""]) { current, _ in current }
    }

    private init() {
        headers = ["X-Plex-Product": "NativePlex", "X-Plex-Client-Identifier": ServerManager.shared.userId, "Accept": "application/json"]
    }

    func authenticatedHeadersFor(server: Server) -> [String: String] {
        return headers.merging(["X-Plex-Token": server.accessToken]) { current, _ in current }
    }

    func getToken(for pinId: Int, code: String, completion: @escaping (CodeResponse?, NetworkError?) -> Void) {
        let getTokenUrl = "https://plex.tv/api/v2/pins/\(pinId)?code=\(code)&X-Plex-Client-Identifier=\(ServerManager.shared.userId)"
        request(url: getTokenUrl, headers: ["Accept": "application/json"], completion: completion)
    }

    func generateCode(completion: @escaping (CodeResponse?, NetworkError?) -> Void) {
        let getPinUrl = "https://plex.tv/api/v2/pins"
        request(url: getPinUrl, headers: ["Accept": "application/json"], method: .POST, body: ["strong": "true", "X-Plex-Client-Identifier": ServerManager.shared.userId, "X-Plex-Product": "NativePlex"], completion: completion)
    }

    func getServers(completion: @escaping (ServerResponse?, NetworkError?) -> Void) {
        let getServersUrl = "https://plex.tv/api/servers.xml"
        request(url: getServersUrl, headers: authenticatedHeaders, method: .GET, completion: completion)
    }

    func getMetadataDetails(server: Server, key: String, completion: @escaping (MediaContainerResponse<Metadata>?, NetworkError?) -> Void) {
        let metadataUrl = server.baseUrl?.appendingPathComponent("/library/metadata/\(key)")
        request(url: metadataUrl, headers: authenticatedHeadersFor(server: server), completion: completion)
    }

    func getMetadataForChildren(server: Server, key: String, completion: @escaping (MediaContainerResponse<Metadata>?, NetworkError?) -> Void) {
        let metadataUrl = server.baseUrl?.appendingPathComponent("\(key)")
        request(url: metadataUrl, headers: authenticatedHeadersFor(server: server), completion: completion)
    }

    func getMetadataFor(server: Server, section: String, completion: @escaping (MediaContainerResponse<Metadata>?, NetworkError?) -> Void) {
        let metadataUrl = server.baseUrl?.appendingPathComponent("/library/sections/\(section)/all")
        request(url: metadataUrl, headers: authenticatedHeadersFor(server: server), completion: completion)
    }

    func getDirectories(server: Server, completion: @escaping (MediaContainerResponse<Directory>?, NetworkError?) -> Void) {
        let sectionsUrl = server.baseUrl?.appendingPathComponent("/library/sections")
        request(url: sectionsUrl, headers: authenticatedHeadersFor(server: server), completion: completion)
    }

    func urlRequestFor(server: Server, imagePath: String) -> URLRequest? {
        if let url = server.baseUrl?.appendingPathComponent(imagePath) {
            var request = URLRequest(url: url)
            request.setValue(server.accessToken, forHTTPHeaderField: "X-Plex-Token")
            return request
        } else {
            return nil
        }
    }

    func playerUrlFor(server: Server, part: Part) -> URL? {
        guard let baseUrl = server.baseUrl else {
            return server.baseUrl
        }

        var urlComponents = URLComponents(url: baseUrl, resolvingAgainstBaseURL: true)
        urlComponents?.path = part.key
        urlComponents?.queryItems = [URLQueryItem(name: "X-Plex-Token", value: server.accessToken)]
        return urlComponents?.url
    }

    private func request<ResponseType: Codable>(url: String, headers: [String: String] = [:], method: HTTPMethod = .GET, body: [String: Any]? = nil, completion: @escaping (ResponseType?, NetworkError?) -> Void) {
        guard let url = URL(string: url) else {
            DispatchQueue.main.async {
                completion(nil, .urlMalFormatted)
            }
            return
        }
        request(url: url, headers: headers, method: method, body: body, completion: completion)
    }

    private func request<ResponseType: Codable>(url: URL?, headers: [String: String] = [:], method: HTTPMethod = .GET, body: [String: Any]? = nil, completion: @escaping (ResponseType?, NetworkError?) -> Void) {
        guard let url = url else {
            DispatchQueue.main.async {
                completion(nil, .urlMalFormatted)
            }
            return
        }
        request(url: url, headers: headers, method: method, body: body, completion: completion)
    }

    private func request<ResponseType: Codable>(url: URL, headers: [String: String] = [:], method: HTTPMethod = .GET, body: [String: Any]? = nil, completion: @escaping (ResponseType?, NetworkError?) -> Void) {
        request(url: url, headers: headers, method: method, body: body) { data, error in
            guard let data = data, error == nil else {
                DispatchQueue.main.async {
                    completion(nil, .networkError(underlyingError: error))
                }
                return
            }

            do {
                let response = try self.decoder.decode(ResponseType.self, from: data)
                DispatchQueue.main.async {
                    completion(response, nil)
                }
            } catch {
                DispatchQueue.main.async {
                    completion(nil, .decodingError(underlyingError: error))
                }
            }
        }
    }

    private func request<ResponseType: XMLDecodable>(url: String, headers: [String: String] = [:], method: HTTPMethod = .GET, body: [String: Any]? = nil, completion: @escaping (ResponseType?, NetworkError?) -> Void) {
        guard let url = URL(string: url) else {
            DispatchQueue.main.async {
                completion(nil, .urlMalFormatted)
            }
            return
        }
        request(url: url, headers: headers, method: method, body: body, completion: completion)
    }

    private func request<ResponseType: XMLDecodable>(url: URL?, headers: [String: String] = [:], method: HTTPMethod = .GET, body: [String: Any]? = nil, completion: @escaping (ResponseType?, NetworkError?) -> Void) {
        guard let url = url else {
            DispatchQueue.main.async {
                completion(nil, .urlMalFormatted)
            }
            return
        }
        request(url: url, headers: headers, method: method, body: body, completion: completion)
    }

    private func request<ResponseType: XMLDecodable>(url: URL, headers: [String: String] = [:], method: HTTPMethod = .GET, body: [String: Any]? = nil, completion: @escaping (ResponseType?, NetworkError?) -> Void) {
        request(url: url, headers: headers, method: method, body: body) { data, error in
            guard let data = data, error == nil else {
                DispatchQueue.main.async {
                    completion(nil, .networkError(underlyingError: error))
                }
                return
            }

            do {
                let xml = XML.parse(data)
                if let root = xml.element?.childElements.first {
                    let response = try ResponseType(root: root)
                    DispatchQueue.main.async {
                        completion(response, nil)
                    }
                } else {
                    throw(XMLError.accessError(description: "Missing root"))
                }
            } catch {
                DispatchQueue.main.async {
                    completion(nil, .decodingError(underlyingError: error))
                }
            }
        }
    }

    private func request(url: String, headers: [String: String] = [:], method: HTTPMethod = .GET, body: [String: Any]? = nil, completion: @escaping (Data?, NetworkError?) -> Void) {
        guard let url = URL(string: url) else {
            DispatchQueue.main.async {
                completion(nil, .urlMalFormatted)
            }
            return
        }
        request(url: url, headers: headers, method: method, body: body, completion: completion)
    }

    private func request(url: URL?, headers: [String: String] = [:], method: HTTPMethod = .GET, body: [String: Any]? = nil, completion: @escaping (Data?, NetworkError?) -> Void) {
        guard let url = url else {
            DispatchQueue.main.async {
                completion(nil, .urlMalFormatted)
            }
            return
        }
        request(url: url, headers: headers, method: method, body: body, completion: completion)
    }

    private func request(url: URL, headers: [String: String] = [:], method: HTTPMethod = .GET, body: [String: Any]? = nil, completion: @escaping (Data?, NetworkError?) -> Void) {
        var request = URLRequest(url: url)
        for (key, value) in headers {
            request.setValue(value, forHTTPHeaderField: key)
        }

        request.httpMethod = method.rawValue
        if let body = body {
            guard let percentEncodedBody = body.percentEncoded() else {
                DispatchQueue.main.async {
                    completion(nil, .bodyMalFormatted)
                }
                return
            }
            request.httpBody = percentEncodedBody
        }
        URLSession.shared.dataTask(with: request) { data, _, error in
            guard let data = data, error == nil else {
                DispatchQueue.main.async {
                    completion(nil, .networkError(underlyingError: error))
                }
                return
            }

            DispatchQueue.main.async {
                completion(data, nil)
            }
        }.resume()
    }
}

extension Dictionary {
    func percentEncoded() -> Data? {
        return map { key, value in
            let escapedKey = "\(key)".addingPercentEncoding(withAllowedCharacters: .urlQueryValueAllowed) ?? ""
            let escapedValue = "\(value)".addingPercentEncoding(withAllowedCharacters: .urlQueryValueAllowed) ?? ""
            return escapedKey + "=" + escapedValue
        }
            .joined(separator: "&")
            .data(using: .utf8)
    }
}

extension CharacterSet {
    static let urlQueryValueAllowed: CharacterSet = {
        let generalDelimitersToEncode = ":#[]@" // does not include "?" or "/" due to RFC 3986 - Section 3.4
        let subDelimitersToEncode = "!$&'()*+,;="

        var allowed = CharacterSet.urlQueryAllowed
        allowed.remove(charactersIn: "\(generalDelimitersToEncode)\(subDelimitersToEncode)")
        return allowed
    }()
}
