//
//  MockLocationService.swift
//  PlacesTests
//

import Foundation
@testable import Places

final class MockLocationService: LocationServiceProtocol {
    private let result: Result<[Location], Error>

    init(result: Result<[Location], Error>) {
        self.result = result
    }

    func fetchLocations() async throws -> [Location] {
        try result.get()
    }
}
