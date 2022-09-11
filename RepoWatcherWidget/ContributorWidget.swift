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
        Task {
            let nextUpdate = Date().addingTimeInterval(43200) // 12 hours in seconds
            
            do {
                // Get repo
                let repoToShow = RepoURL.elixirRepoURL
                var repo = try await NetworkManager.shared.getRepo(atUrl: repoToShow)
                let avatar = await NetworkManager.shared.downloadImageData(from: repo.owner.avatarUrl)
                repo.avatarData = avatar ?? Data()
                
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
                
                // Create entry and timeline
                let entry = ContributorEntry(date: .now, repo: repo)
                let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
                completion(timeline)
            } catch {
                print("😵 Error - \(error.localizedDescription)")
            }
        }
    }
}

struct ContributorEntry: TimelineEntry {
    var date: Date
    let repo: Repository
}

struct ContributorEntryView : View {
    var entry: ContributorEntry
    
    var body: some View {
        ZStack {
            Color(uiColor: .tertiarySystemBackground)
            VStack() {
                RepoMediumView(repo: entry.repo)
                ContributorMediumView(repo: entry.repo)
            }
            
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
