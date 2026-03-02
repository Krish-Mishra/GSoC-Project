//
//  HistoryDetailsView.swift
//  GSoC-SwiftProject
//
//  Created by Krish Mishra on 02/03/26.
//

import SwiftUI
import QuickLook

struct HistoryDetailsView: View {
    let history: SavedSummary
    @State private var selectedURL: URL?
    
    @MainActor
    func generatePDF() -> URL? {
        let url = FileManager.default.temporaryDirectory.appendingPathComponent("\(history.repoName)_Report.pdf")
        
        let pageWidth: CGFloat = 595.2
        let pageHeight: CGFloat = 841.8
        let margin: CGFloat = 60.0
        let renderRect = CGRect(x: margin, y: margin, width: pageWidth - (margin * 2), height: pageHeight - (margin * 2))
        
        let renderer = UIGraphicsPDFRenderer(bounds: CGRect(x: 0, y: 0, width: pageWidth, height: pageHeight))
        
        let titleFont = UIFont.systemFont(ofSize: 26, weight: .bold)
        let subTitleFont = UIFont.systemFont(ofSize: 16, weight: .semibold)
        let bodyFont = UIFont.systemFont(ofSize: 12, weight: .regular)
        let boldFont = UIFont.systemFont(ofSize: 12, weight: .bold)
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 6
        
        let fullContent = NSMutableAttributedString(string: "CommitSage AI Report\n", attributes: [.font: titleFont])
        fullContent.append(NSAttributedString(string: "Project: \(history.repoName)\n", attributes: [.font: subTitleFont]))
        fullContent.append(NSAttributedString(string: "Generated: \(history.date.formatted())\n\n", attributes: [.font: bodyFont, .foregroundColor: UIColor.secondaryLabel]))
        
        let rawSummary = history.summaryContent
        let attributedBody = NSMutableAttributedString(string: rawSummary, attributes: [.font: bodyFont, .paragraphStyle: paragraphStyle])
        
        let regex = try? NSRegularExpression(pattern: "\\*\\*(.*?)\\*\\*", options: [])
        let range = NSRange(location: 0, length: rawSummary.utf16.count)
        
        regex?.enumerateMatches(in: rawSummary, options: [], range: range) { match, _, _ in
            if let matchRange = match?.range(at: 1) {
                attributedBody.addAttribute(.font, value: boldFont, range: matchRange)
            }
        }
        
        let cleanBody = attributedBody.string.replacingOccurrences(of: "**", with: "")
        let finalBody = NSMutableAttributedString(string: cleanBody, attributes: [.font: bodyFont, .paragraphStyle: paragraphStyle])
        
        fullContent.append(attributedBody)
        
        do {
            try renderer.writePDF(to: url) { context in
                var currentRange = NSRange(location: 0, length: 0)
                let framesetter = CTFramesetterCreateWithAttributedString(fullContent)
                
                while currentRange.location < fullContent.length {
                    context.beginPage()
                    let path = CGPath(rect: renderRect, transform: nil)
                    let frame = CTFramesetterCreateFrame(framesetter, CFRange(location: currentRange.location, length: 0), path, nil)
                    
                    let cgContext = context.cgContext
                    cgContext.saveGState()
                    cgContext.translateBy(x: 0, y: pageHeight)
                    cgContext.scaleBy(x: 1.0, y: -1.0)
                    
                    CTFrameDraw(frame, cgContext)
                    cgContext.restoreGState()
                    
                    let visibleRange = CTFrameGetVisibleStringRange(frame)
                    currentRange.location += visibleRange.length
                }
            }
            return url
        } catch {
            return nil
        }
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text(history.date.formatted(date: .long, time: .shortened))
                    .font(.caption)
                    .foregroundStyle(.secondary)
                
                Text(LocalizedStringKey(history.summaryContent))
                    .font(.body)
                    .textSelection(.enabled)
            }
            .padding()
        }
        .quickLookPreview($selectedURL)
        .navigationTitle(history.repoName)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                        print("DEBUG: Button tapped!")
                        Task { @MainActor in
                            if let url = generatePDF() {
                                print("DEBUG: URL created at \(url)")
                                self.selectedURL = url
                            } else {
                                print("DEBUG: generatePDF returned nil")
                            }
                        }
                    } label: {
                        Image(systemName: "doc.viewfinder")
                }
                ShareLink(item: history.shareableText,
                    subject: Text("CommitSage Summary: \(history.repoName)"),
                    preview: SharePreview("AI Summary", image: Image(systemName: "doc.text")))
            }
        }
    }
}
