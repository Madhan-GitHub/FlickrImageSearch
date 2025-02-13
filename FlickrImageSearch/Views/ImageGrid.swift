//
//  ImageGrid.swift
//  FlickrImageSearch
//
//  Created by Maddy on 2/13/25.
//

import SwiftUI

struct ImageGrid: View {
    let photo: FlickrImage
    
    var body: some View {
        AsyncImage(url: URL(string: photo.media.m)) { image in
            image
                .resizable()
                .scaledToFill()
                .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
                .clipped()
                .aspectRatio(1, contentMode: .fit)
        } placeholder: {
            ProgressView()
                .frame(width: 108, height: 108)
                .background(Color.gray.opacity(0.1))
        }
        .clipped()
        .contentShape(Rectangle())
    }
}
