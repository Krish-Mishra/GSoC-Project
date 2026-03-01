//
//  CommitViewModel.swift
//  GSoC-SwiftProject
//
//  Created by Krish Mishra on 01/03/26.
//

import Foundation

@Observable
class CommitViewModel {
    var commits: [GitHubCommit] = []
    var isLoading = false
    var errorMessage: String?
    
    private let service = GitHubService()
    
    func loadCommits(for repo: String) async {
        isLoading = true
        errorMessage = nil
        
        do {
            let fetchedCommits = try await service.fetchCommits(for: repo)

            self.commits = fetchedCommits
            self.isLoading = false
        } catch {
            self.errorMessage = "Failed to load: \(error.localizedDescription)"
            self.isLoading = false
        }
    }
}
