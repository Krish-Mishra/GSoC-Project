//
//  HistoryView.swift
//  GSoC-SwiftProject
//
//  Created by Krish Mishra on 02/03/26.
//

import SwiftUI
import SwiftData

struct HistoryView: View {
    @Query(sort: \SavedSummary.date, order: .reverse) var histories: [SavedSummary]
    @Environment(\.modelContext) private var modelContext

    var body: some View {
        NavigationStack {
            List {
                ForEach(histories) { history in
                    VStack(alignment: .leading, spacing: 8) {
                        Text(history.repoName)
                            .font(.headline)
                        Text(history.date.formatted(date: .abbreviated, time: .shortened))
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Text(history.summaryContent)
                            .font(.subheadline)
                            .lineLimit(3)
                    }
                    .padding(.vertical, 4)
                }
                .onDelete(perform: deleteHistory)
            }
            .navigationTitle("History")
        }
    }

    private func deleteHistory(offsets: IndexSet) {
        for index in offsets {
            modelContext.delete(histories[index])
        }
    }
}
