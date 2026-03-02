//
//  ContentView.swift
//  GSoC-SwiftProject
//
//  Created by Krish Mishra on 26/02/26.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @State var viewModel = CommitViewModel()
    @Environment(\.modelContext) private var modelContext
    
    var body: some View {
        TabView {
            NavigationStack {
                VStack {
                    if viewModel.isLoading {
                        ProgressView("Analyzing GitHub Data...")
                            .controlSize(.large)
                    } else if let error = viewModel.errorMessage {
                        ContentUnavailableView(
                            "Connection Error",
                            systemImage: "exclamationmark.triangle",
                            description: Text(error)
                        )
                    } else {
                        List {
                            Section("AI Insights") {
                                if viewModel.isAnalyzing {
                                    HStack {
                                        Spacer()
                                        ProgressView("Generating Summary...")
                                        Spacer()
                                    }
                                } else if let summary = viewModel.aiSummary {
                                    Text(LocalizedStringKey(summary))
                                        .font(.body)
                                        .padding(.vertical, 8)
                                        .textSelection(.enabled)
                                } else {
                                    Button {
                                        Task {
                                            await viewModel.generateAISummary(modelContext: modelContext)
                                        }
                                    } label: {
                                        Label("Generate AI Summary", systemImage: "sparkles")
                                            .fontWeight(.bold)
                                    }
                                }
                            }
                            
                            Section("Recent Commits") {
                                ForEach(viewModel.commits) { commit in
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
            .tabItem {
                Label("Analyze", systemImage: "magnifyingglass")
            }
            
            HistoryView()
                .tabItem {
                    Label("History", systemImage: "clock.arrow.circlepath")
                }
        }
    }
}

#Preview {
    ContentView()
}
