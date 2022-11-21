//
//  SingleRepoWidget.swift
//  RepoWatcherWidgetExtension
//
//  Created by Oscar Cristaldo on 2022-08-21.
//

import WidgetKit
import SwiftUI

struct SingleRepoProvider: IntentTimelineProvider {
    func placeholder(in context: Context) -> SingleRepoEntry {
        SingleRepoEntry(date: .now, repo: MockData.repoOne)
    }
    
    func getSnapshot(for configuration: SelectSingleRepoIntent, in context: Context, completion: @escaping (SingleRepoEntry) -> Void) {
        let entry = SingleRepoEntry(date: .now, repo: MockData.repoOne)
        completion(entry)
    }
    
    func getTimeline(for configuration: SelectSingleRepoIntent, in context: Context, completion: @escaping (Timeline<SingleRepoEntry>) -> Void) {
        Task {
            let nextUpdate = Date().addingTimeInterval(43200) // 12 hours in seconds
            
            do {
                // Get repo
                let repoToShow = RepoURL.prefix + configuration.repo!
                var repo = try await NetworkManager.shared.getRepo(atUrl: repoToShow)
                let avatar = await NetworkManager.shared.downloadImageData(from: repo.owner.avatarUrl)
                repo.avatarData = avatar ?? Data()
                
                if context.family == .systemLarge {
                    // Get contributors
                    let contributors = try await NetworkManager.shared.getContributors(atUrl: repoToShow + "/contributors")
                    
                    // Filter to just the top 4
                    var topFour = Array(contributors.prefix(4))
                    
                    // Download top 4 avatars
                    for i in topFour.indices {
                        let avatar = await NetworkManager.shared.downloadImageData(from: topFour[i].avatarUrl)
                        topFour[i].avatarData = avatar ?? Data()
                    }
                    
                    repo.contributors = topFour
                }
                
                // Create entry and timeline
                let entry = SingleRepoEntry(date: .now, repo: repo)
                let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
                completion(timeline)
            } catch {
                print("😵 Error - \(error.localizedDescription)")
            }
        }
    }
}

struct SingleRepoEntry: TimelineEntry {
    var date: Date
    let repo: Repository
}

struct SingleRepoEntryView : View {
    @Environment(\.widgetFamily) var family
    var entry: SingleRepoEntry
    
    var body: some View {
        switch family {
        case .systemMedium:
            RepoMediumView(repo: entry.repo)
        case .systemLarge:
            ZStack {
                Color(uiColor: .tertiarySystemBackground)
                VStack() {
                    RepoMediumView(repo: entry.repo)
                    ContributorMediumView(repo: entry.repo)
                }
            }
        case .accessoryInline:
            Text("\(entry.repo.name) - \(entry.repo.daysSinceLastActivity) days")
        case .accessoryCircular:
            ZStack {
                AccessoryWidgetBackground()
                VStack {
                    Text("\(entry.repo.daysSinceLastActivity)")
                        .font(.headline)
                    Text("days")
                        .font(.caption)
                }
            }
        case .accessoryRectangular:
            VStack(alignment: .leading) {
                Text("\(entry.repo.name)")
                    .font(.headline)
                Text("\(entry.repo.daysSinceLastActivity) days")
                HStack {
                    Image(systemName: "star.fill")
                        .resizable()
                        .frame(width: 12, height: 12)
                        .aspectRatio(contentMode: .fit)
                    Text("\(entry.repo.watchers)")
                    
                    Image(systemName: "tuningfork")
                        .resizable()
                        .frame(width: 12, height: 12)
                        .aspectRatio(contentMode: .fit)
                    Text("\(entry.repo.forks)")
                    
                    if entry.repo.hasIssues {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .resizable()
                            .frame(width: 12, height: 12)
                            .aspectRatio(contentMode: .fit)
                        Text("\(entry.repo.openIssues)")
                    }
                }
                .font(.caption)
            }
        case .systemSmall, .systemExtraLarge:
            EmptyView()
        @unknown default:
            EmptyView()
        }
    }
}

struct SingleRepoWidget: Widget {
    
    let kind: String = "SingleRepoWidget"
    
    var body: some WidgetConfiguration {
        IntentConfiguration(kind: kind, intent: SelectSingleRepoIntent.self, provider: SingleRepoProvider()) { entry in
            SingleRepoEntryView(entry: entry)
        }
        .configurationDisplayName("Single Repo")
        .description("Keep a single repository's.")
        .supportedFamilies([.systemMedium, .systemLarge, .accessoryInline, .accessoryCircular, .accessoryRectangular])
    }
}

struct SingleRepoWidget_Previews: PreviewProvider {
    static var previews: some View {
        SingleRepoEntryView(entry: SingleRepoEntry(date: Date(), repo: MockData.repoTwo))
            .previewContext(WidgetPreviewContext(family: .accessoryInline))
        SingleRepoEntryView(entry: SingleRepoEntry(date: Date(), repo: MockData.repoTwo))
            .previewContext(WidgetPreviewContext(family: .accessoryCircular))
        SingleRepoEntryView(entry: SingleRepoEntry(date: Date(), repo: MockData.repoTwo))
            .previewContext(WidgetPreviewContext(family: .accessoryRectangular))
    }
}
