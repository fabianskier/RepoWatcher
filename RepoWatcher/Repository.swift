//
//  Repository.swift
//  RepoWatcher
//
//  Created by Oscar Cristaldo on 2022-08-13.
//

import Foundation

struct Repository: Decodable {
    
    let name: String
    let owner: Owner
    let hasIssues: Bool
    let forks: Int
    let watchers: Int
    let openIssues: Int
    let pushedAt: String
    
    static let placeholder = Repository(name: "metaprogramming",
                                        owner: Owner(avatarUrl: "https://avatars.githubusercontent.com/u/15128101?v=4"),
                                        hasIssues: true,
                                        forks: 25,
                                        watchers: 125,
                                        openIssues: 2,
                                        pushedAt: "2022-08-09T06:37:33Z")
}

struct Owner: Decodable {
    
    let avatarUrl: String
}
