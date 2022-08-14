//
//  NetworkManager.swift
//  RepoWatcher
//
//  Created by Oscar Cristaldo on 2022-08-13.
//

import Foundation

class NetworkManager {
    
    static let shared = NetworkManager()
    let decoder = JSONDecoder()
    
    private init() {
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        decoder.dateDecodingStrategy = .iso8601
    }
    
    func getRepo(atUrl urlString: String) async throws -> Repository {
        
        guard let url = URL(string: urlString) else { throw NetworkError.invalidRepoURL }
        
        let (data, response) = try await URLSession.shared.data(from: url)
        
        guard let response = response as? HTTPURLResponse, response.statusCode == 200 else { throw NetworkError.invalidResponse }
        
        do {
            return try decoder.decode(Repository.self, from: data)
        } catch {
            throw NetworkError.invalidRepoData
        }
    }
    
    func downloadImageData(from urlString: String) async -> Data? {
        
        guard let url = URL(string: urlString) else { return nil }
        
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            return data
        } catch {
            return nil
        }
    }
}

enum NetworkError: Error {
    
    case invalidRepoURL
    case invalidResponse
    case invalidRepoData
}

enum RepoURL {
    
    static let metaprogrammingRepoURL = "https://api.github.com/repos/fabianskier/metaprogramming"
    static let livebookRepoURL = "https://api.github.com/repos/livebook-dev/livebook"
    static let elixirRepoURL = "https://api.github.com/repos/elixir-lang/elixir"
}
