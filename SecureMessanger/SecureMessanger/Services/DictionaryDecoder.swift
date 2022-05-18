//
//  DictionaryDecoder.swift
//  SecureMessanger
//
//  Created by Maksym Paidych on 18.05.2022.
//

import UIKit

class DictionaryDecoder {
    private let jsonDecoder = JSONDecoder()
    
    private init() {}
    
    static let shared = DictionaryDecoder()
    
    func decode<T>(_ type: T.Type, from json: Any) throws -> T where T: Decodable {
        let jsonData = try JSONSerialization.data(withJSONObject: json, options: [])
        return try jsonDecoder.decode(type, from: jsonData)
    }
}

extension Encodable {

    var dict : [String: Any]? {
        guard let data = try? JSONEncoder().encode(self) else { return nil }
        guard let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String:Any] else { return nil }
        return json
    }
}
