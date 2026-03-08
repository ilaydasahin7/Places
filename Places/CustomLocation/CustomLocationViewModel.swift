//
//  CustomLocationViewModel.swift
//  Places
//
//  Created by İlayda Şahin on 8.03.2026.
//

import Combine
import SwiftUI

@MainActor
final class CustomLocationViewModel: ObservableObject {
    @Published var latitudeText: String = ""
    @Published var longitudeText: String = ""
    @Published var errorMessage: String?
    
    func openInWikipedia() {
        guard let lat = Double(latitudeText.trimmingCharacters(in: .whitespaces)),
              let long = Double(longitudeText.trimmingCharacters(in: .whitespaces)) else {
            return
        }
        
        Task {
            let success = await WikipediaRedirectionHelper.openPlaces(latitude: lat, longitude: long)
            if !success {
                errorMessage = "Failed to open Wikipedia app"
            }
        }
    }
    
    var isValid: Bool {
        guard let lat = Double(latitudeText.trimmingCharacters(in: .whitespaces)),
              let long = Double(longitudeText.trimmingCharacters(in: .whitespaces)) else {
            return false
        }
        return lat >= -90 && lat <= 90 && long >= -180 && long <= 180
    }
}
