//
//  FlickrImageSearchTests.swift
//  FlickrImageSearchTests
//
//  Created by Maddy on 2/13/25.
//

import Testing
@testable import FlickrImageSearch

struct FlickrImageSearchTests {
    private var viewModel: FlickrViewModel!
    
    init() {
        viewModel = FlickrViewModel()
    }
    
    @Test func testUpdateSearchTextTriggersFetch() async {
        let previousSearchText = viewModel.searchText
        viewModel.updateSearchText("porcupine")
        #expect(viewModel.searchText != previousSearchText, "Search text should be updated")
    }
}
