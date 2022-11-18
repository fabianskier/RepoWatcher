//
//  UserDefaults+Ext.swift
//  RepoWatcher
//
//  Created by Oscar Cristaldo on 2022-11-18.
//

import Foundation

extension UserDefaults {
    static var shared: UserDefaults {
        UserDefaults(suiteName: "group.py.com.fabianskier.RepoWatcher")!
    }
    
    static let repoKey = "repos"
}
