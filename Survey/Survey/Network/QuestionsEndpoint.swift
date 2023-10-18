//
//  QuestionsEndpoint.swift
//  Survey
//
//  Created by Artem Kutasevych on 18.10.2023.
//

import Foundation
enum QuestionsEndpoint: APIEndpoint {
    case getQuestions
    case postAnswer(id: Int, answer: String)
    
    var baseURL: URL {
        return URL(string: "https://xm-assignment.web.app")!
    }
    
    var path: String {
        switch self {
        case .getQuestions:
            return "/questions"
        case .postAnswer:
            return "/question/submit"
        }
    }
    
    var method: HTTPMethod {
        switch self {
        case .getQuestions:
            return .get
        case .postAnswer:
            return .post
        }
    }
    
    var headers: [String: String]? {
        return nil
    }
    
    var parameters: [String: Any]? {
        switch self {
        case .getQuestions:
            return nil
        case .postAnswer(let id, let answer):
           return  ["id": String(id), "answer": answer]
        }
    }
}
