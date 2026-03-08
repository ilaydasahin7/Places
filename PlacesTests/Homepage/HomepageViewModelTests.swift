//
//  HomepageViewModelTests.swift
//  PlacesTests
//
//  Created by İlayda Şahin on 8.03.2026.
//

import Foundation
import Testing
@testable import Places

@MainActor
struct HomepageViewModelTests {
    private let amsterdamLocation = Location(name: "Amsterdam", lat: 52.3676, long: 4.9041)
    
    private func setUp(
        locationResult: Result<[Location], Error>
    ) -> HomepageViewModel {
        let locationService = MockLocationService(result: locationResult)
        return HomepageViewModel(locationService: locationService)
    }

    @Test
    func fetchPlaces_setsSuccessState_whenServiceReturnsLocations() async {
        let viewModel = setUp(locationResult: .success([amsterdamLocation]))

        await viewModel.fetchPlaces()

        switch viewModel.state {
        case .success(let locations):
            #expect(locations.count == 1)
            #expect(locations.first?.name == "Amsterdam")
            #expect(locations.first?.lat == 52.3676)
            #expect(locations.first?.long == 4.9041)
        default:
            Issue.record("Expected success state after fetching locations")
        }
    }

    @Test
    func fetchPlaces_setsFailureState_whenServiceThrowsError() async {
        let viewModel = setUp(locationResult: .failure(MockError.fetchFailed))

        await viewModel.fetchPlaces()

        switch viewModel.state {
        case .failure(let message):
            #expect(message == "Mock fetch failed")
        default:
            Issue.record("Expected failure state when service throws")
        }
    }

}

private enum MockError: LocalizedError {
    case fetchFailed

    var errorDescription: String? {
        switch self {
        case .fetchFailed:
            return "Mock fetch failed"
        }
    }
}
