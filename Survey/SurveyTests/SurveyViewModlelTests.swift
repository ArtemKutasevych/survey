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
}
