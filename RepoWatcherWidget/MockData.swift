//
//  MockData.swift
//  RepoWatcherWidgetExtension
//
//  Created by Oscar Cristaldo on 2022-08-18.
//

import Foundation

struct MockData {
    
    static let repoOne = Repository(name: "metaprogramming",
                                        owner: Owner(avatarUrl: "https://avatars.githubusercontent.com/u/15128101?v=4"),
                                        hasIssues: true,
                                        forks: 25,
                                        watchers: 125,
                                        openIssues: 2,
                                        pushedAt: "2022-08-09T06:37:33Z",
                                        avatarData: Data())
    
    static let repoTwo = Repository(name: "metaprogramming",
                                        owner: Owner(avatarUrl: "https://avatars.githubusercontent.com/u/15128101?v=4"),
                                        hasIssues: false,
                                        forks: 25,
                                        watchers: 12,
                                        openIssues: 2,
                                        pushedAt: "2022-01-09T06:37:33Z",
                                        avatarData: Data())
}
