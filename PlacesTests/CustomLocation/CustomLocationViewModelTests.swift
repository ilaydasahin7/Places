//
//  CustomLocationViewModelTests.swift
//  PlacesTests
//
//  Created by İlayda Şahin on 8.03.2026.
//

import Testing
@testable import Places

@MainActor
struct CustomLocationViewModelTests {
    @Test
    func isValid_returnsTrue_forInRangeCoordinates() {
        let viewModel = CustomLocationViewModel()
        viewModel.latitudeText = " 52.3676 "
        viewModel.longitudeText = " 4.9041 "

        #expect(viewModel.isValid == true)
    }

    @Test
    func isValid_returnsFalse_forOutOfRangeCoordinates() {
        let viewModel = CustomLocationViewModel()
        viewModel.latitudeText = "91"
        viewModel.longitudeText = "181"

        #expect(viewModel.isValid == false)
    }
}
