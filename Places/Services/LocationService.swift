//
//  LocationService.swift
//  Places
//
//  Created by İlayda Şahin on 8.03.2026.
//

import Foundation

protocol URLSessionProtocol {
    func data(from url: URL) async throws -> (Data, URLResponse)
}

extension URLSession: URLSessionProtocol {}

enum LocationServiceError: Error, LocalizedError {
    case invalidURL
    case networkError(Error)
    case decodingError(Error)
    case noData
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "The URL is invalid"
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        case .decodingError(let error):
            return "Failed to decode data: \(error.localizedDescription)"
        case .noData:
            return "No data received from server"
        }
    }
}

protocol LocationServiceProtocol {
    func fetchLocations() async throws -> [Location]
}

class LocationService: LocationServiceProtocol {
    private let urlString = "https://raw.githubusercontent.com/abnamrocoesd/assignment-ios/main/locations.json"
    private let urlSession: URLSessionProtocol
    
    init(urlSession: URLSessionProtocol = URLSession.shared) {
        self.urlSession = urlSession
    }
    
    func fetchLocations() async throws -> [Location] {
        guard let url = URL(string: urlString) else {
            throw LocationServiceError.invalidURL
        }
        
        let (data, response) = try await urlSession.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw LocationServiceError.noData
        }
        
        let decoder = JSONDecoder()
        do {
            let locationsResponse = try decoder.decode(LocationsResponse.self, from: data)
            return locationsResponse.locations
        } catch {
            throw LocationServiceError.decodingError(error)
        }
    }
}

private struct LocationsResponse: Decodable {
    let locations: [Location]
}

