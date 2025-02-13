//
//  ContentView.swift
//  FlickrImageSearch
//
//  Created by Maddy on 2/13/25.
//

import SwiftUI

import SwiftUI

struct ContentView: View {
    @State private var viewModel = FlickrViewModel()
    
    // Define grid layout with adaptive columns for responsive design
    let columns = [
        GridItem(.adaptive(minimum: 100), spacing: 1),
        GridItem(.adaptive(minimum: 100), spacing: 1),
        GridItem(.adaptive(minimum: 100), spacing: 1)
    ]
    
    var body: some View {
        NavigationStack {
            ZStack {
                VStack {
                    // Search progress indicator
                    if viewModel.isSearching {
                        ProgressView("Searching...")
                            .padding()
                    }
                    
                    ScrollView {
                        LazyVGrid(columns: columns, spacing: 1) {
                            ForEach(viewModel.photos) { photo in
                                NavigationLink(destination: ImageDetailView(photo: photo)) {
                                    ImageGrid(photo: photo)
                                }
                            }
                        }
                    }
                }
                
                // Loading of "Flickr Images" view
                if viewModel.isLoading {
                            ProgressView()
                }
            }
            .navigationTitle("Flickr Images")
            .searchable(
                text: .init(
                    get: { viewModel.searchText },
                    set: { viewModel.updateSearchText($0) }
                ),
                prompt: "Search images"
            )
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        Task {
                            await viewModel.refreshPhotos()
                        }
                    }) {
                        Image(systemName: "arrow.clockwise")
                    }
                }
            }
        }
        .task {
            await viewModel.fetchImages()
        }
    }
}

#Preview {
    ContentView()
}
