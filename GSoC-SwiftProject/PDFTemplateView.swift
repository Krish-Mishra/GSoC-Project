//
//  PDFTemplateView.swift
//  GSoC-SwiftProject
//
//  Created by Krish Mishra on 02/03/26.
//

import SwiftUI

struct PDFTemplateView: View {
    let history: SavedSummary
    
    var body: some View {
        VStack(alignment: .leading, spacing: 30) {
            // Header Section
            VStack(alignment: .leading, spacing: 10) {
                Text("CommitSage AI Report")
                    .font(.system(size: 32, weight: .bold))
                Text("Project: \(history.repoName)")
                    .font(.title2)
                Text("Date: \(history.date.formatted())")
                    .font(.subheadline).foregroundStyle(.secondary)
            }
            
            Divider()
            
            // 🚀 Content: fixedSize ensures the renderer calculates total height
            Text(LocalizedStringKey(history.summaryContent))
                .font(.body)
                .lineSpacing(8)
                .fixedSize(horizontal: false, vertical: true)
            
            // 🚀 Spacer ensures the last page has a bottom margin
            Spacer(minLength: 100)
        }
        .padding(.horizontal, 60) // Professional side margins
        .padding(.top, 60)        // Top margin for Page 1
        .padding(.bottom, 100)    // 🚀 Safety buffer for page breaks
        .frame(width: 595)        // Standard A4 width
        .background(Color.white)
    }
}
