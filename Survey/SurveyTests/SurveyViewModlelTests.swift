//
//  SurveyViewModelTests.swift
//  SurveyTests
//
//  Created by Artem Kutasevych on 18.10.2023.
//

import XCTest
@testable import Survey

final class SurveyViewModelTests: XCTestCase {
 
    private var sut: SurveyViewModel?
    private var questionService = QuestionServiceMock()
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        sut = SurveyViewModel(questionsService: questionService)
    }
    
    func testSubmitAnswerSuccess() {
        // given
        let expectedValue = NoReply()
        questionService.postAnswerReturnValue = expectedValue
        
        // when
        sut?.submitAnswer()
        
        // then
        XCTAssertTrue(questionService.getQuestionsCalled)
        XCTAssertTrue(questionService.postAnswerCalled)
    }
    
    func testSubmitAnswerFailure() {
        // given
        let error: APIError = .errorResponce
        questionService.errorPostAnswer = error
        // when
        sut?.submitAnswer()
        
        // then
        XCTAssertTrue(questionService.getQuestionsCalled)
        XCTAssertTrue(questionService.postAnswerCalled)
    }
    
    func testIncrement() {
        // given
        let expectedQuestion = Question(id: 2, question: "2 Question")
        let questions = [Question(id: 1, question: "1 Question"), expectedQuestion]
        sut?.questions = questions.map { QuestionViewModel(question: $0) }
        sut?.currentQuestion = QuestionViewModel(question: questions.first ?? expectedQuestion)
        
        // when
        sut?.increment()
        
        // then
        XCTAssertEqual(sut?.currentQuestion.question, expectedQuestion)
    }
    
    func testDecrement() {
        // given
        let expectedQuestion = Question(id: 1, question: "1 Question")
        let questions = [expectedQuestion, Question(id: 2, question: "2 Question")]
        sut?.questions = questions.map { QuestionViewModel(question: $0) }
        sut?.currentQuestion = QuestionViewModel(question: questions.last ?? expectedQuestion)
        
        // when
        sut?.decrement()
        
        // then
        XCTAssertEqual(sut?.currentQuestion.question, expectedQuestion)
    }
}
