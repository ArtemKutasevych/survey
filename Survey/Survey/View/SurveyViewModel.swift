//
//  SurveyViewModel.swift
//  Survey
//
//  Created by Artem Kutasevych on 18.10.2023.
//

import Foundation
import Combine

enum ViewState {
    case normal
    case success
    case error
}

class SurveyViewModel: ObservableObject {
    private var cancellables = Set<AnyCancellable>()
    let questionsService: QuestionsServiceProtocol
    var questions: [QuestionViewModel] = []
    @Published var currentQuestion: QuestionViewModel
    @Published var viewState: ViewState = .normal
    var isLoaded = false
    
    init(questionsService: QuestionsServiceProtocol) {
        self.questionsService = questionsService
        self.currentQuestion = QuestionViewModel(question: Question(id: -1, question: ""))
        self.fetchQuestions()
    }
    
    private func fetchQuestions() {
        questionsService.getQuestions()
            .receive(on: RunLoop.main)
            .sink(receiveCompletion: { data in
            
        }, receiveValue: { [weak self] questions in
            guard let self else { return }
            for question in questions {
                self.questions.append(QuestionViewModel(question: question))
                self.currentQuestion = self.questions.first!
                isLoaded = true
            }
        }).store(in: &cancellables)
    }
    
    func submitAnswer() {
        isLoaded = false
        questionsService.postAnswer(with: currentQuestion.question.id, answer: currentQuestion.answer)
            .receive(on: RunLoop.main)
            .sink(receiveCompletion: { [weak self] completion in
                                        switch completion {
                                        case .failure(let error):
                                            if let error = error as? APIError,
                                               error == .errorResponce {
                                                print(error)
                                                self?.viewState = .error
                                            }
                                        case .finished: 
                                            self?.currentQuestion.answered = true
                                            self?.viewState = .success
                                            print("success")
                                        }
                self?.isLoaded = true
                                }, receiveValue: { _ in})
            .store(in: &cancellables)
        
    }
    
    func increment() {
         let id = currentQuestion.question.id
             guard id < questions.count else { return }
        
        currentQuestion = self.questions[id]
        viewState = .normal
    }
    
    func decrement() {
         let id = currentQuestion.question.id
        guard id >= 2 else { return }
        
        currentQuestion = self.questions[id - 2]
        viewState = .normal
    }
}

class QuestionViewModel {
    let question: Question
    var answered: Bool
    var answer: String
    
    init(question: Question, answered: Bool = false, answer: String = "") {
        self.question = question
        self.answered = answered
        self.answer = answer
    }
}
