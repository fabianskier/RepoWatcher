//
//  ContributorWidget.swift
//  RepoWatcherWidgetExtension
//
//  Created by Oscar Cristaldo on 2022-08-21.
//

import WidgetKit
import SwiftUI

struct ContributorProvider: TimelineProvider {
    func placeholder(in context: Context) -> ContributorEntry {
        ContributorEntry(date: .now, repo: MockData.repoOne)
    }
    
    func getSnapshot(in context: Context, completion: @escaping (ContributorEntry) -> Void) {
        let entry = ContributorEntry(date: .now, repo: MockData.repoOne)
        completion(entry)
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<ContributorEntry>) -> Void) {
        let nextUpdate = Date().addingTimeInterval(43200) // 12 hours in seconds
        let entry = ContributorEntry(date: .now, repo: MockData.repoOne)
        let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
        completion(timeline)
    }
}

struct ContributorEntry: TimelineEntry {
    var date: Date
    let repo: Repository
}

struct ContributorEntryView : View {
    var entry: ContributorEntry
    
    var body: some View {
        VStack {
            RepoMediumView(repo: entry.repo)
            ContributorMediumView()
        }
    }
}

struct ContributorWidget: Widget {
    
    let kind: String = "ContributorWidget"
    
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: ContributorProvider()) { entry in
            ContributorEntryView(entry: entry)
        }
        .configurationDisplayName("Contributors")
        .description("Keep track of a repository.s top contributors.")
        .supportedFamilies([.systemLarge])
    }
}

struct ContributorWidget_Previews: PreviewProvider {
    static var previews: some View {
        ContributorEntryView(entry: ContributorEntry(date: Date(), repo: MockData.repoOne))
            .previewContext(WidgetPreviewContext(family: .systemLarge))
    }
}
