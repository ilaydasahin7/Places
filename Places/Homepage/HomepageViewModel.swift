//
//  HomepageViewModel.swift
//  Places
//
//  Created by İlayda Şahin on 8.03.2026.
//

import Combine
import SwiftUI

enum HomepageState {
    case loading
    case success([Location])
    case failure(String)
}

@MainActor
final class HomepageViewModel: ObservableObject {
    @Published var state: HomepageState = .loading
    
    private let locationService: LocationServiceProtocol
    
    init(locationService: LocationServiceProtocol = LocationService()) {
        self.locationService = locationService
    }
    
    func fetchPlaces() async {
        state = .loading
        
        do {
            let fetchedLocations = try await locationService.fetchLocations()
            state = .success(fetchedLocations)
        } catch {
            state = .failure(error.localizedDescription)
        }
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
