//
//  Codable+Extensions.swift
//  Portal
//
//  Created by Rolando Rodriguez on 8/23/19.
//

import Foundation
import FirebaseFirestore

public extension Encodable where Self: PortalModel {
    /// Returns a JSON dictionary, with choice of minimal information
    func firestoreObject() -> [String: Any]? {
        let encoder = JSONEncoder()
        guard let data = try? encoder.encode(self) else { return nil }
        do {
            guard let dictionary = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String:Any] else {return nil}
            return dictionary
        }
        catch (let error) { print(error.localizedDescription); return nil}
    }
}

public extension Decodable where Self: PortalModel {
    /// Initialize from JSON Dictionary. Return nil on failure
    init?(dictionary value: [String:Any]){
        
        guard JSONSerialization.isValidJSONObject(value) else {print("Invalid due to timestamp type"); return nil }
        guard let jsonData = try? JSONSerialization.data(withJSONObject: value, options: []) else { return nil }
        guard let newValue = try? JSONDecoder().decode(Self.self, from: jsonData) else { return nil }
        self = newValue
    }
}
