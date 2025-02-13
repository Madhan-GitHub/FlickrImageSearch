//
//  FlickrViewModel.swift
//  FlickrImageSearch
//
//  Created by Maddy on 2/13/25.
//

import Foundation
import SwiftUI
import Combine

@Observable
final class FlickrViewModel {
    // MARK: - Public Properties
    var photos: [FlickrImage] = []
    var searchText = ""
    var isLoading = false
    var isSearching = false
    var errorMessage: String?
    
    // MARK: - Private Properties
    private let baseURL = "https://api.flickr.com/services/feeds/photos_public.gne?format=json&nojsoncallback=1&tags=porcupine"
    private var cancellables = Set<AnyCancellable>()
    private let cache = NSCache<NSString, NSArray>()
    private let searchSubject = PassthroughSubject<String, Never>()
    
    // MARK: - Initialization
    init() {
        setupSearchSubscription()
    }
    
    // MARK: - Private Methods
    private func setupSearchSubscription() {
        // Debounce search input to prevent excessive API calls
        searchSubject
            .debounce(for: .milliseconds(600), scheduler: DispatchQueue.main)
            .removeDuplicates()
            .sink { [weak self] _ in
                Task { @MainActor in
                    await self?.fetchImages()
                }
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Public Methods
    func updateSearchText(_ newText: String) {
        searchText = newText
        searchSubject.send(newText)
    }
    
    @MainActor
    func fetchImages() async {
        // Show loading indicator based on whether it's initial load or search
        if photos.isEmpty {
            isLoading = true
        } else {
            isSearching = true
        }
        errorMessage = nil
        
        do {
            // Check cache first
            let cacheKey = NSString(string: searchText)
            if let cachedPhotos = cache.object(forKey: cacheKey) as? [FlickrImage] {
                photos = cachedPhotos
                isLoading = false
                isSearching = false
                return
            }
            
            // Build URL with search parameters
            var urlString = baseURL
            if !searchText.isEmpty {
                let tags = searchText
                    .components(separatedBy: " ")
                    .filter { !$0.isEmpty }
                    .joined(separator: ",")
                
                if let encodedTags = tags.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) {
                    urlString += "&tags=\(encodedTags)"
                }
            }
            
            guard let url = URL(string: urlString) else {
                throw URLError(.badURL)
            }
            
            let (data, _) = try await URLSession.shared.data(from: url)
            
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            
            let result = try decoder.decode(FlickrFeedResult.self, from: data)
            photos = result.items
            cache.setObject(result.items as NSArray, forKey: cacheKey)
            
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
        isSearching = false
    }
    
    func clearCache() {
        cache.removeAllObjects()
    }
    
    @MainActor
    func refreshPhotos() async {
        clearCache()
        await fetchImages()
    }
}
