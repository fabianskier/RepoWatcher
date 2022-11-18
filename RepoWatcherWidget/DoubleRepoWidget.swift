//
//  RepoWatcherWidget.swift
//  RepoWatcherWidget
//
//  Created by Oscar Cristaldo on 2022-08-13.
//

import WidgetKit
import SwiftUI

struct DoubleRepoProvider: TimelineProvider {
    func placeholder(in context: Context) -> DoubleRepoEntry {
        DoubleRepoEntry(date: Date(), topRepo: MockData.repoOne, bottomRepo: MockData.repoTwo)
    }
    
    func getSnapshot(in context: Context, completion: @escaping (DoubleRepoEntry) -> ()) {
        let entry = DoubleRepoEntry(date: Date(), topRepo: MockData.repoOne, bottomRepo: MockData.repoTwo)
        completion(entry)
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        Task {
            let nextUpdate = Date().addingTimeInterval(43200) // 12 hours in seconds
            
            do {
                // get top repo
                var repo = try await NetworkManager.shared.getRepo(atUrl: RepoURL.elixirRepoURL)
                let topAvatarImageData = await NetworkManager.shared.downloadImageData(from: repo.owner.avatarUrl)
                repo.avatarData = topAvatarImageData ?? Data()
                
                // get bottom repo
                var bottomRepo = try await NetworkManager.shared.getRepo(atUrl: RepoURL.livebookRepoURL)
                let bottomAvatarImageData = await NetworkManager.shared.downloadImageData(from: bottomRepo.owner.avatarUrl)
                bottomRepo.avatarData = bottomAvatarImageData ?? Data()
                
                // create entry and timeline
                let entry = DoubleRepoEntry(date: .now, topRepo: repo, bottomRepo: bottomRepo)
                let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
                completion(timeline)
            } catch {
                print("😵 Error - \(error.localizedDescription)")
            }
        }
    }
}

struct DoubleRepoEntry: TimelineEntry {
    let date: Date
    let topRepo: Repository
    let bottomRepo: Repository
}

struct DoubleRepoEntryView : View {
    var entry: DoubleRepoProvider.Entry
    
    var body: some View {
        ZStack {
            Color(uiColor: .tertiarySystemBackground)
            VStack(spacing: 36) {
                RepoMediumView(repo: entry.topRepo)
                RepoMediumView(repo: entry.bottomRepo)
            }
        }
    }
}

struct DoubleRepoWidget: Widget {
    
    let kind: String = "DoubleRepoWidget"
    
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: DoubleRepoProvider()) { entry in
            DoubleRepoEntryView(entry: entry)
        }
        .configurationDisplayName("Repo Watcher")
        .description("Keep an eye two GitHub repositories.")
        .supportedFamilies([.systemLarge])
    }
}

struct DoubleRepoWidget_Previews: PreviewProvider {
    static var previews: some View {
        DoubleRepoEntryView(entry: DoubleRepoEntry(date: Date(), topRepo: MockData.repoOne, bottomRepo: MockData.repoTwo))
            .previewContext(WidgetPreviewContext(family: .systemLarge))
    }
}

