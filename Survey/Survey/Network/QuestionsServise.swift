//
//  GetQuestions.swift
//  Survey
//
//  Created by Artem Kutasevych on 18.10.2023.
//

import Foundation
import Combine

protocol QuestionsServiceProtocol {
  func getQuestions() -> AnyPublisher<[Question], Error>
  func postAnswer(with id: Int, answer: String) -> AnyPublisher<NoReply, Error>
}

class QuestionsService: QuestionsServiceProtocol {
    let apiClient = URLSessionAPIClient<QuestionsEndpoint>()
    
    func getQuestions() -> AnyPublisher<[Question], Error> {
        return apiClient.request(.getQuestions)
    }
    
    func postAnswer(with id: Int, answer: String) -> AnyPublisher<NoReply, Error> {
        return apiClient.request(.postAnswer(id: id, answer: answer))
    }
}

struct Question: Codable, Equatable {
    let id: Int
    let question: String
    
    static func ==(lhs: Question, rhs: Question) -> Bool {
        return lhs.id == rhs.id && lhs.question == rhs.question
    }
}

struct NoReply: Decodable {}
