//
//  FlickrImage.swift
//  FlickrImageSearch
//
//  Created by Maddy on 2/13/25.
//

import Foundation

/*
 Represents the top level response from Flickr API
 */
struct FlickrFeedResult: Codable {
    let items: [FlickrImage]
}

/*
 Represents a single Flickr image with its metadata
 */
struct FlickrImage: Codable, Identifiable {
    let media: Media
    let link: String
    let title: String
    let author: String
    let description: String
    let published: Date
    
    // Unique identifier for the image
    var id: String { link }
    
    enum CodingKeys: String, CodingKey {
        case media, link, title
        case description, published, author
    }
}

/*
 Represents the media URLs for the Flickr image
 */
struct Media: Codable {
    let m: String
    
    // Converts thumbnail URL to full-resolution URL
    var originalURL: String {
        m.replacingOccurrences(of: "_m.", with: ".")
    }
}
