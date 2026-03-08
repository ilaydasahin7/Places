//
//  WikipediaRedirectionHelper.swift
//  Places
//
//  Created by İlayda Şahin on 8.03.2026.
//

import UIKit

struct WikipediaRedirectionHelper {
    static func openPlaces(latitude: Double, longitude: Double) async -> Bool {
        let urlString = "wikipedia://places/?latitude=\(latitude)&longitude=\(longitude)"
        
        guard let url = URL(string: urlString) else {
            return false
        }
        
        return await UIApplication.shared.open(url)
    }
}

