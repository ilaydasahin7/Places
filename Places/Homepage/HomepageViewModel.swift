//
//  HomepageViewModel.swift
//  Places
//
//  Created by İlayda Şahin on 8.03.2026.
//

import Combine
import SwiftUI

final class HomepageViewModel: ObservableObject {
    @Published var locations: [Location] = []
    
    init() {
        locations = [
            Location(name: "Amsterdam", lat: 52.3676, long: 4.9041),
            Location(name: "Istanbul", lat: 41.0082, long: 28.9784),
            Location(name: "Mumbai", lat: 19.0760, long: 72.8777),
            Location(name: nil, lat: 40.4381, long: -3.7496)
        ]
    }
    
    func openInWikipedia(location: Location) {
        guard let lat = location.lat, let long = location.long else {
            return
        }
        
        Task {
            await WikipediaRedirectionHelper.openPlaces(latitude: lat, longitude: long)
        }
    }
}
