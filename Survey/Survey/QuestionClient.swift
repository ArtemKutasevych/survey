//
//  QuestionService.swift
//  Survey
//
//  Created by Artem Kutasevych on 23.10.2023.
//

import Foundation
import ComposableArchitecture

struct QuestionClient {
    var getQuestions: @Sendable () async throws -> [Question]
    var postAnswer: @Sendable (Int, String) async throws -> NoReply
}

extension DependencyValues {
    var questionClient: QuestionClient {
        get { self[QuestionClient.self] }
        set { self[QuestionClient.self] = newValue }
    }
}

// MARK: - Live API implementation

extension QuestionClient: DependencyKey {
    static let baseURL = URL(string: "https://xm-assignment.web.app")
    static let liveValue = QuestionClient(
        getQuestions: {
            let path = "/questions"
            var url = baseURL?.appendingPathComponent(path)
            guard let url else { return [] }
            var request = URLRequest(url: url)
            request.httpMethod = "GET"
            let (data, _) = try await URLSession.shared.data(for: request)
            return try jsonDecoder.decode([Question].self, from: data)
        },
        postAnswer: { id, answer in
            let path = "/question/submit"
            var url = baseURL?.appendingPathComponent(path)
            url?.append(queryItems: [
                URLQueryItem(name: "id", value: "\(id)"),
                URLQueryItem(name: "answer", value: answer),
            ])
            guard let url else { return NoReply() }
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            let (data, responce) = try await URLSession.shared.data(for: request)
            
            guard let httpResponse = responce as? HTTPURLResponse,
                  (200...299).contains(httpResponse.statusCode) else {
                throw APIError.errorResponce
            }
            
            
            var newData = data
            if data.isEmpty {
                newData = "{}".data(using: .utf8)!
            }
            
            return try jsonDecoder.decode(NoReply.self, from: newData)
        }
    )
}

private let jsonDecoder: JSONDecoder = {
    let decoder = JSONDecoder()
    return decoder
}()
