//
//  ImageDetailView.swift
//  FlickrImageSearch
//
//  Created by Maddy on 2/13/25.
//

import SwiftUI

struct ImageDetailView: View {
    let photo: FlickrImage
    let dimensions: ImageDimensions?
    
    init(photo: FlickrImage) {
        self.photo = photo
        self.dimensions = ImageDimensions.extractFromDescription(photo.description)
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // 1. Image
                AsyncImage(url: URL(string: photo.media.originalURL)) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(maxWidth: .infinity)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .shadow(radius: 5)
                } placeholder: {
                    ProgressView()
                        .frame(height: 300)
                }
                
                // 2. Title and metadata container
                VStack(alignment: .leading, spacing: 16) {
                    // Title
                    Text(photo.title)
                        .font(.title2)
                        .bold()
                        .fixedSize(horizontal: false, vertical: true)
                    
                    // Author and date section
                    HStack(spacing: 12) {
                        // Author with icon
                        Label {
                            Text(formatAuthor(photo.author))
                        } icon: {
                            Image(systemName: "person.circle.fill")
                        }
                        .foregroundColor(.secondary)
                        
                        Divider()
                            .frame(height: 16)
                        
                        // Date with icon
                        Label {
                            Text(formatDate(photo.published))
                        } icon: {
                            Image(systemName: "calendar")
                        }
                        .foregroundColor(.secondary)
                    }
                    .font(.subheadline)
                    
                    // Image dimensions section
                    if let dimensions = dimensions {
                        Label {
                            Text("\(dimensions.width) × \(dimensions.height) pixels")
                        } icon: {
                            Image(systemName: "rectangle.dashed")
                        }
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    }
                    
                    // Description section
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Description")
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        Text(cleanDescription(photo.description))
                            .font(.body)
                            .foregroundColor(.secondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .padding(.top, 8)
                }
                .padding(.horizontal)
            }
            .padding(.vertical)
        }
        .navigationBarTitleDisplayMode(.inline)
        .background(Color(.systemBackground))
    }
    
    // Helper functions
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
    
    private func formatAuthor(_ author: String) -> String {
        let components = author.components(separatedBy: "\"")
        return components.count >= 2 ? components[1] : author
    }
    
    private func cleanDescription(_ description: String) -> String {
        // First remove HTML tags
        var cleanText = description.replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression)
        
        // Remove multiple spaces
        cleanText = cleanText.replacingOccurrences(of: "\\s+", with: " ", options: .regularExpression)
        
        // Remove any remaining HTML entities
        cleanText = cleanText.replacingOccurrences(of: "&[^;]+;", with: "", options: .regularExpression)
        
        return cleanText.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}

// Structure to hold image dimensions
struct ImageDimensions {
    let width: Int
    let height: Int
    
    static func extractFromDescription(_ description: String) -> ImageDimensions? {
        // Regular expression to match dimensions in format "width="X" height="Y""
        let pattern = #"width="(\d+)".*?height="(\d+)""#
        
        guard let regex = try? NSRegularExpression(pattern: pattern),
              let match = regex.firstMatch(in: description,
                                           range: NSRange(description.startIndex..., in: description)) else {
            return nil
        }
        
        // Extract width and height values
        guard let widthRange = Range(match.range(at: 1), in: description),
              let heightRange = Range(match.range(at: 2), in: description),
              let width = Int(description[widthRange]),
              let height = Int(description[heightRange]) else {
            return nil
        }
        
        return ImageDimensions(width: width, height: height)
    }
}
