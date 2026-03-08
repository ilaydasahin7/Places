//
//  CustomLocationView.swift
//  Places
//
//  Created by İlayda Şahin on 8.03.2026.
//

import SwiftUI

struct CustomLocationView: View {
    @StateObject private var viewModel = CustomLocationViewModel()
    @Binding var isPresented: Bool
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Latitude")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        TextField("e.g., 52.3676", text: $viewModel.latitudeText)
                            .keyboardType(.decimalPad)
                            .textFieldStyle(.roundedBorder)
                            .accessibilityLabel("Latitude")
                            .accessibilityIdentifier("customLocation.latitude")
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Longitude")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        TextField("e.g., 4.9041", text: $viewModel.longitudeText)
                            .keyboardType(.decimalPad)
                            .textFieldStyle(.roundedBorder)
                            .accessibilityLabel("Longitude")
                            .accessibilityIdentifier("customLocation.longitude")
                    }
                } header: {
                    Text("Enter Coordinates")
                } footer: {
                    Text("Latitude: -90 to 90, Longitude: -180 to 180")
                        .font(.caption2)
                }
                
                Section {
                    Button(action: {
                        viewModel.openInWikipedia()
                        if viewModel.errorMessage == nil {
                            isPresented = false
                        }
                    }) {
                        HStack {
                            Spacer()
                            Text("Open in Wikipedia")
                                .fontWeight(.semibold)
                            Spacer()
                        }
                    }
                    .disabled(!viewModel.isValid)
                    .accessibilityIdentifier("customLocation.openWikipedia")
                }
            }
            .navigationTitle("Custom Location")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        isPresented = false
                    }
                    .accessibilityIdentifier("customLocation.cancel")
                }
            }
            .alert("Error", isPresented: Binding(
                get: { viewModel.errorMessage != nil },
                set: { if !$0 { viewModel.errorMessage = nil } }
            )) {
                Button("OK") { }
                    .accessibilityIdentifier("customLocation.error.ok")
            } message: {
                Text(viewModel.errorMessage ?? "An unknown error occurred.")
            }
        }
    }
}

#Preview {
    CustomLocationView(isPresented: .constant(true))
}
