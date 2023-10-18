//
//  QuestiionsServicMock.swift
//  SurveyTests
//
//  Created by Artem Kutasevych on 18.10.2023.
//

import Foundation
import Combine
@testable import Survey

class QuestionServiceMock: QuestionsServiceProtocol {
    
    var getQuestionsCallsCount = 0
    var getQuestionsCalled: Bool {
        return getQuestionsCallsCount > 0
    }
    var getQuestionsReturnValue = [Question(id: 1, question: "")]
    var error: APIError?
    
    func getQuestions() -> AnyPublisher<[Question], Error> {
        getQuestionsCallsCount += 1
        if let error {
            return Fail(error: error)
                .eraseToAnyPublisher()
        }
        return Just(getQuestionsReturnValue)
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }
    
    var postAnswerCallsCount = 0
    var postAnswerCalled: Bool {
        return postAnswerCallsCount > 0
    }
    var postAnswerReturnValue: NoReply!
    var errorPostAnswer: APIError?
    
    func postAnswer(with id: Int, answer: String) -> AnyPublisher<NoReply, Error> {
        postAnswerCallsCount += 1
        if let errorPostAnswer {
            return Fail(error: errorPostAnswer)
                .eraseToAnyPublisher()
        }
        return Just(postAnswerReturnValue)
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }
}

