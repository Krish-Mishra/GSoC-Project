//
//  GitHubModels.swift
//  GSoC-SwiftProject
//
//  Created by Krish Mishra on 01/03/26.
//

import Foundation

// The top-level array returned by https://api.github.com/repos/USER/REPO/commits
struct GitHubCommit: Codable, Identifiable {
    let id = UUID() // For SwiftUI Lists
    let sha: String
    let commit: CommitDetails
    
    // We only want the message and author info for now
    struct CommitDetails: Codable {
        let message: String
        let author: AuthorDetails
    }
    
    struct AuthorDetails: Codable {
        let name: String
        let date: String
    }
    
    // CodingKeys help if GitHub's JSON uses different naming than your Swift variables
    enum CodingKeys: String, CodingKey {
        case sha
        case commit
    }
}
