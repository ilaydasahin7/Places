//
//  HomepageView.swift
//  Places
//
//  Created by İlayda Şahin on 8.03.2026.
//

import SwiftUI

struct HomepageView: View {
    @StateObject private var viewModel = HomepageViewModel()
    @State private var showingCustomLocation = false
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                Text("Places")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                    .background(Color(.systemBackground))
                    .accessibilityIdentifier("homepage.title")
                
                switch viewModel.state {
                case .loading:
                    Spacer()
                    ProgressView()
                        .accessibilityLabel("Loading places")
                        .accessibilityIdentifier("homepage.loading")
                    Spacer()
                    
                case .success(let locations):
                    List {
                        ForEach(locations) { location in
                            Button(action: {
                                viewModel.openInWikipedia(location: location)
                            }) {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(location.displayName)
                                        .font(.headline)
                                        .foregroundColor(.primary)
                                    
                                    if let lat = location.lat, let long = location.long {
                                        HStack {
                                            Text("Lat: \(lat, specifier: "%.4f")")
                                                .font(.caption)
                                                .foregroundColor(.secondary)
                                            
                                            Text("•")
                                                .foregroundColor(.secondary)
                                            
                                            Text("Long: \(long, specifier: "%.4f")")
                                                .font(.caption)
                                                .foregroundColor(.secondary)
                                        }
                                    }
                                }
                                .padding(.vertical, 4)
                                .contentShape(Rectangle())
                                .accessibilityLabel(locationAccessibilityLabel(for: location))
                            }
                            .buttonStyle(.plain)
                            .accessibilityIdentifier("homepage.location.\(location.id)")
                        }
                    }
                    .listStyle(.plain)
                    .accessibilityIdentifier("homepage.locations.list")
                    
                case .failure(let error):
                    Spacer()
                    VStack(spacing: 16) {
                        Text("Error")
                            .font(.headline)
                        Text(error)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                        Button("Retry") {
                            Task {
                                await viewModel.fetchPlaces()
                            }
                        }
                        .accessibilityIdentifier("homepage.retry")
                    }
                    .padding()
                    Spacer()
                }
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showingCustomLocation = true
                    }) {
                        Image(systemName: "plus")
                            .font(.title3)
                    }
                    .accessibilityLabel("Add custom location")
                    .accessibilityIdentifier("homepage.addCustomLocation")
                }
            }
            .sheet(isPresented: $showingCustomLocation) {
                CustomLocationView(isPresented: $showingCustomLocation)
            }
            .onAppear {
                Task {
                    await viewModel.fetchPlaces()
                }
            }
        }
    }
    
    private func locationAccessibilityLabel(for location: Location) -> String {
        if let lat = location.lat, let long = location.long {
            return "\(location.displayName). Latitude \(String(format: "%.4f", lat)), Longitude \(String(format: "%.4f", long))"
        }
        
        return location.displayName
    }
}

#Preview {
    HomepageView()
}
