//
//  CommitViewModel.swift
//  GSoC-SwiftProject
//
//  Created by Krish Mishra on 01/03/26.
//

import Foundation
import SwiftData

@Observable
class CommitViewModel {
    var commits: [GitHubCommit] = []
    var isLoading = false
    var errorMessage: String?
    
    private let service = GitHubService()
    
    func generateAISummary(modelContext: ModelContext) async {
        guard !commits.isEmpty else { return }
        
        isAnalyzing = true
        
        do {
            let summary = try await aiService.summarize(commits: commits)
            self.aiSummary = summary
            let newHistoryEntry = SavedSummary(repoName: "GSoC Project", summaryContent: summary)
                    modelContext.insert(newHistoryEntry)
        } catch {
            self.errorMessage = "AI failed: \(error.localizedDescription)"
        }
        
        isAnalyzing = false
    }
    
    func loadCommits(for repo: String) async {
        self.aiSummary = nil
        self.errorMessage = nil
        
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
    
    var aiSummary: String?
        var isAnalyzing = false
        private let aiService = OpenRouterService()
        func generateSummary() async {
            guard !commits.isEmpty else { return }
            
            isAnalyzing = true
            do {
                // This calls the service we just fixed!
                let summary = try await aiService.summarize(commits: commits)
                self.aiSummary = summary
            } catch {
                print("AI Error: \(error.localizedDescription)")
            }
            isAnalyzing = false
        }
}
