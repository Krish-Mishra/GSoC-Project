//
//  GitHubService.swift
//  GSoC-SwiftProject
//
//  Created by Krish Mishra on 01/03/26.
//

import Foundation

@Observable
class GitHubService {
    // 1. Using your secure token
    private let token = Secrets.gitHubToken
    
    // 2. The main function to fetch commits
    func fetchCommits(for repoPath: String) async throws -> [GitHubCommit] {
        // Example path: "Krish-Mishra/GSoC-Project"
        let urlString = "https://api.github.com/repos/\(repoPath)/commits"
        
        guard let url = URL(string: urlString) else {
            throw URLError(.badURL)
        }
        
        // 3. Set up the request with your token for higher rate limits
        var request = URLRequest(url: url)
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/vnd.github+json", forHTTPHeaderField: "Accept")
        
        // 4. Perform the network call (Networking basics from your video #23)
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }
        
        // 5. Decode the JSON into your GitHubCommit models (Video #22 logic)
        let decoder = JSONDecoder()
        // GitHub uses ISO8601 dates, so we tell the decoder how to handle them
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        decoder.dateDecodingStrategy = .formatted(formatter)
        
        return try decoder.decode([GitHubCommit].self, from: data)
    }
}
