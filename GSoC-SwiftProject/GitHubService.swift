//
//  GitHubService.swift
//  GSoC-SwiftProject
//
//  Created by Krish Mishra on 01/03/26.
//

import Foundation

@Observable
class GitHubService {
    private let token = Secrets.gitHubToken
    
    func fetchCommits(for repoPath: String) async throws -> [GitHubCommit] {
        let urlString = "https://api.github.com/repos/\(repoPath)/commits"
        
        guard let url = URL(string: urlString) else {
            throw URLError(.badURL)
        }
        
        var request = URLRequest(url: url)
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/vnd.github+json", forHTTPHeaderField: "Accept")
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }
        
        let decoder = JSONDecoder()
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        decoder.dateDecodingStrategy = .formatted(formatter)
        
        return try decoder.decode([GitHubCommit].self, from: data)
    }
}
