//
//  OpenRouterService.swift
//  GSoC-SwiftProject
//
//  Created by Krish Mishra on 01/03/26.
//

import Foundation

@Observable
class OpenRouterService {
    private let apiKey = Secrets.openRouterKey
    private let url = URL(string: "https://openrouter.ai/api/v1/chat/completions")!

    func summarize(commits: [GitHubCommit]) async throws -> String {
        let commitMessages = commits.map { $0.commit.message }.joined(separator: "\n")
        
        // Define the JSON payload
        let parameters: [String: Any] = [
            "model": "google/gemini-2.0-flash-001",
            "messages": [
                [
                    "role": "system",
                    "content": """
                    You are a Senior Technical Lead. Summarize GitHub commits using this exact format with proper heading font differentiation
                    and also proper spacing, indentations and keep it detailed of at least one full page. Give spaces between the lines so that it becomes easier to read the summary. Also I am giving you the template so here make the headings like key highihts and technical details as heading font and then layer or format the inner content in the suitable sub heading manner, start with the main topic itself and dont say anything else, and keep in mind all the heading guidelines I gave you:
                    ### 🚀 Key Highlights
                    * **[Category]**: Brief description of the change.
                    ### 🛠 Technical Details
                    * Mention specific files or architectural patterns improved.
                    """
                ],
                ["role": "user", "content": commitMessages]
            ]
        ]
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("CommitSage-App", forHTTPHeaderField: "HTTP-Referer") // Required by OpenRouter
        request.httpBody = try? JSONSerialization.data(withJSONObject: parameters)

        let (data, _) = try await URLSession.shared.data(for: request)
        
        // Parse the response
        if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
           let choices = json["choices"] as? [[String: Any]],
           let message = choices.first?["message"] as? [String: Any],
           let content = message["content"] as? String {
            return content
        }
        
        return "Failed to parse AI response."
    }
}
