//
//  ContentView.swift
//  GSoC-SwiftProject
//
//  Created by Krish Mishra on 26/02/26.
//

import SwiftUI

struct ContentView: View {
    @State private var viewModel = CommitViewModel()
    
    var body: some View {
        NavigationStack {
            Group {
                if viewModel.isLoading {
                    ProgressView("Analyzing GitHub Data...")
                        .controlSize(.large)
                } else if let error = viewModel.errorMessage {
                    ContentUnavailableView("Connection Error",
                                           systemImage: "exclamationmark.triangle",
                                           description: Text(error))
                } else {
                    List(viewModel.commits) { commit in
                        VStack(alignment: .leading, spacing: 8) {
                            Text(commit.commit.message)
                                .font(.headline)
                                .lineLimit(2)
                            
                            HStack {
                                Label(commit.commit.author.name, systemImage: "person.circle")
                                Spacer()
                                Text(commit.sha.prefix(7))
                                    .font(.caption.monospaced())
                                    .padding(4)
                                    .background(Color.secondary.opacity(0.2))
                                    .cornerRadius(4)
                            }
                            .font(.caption)
                            .foregroundColor(.secondary)
                        }
                        .padding(.vertical, 4)
                    }
                }
            }
            .navigationTitle("CommitSage")
            .task {
                await viewModel.loadCommits(for: "Krish-Mishra/GSoC-Project")
            }
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        Task { await viewModel.loadCommits(for: "Krish-Mishra/GSoC-Project") }
                    } label: {
                        Image(systemName: "arrow.clockwise")
                    }
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
