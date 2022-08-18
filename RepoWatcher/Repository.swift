//
//  Repository.swift
//  RepoWatcher
//
//  Created by Oscar Cristaldo on 2022-08-13.
//

import Foundation

struct Repository {
    
    let name: String
    let owner: Owner
    let hasIssues: Bool
    let forks: Int
    let watchers: Int
    let openIssues: Int
    let pushedAt: String
    var avatarData: Data
    
    static let placeholder = Repository(name: "metaprogramming",
                                        owner: Owner(avatarUrl: "https://avatars.githubusercontent.com/u/15128101?v=4"),
                                        hasIssues: true,
                                        forks: 25,
                                        watchers: 125,
                                        openIssues: 2,
                                        pushedAt: "2022-08-09T06:37:33Z",
                                        avatarData: Data())
}

extension Repository {
    struct CodingData: Decodable {
        let name: String
        let owner: Owner
        let hasIssues: Bool
        let forks: Int
        let watchers: Int
        let openIssues: Int
        let pushedAt: String
        
        var repo: Repository {
            Repository(name: name,
                       owner: owner,
                       hasIssues: hasIssues,
                       forks: forks,
                       watchers: watchers,
                       openIssues: openIssues,
                       pushedAt: pushedAt,
                       avatarData: Data())
        }
    }
}

struct Owner: Decodable {
    
    let avatarUrl: String
}
