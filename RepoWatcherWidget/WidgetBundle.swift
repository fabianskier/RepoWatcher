//
//  WidgetBundle.swift
//  RepoWatcherWidgetExtension
//
//  Created by Oscar Cristaldo on 2022-08-21.
//

import SwiftUI
import WidgetKit

@main
struct RepoWatcherWidgets: WidgetBundle {
    
    var body: some Widget {
        CompactRepoWidget()
        ContributorWidget()
    }
}
