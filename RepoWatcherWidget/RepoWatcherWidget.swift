//
//  RepoWatcherWidget.swift
//  RepoWatcherWidget
//
//  Created by Oscar Cristaldo on 2022-08-13.
//

import WidgetKit
import SwiftUI

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> RepoEntry {
        RepoEntry(date: Date(), repo: MockData.repoOne, bottomRepo: MockData.repoTwo)
    }
    
    func getSnapshot(in context: Context, completion: @escaping (RepoEntry) -> ()) {
        let entry = RepoEntry(date: Date(), repo: MockData.repoOne, bottomRepo: MockData.repoTwo)
        completion(entry)
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        Task {
            let nextUpdate = Date().addingTimeInterval(43200) // 12 hours in seconds
            
            do {
                // get top repo
                var repo = try await NetworkManager.shared.getRepo(atUrl: RepoURL.elixirRepoURL)
                let avatar = await NetworkManager.shared.downloadImageData(from: repo.owner.avatarUrl)
                repo.avatarData = avatar ?? Data()
                
                // get bottom repo if in large widget
                var bottomRepo: Repository?
                if context.family == .systemLarge {
                    bottomRepo = try await NetworkManager.shared.getRepo(atUrl: RepoURL.livebookRepoURL)
                    let avatar = await NetworkManager.shared.downloadImageData(from: bottomRepo!.owner.avatarUrl)
                    bottomRepo!.avatarData = avatar ?? Data()
                }
                
                // create entry and timeline
                let entry = RepoEntry(date: .now, repo: repo, bottomRepo: bottomRepo)
                let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
                completion(timeline)
            } catch {
                print("😵 Error - \(error.localizedDescription)")
            }
        }
    }
}

struct RepoEntry: TimelineEntry {
    let date: Date
    let repo: Repository
    let bottomRepo: Repository?
}

struct RepoWatcherWidgetEntryView : View {
    
    var entry: Provider.Entry
    @Environment(\.widgetFamily) var family
    
    var body: some View {
        switch family {
        case .systemSmall:
            EmptyView()
        case .systemMedium:
            RepoMediumView(repo: entry.repo)
        case .systemLarge:
            VStack(spacing: 36) {
                RepoMediumView(repo: entry.repo)
                if let bottomRepo = entry.bottomRepo {
                    RepoMediumView(repo: bottomRepo)
                }
            }
        case .systemExtraLarge, .accessoryCircular, .accessoryRectangular, .accessoryInline:
            EmptyView()
        @unknown default:
            EmptyView()
        }
        
    }
}

@main
struct RepoWatcherWidget: Widget {
    
    let kind: String = "RepoWatcherWidget"
    
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            RepoWatcherWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Repo Watcher")
        .description("Keep an eye on one or two GitHub repositories.")
        .supportedFamilies([.systemMedium, .systemLarge])
    }
}

struct RepoWatcherWidget_Previews: PreviewProvider {
    static var previews: some View {
        RepoWatcherWidgetEntryView(entry: RepoEntry(date: Date(), repo: MockData.repoOne, bottomRepo: MockData.repoTwo))
            .previewContext(WidgetPreviewContext(family: .systemMedium))
        RepoWatcherWidgetEntryView(entry: RepoEntry(date: Date(), repo: MockData.repoOne, bottomRepo: MockData.repoTwo))
            .previewContext(WidgetPreviewContext(family: .systemLarge))
    }
}

