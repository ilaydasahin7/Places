//
//  Location.swift
//  Places
//
//  Created by İlayda Şahin on 8.03.2026.
//

import Foundation

struct Location: Identifiable, Decodable {
    let id = UUID()
    let name: String?
    let lat: Double?
    let long: Double?
    
    var displayName: String {
        if let name = name {
            return name
        }
        if let lat = lat, let long = long {
            return String(format: "%.4f, %.4f", lat, long)
        }
        return "Unknown Location"
    }
    
    enum CodingKeys: String, CodingKey {
        case name
        case lat
        case long
    }
}
