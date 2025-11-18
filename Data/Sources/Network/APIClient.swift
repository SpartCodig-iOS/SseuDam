//
//  APIClient.swift
//  Data
//
//  Created by 김민희 on 11/17/25.
//

import Foundation

final class APIClient {
    
    private let baseURL: URL
    private let session: URLSession
    
    init(
        baseURL: URL = URL(string: "https://sseudam.up.railway.app")!,
        session: URLSession = .shared
    ) {
        self.baseURL = baseURL
        self.session = session
    }
    
    func request<Response: Decodable>(
        method: HTTPMethod,
        path: String,
        query: [String: String]? = nil
    ) async throws -> Response {
        try await request(method: method, path: path, query: query, body: Optional<Data>.none as Data?)
    }
    
    func request<Body: Encodable, Response: Decodable>(
        method: HTTPMethod,
        path: String,
        query: [String: String]? = nil,
        body: Body?
    ) async throws -> Response {
        
        guard var components = URLComponents(
            url: baseURL.appendingPathComponent(path),
            resolvingAgainstBaseURL: false
        ) else {
            throw APIError.invalidURL
        }
        
        if let query = query, !query.isEmpty {
            components.queryItems = query.map { URLQueryItem(name: $0.key, value: $0.value) }
        }
        
        guard let url = components.url else {
            throw APIError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        
        if let body = body {
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpBody = try JSONEncoder().encode(body)
        }
        
        // request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        let (data, response) = try await session.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }
        
        guard (200..<300).contains(httpResponse.statusCode) else {
            throw APIError.httpError(httpResponse.statusCode)
        }
        
        do {
            return try JSONDecoder().decode(Response.self, from: data)
        } catch {
            throw APIError.decodingError
        }
    }
}
