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
                
                List {
                    ForEach(viewModel.locations) { location in
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
                        }
                        .buttonStyle(.plain)
                    }
                }
                .listStyle(.plain)
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showingCustomLocation = true
                    }) {
                        Image(systemName: "plus")
                            .font(.title3)
                    }
                }
            }
            .sheet(isPresented: $showingCustomLocation) {
                CustomLocationView(isPresented: $showingCustomLocation)
            }
        }
    }
}

#Preview {
    HomepageView()
}
