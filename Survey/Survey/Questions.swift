//
//  Questions.swift
//  Survey
//
//  Created by Artem Kutasevych on 20.10.2023.
//

import ComposableArchitecture
@_spi (Internals) import ComposableArchitecture
import SwiftUI

enum AnswerState {
    case normal
    case success
    case error
}

struct Questions: Reducer {
    struct State: Equatable {
        @BindingState var currentQuestionNumber: Int = 0
        @BindingState var answerState: AnswerState = .normal
        @BindingState var isLoading = false
        var questions: IdentifiedArrayOf<QuestionReducer.State> = []
    }
    
    @Dependency(\.questionClient) var questionClient
    @Dependency(\.continuousClock) var clock
    
    enum Action: BindableAction, Equatable, Sendable {
        case incrementButtonTapped
        case decrementButtonTapped
        case fetchQuestions
        case fetchQuestionsResponce(TaskResult<[Question]>)
        
        case submitAnswerButtonTapped(Int, String)
        case submitAnswerResponse(TaskResult<NoReply>)
        
        case normalAnswerState
    
        case binding(BindingAction<State>)
        case question(id: QuestionReducer.State.ID, action: QuestionReducer.Action)
    }
    
    
    var body: some Reducer<State, Action> {
        BindingReducer()
        Reduce { state, action in
            switch action {
            case .incrementButtonTapped:
                let id = state.currentQuestionNumber + 1
                guard id < state.questions.count else { return .none }
                state.currentQuestionNumber += 1
                state.answerState = .normal
                return .none
                
            case .decrementButtonTapped:
                let id = state.currentQuestionNumber  + 1
                guard id >= 1 else { return .none }
                state.currentQuestionNumber -= 1
                state.answerState = .normal
                return .none
                
            case .binding(_):
                return .none
                
            case .fetchQuestions:
                state.isLoading = true
                return .run { send in
                    await send(.fetchQuestionsResponce(TaskResult { try await self.questionClient.getQuestions() }))
                }
                
            case .fetchQuestionsResponce(.failure):
                state.questions = []
                state.isLoading = false
                return .none
                
            case let .fetchQuestionsResponce(.success(response)):
                let questions = response.map { QuestionReducer.State(id: $0.id, question: $0.question) }
                for (index, question) in questions.enumerated() {
                    state.questions.insert(question, at: index)
                }
                state.isLoading = false
                return .none
                
                
            case .submitAnswerButtonTapped(let id, let answer):
                state.isLoading = true
                return .run { send in
                    await send(.submitAnswerResponse(TaskResult { try await self.questionClient.postAnswer(id, answer) }))
                }
                
            case .submitAnswerResponse(.failure):
                state.isLoading = false
                state.answerState = .error
                state.questions[state.currentQuestionNumber].answered = false
                return .run { send in
                    try await self.clock.sleep(for: .seconds(5))
                    await send(.normalAnswerState)
                }
                
            case .submitAnswerResponse(.success(_)):
                state.isLoading = false
                state.answerState = .success
                return .run { send in
                    try await self.clock.sleep(for: .seconds(2))
                    await send(.normalAnswerState)
                }
                
            case .normalAnswerState:
                state.answerState = .normal
                return .none
                
            case .question(id: _, action: .binding(\.$answered)):
                let id = state.currentQuestionNumber
                let answer = state.questions[state.currentQuestionNumber].answer
                return .run { send in
                    await send(.submitAnswerButtonTapped(id, answer))
                }
                
            case .question:
                return .none
            }
        }
        .forEach(\.questions, action: /Action.question(id:action:)) {
            QuestionReducer()
        }
    }
}


struct QuestionsView: View {
    let store: StoreOf<Questions>
    struct ViewState: Equatable {
        
        @BindingViewState var currentQuestionNumber: Int
        @BindingViewState var answerState: AnswerState
        @BindingViewState var isLoading: Bool
        var questions: IdentifiedArrayOf<QuestionReducer.State>
        let numberOfSubmittedQuestions: Int
        let numberOfQuestions: Int
        
        init(store: BindingViewStore<Questions.State>) {
            self._currentQuestionNumber = store.$currentQuestionNumber
            self._answerState = store.$answerState
            self._isLoading = store.$isLoading
            self.numberOfSubmittedQuestions = store.questions.filter { $0.answered }.count
            self.numberOfQuestions = store.questions.count
            self.questions = store.questions
        }
    }
    
    
    var body: some View {
        WithViewStore(self.store, observe: ViewState.init) { viewStore in
            if viewStore.isLoading {
                ProgressView()
                    .scaleEffect(5.0, anchor: .center)
                    .progressViewStyle(CircularProgressViewStyle(tint: .red))
            } else {
                NavigationStack {
                    VStack {
                        Spacer()
                            .frame(height: 1)
                        VStack {
                            switch viewStore.answerState {
                            case .normal:
                                NormalView(numberOfSubmittesQuestions: viewStore.numberOfSubmittedQuestions)
                            case .success:
                                SuccessView()
                            case .error:
                                ErrorView {
                                    viewStore.send(.submitAnswerButtonTapped(viewStore.currentQuestionNumber, viewStore.questions[viewStore.currentQuestionNumber].answer))
                                }
                            }
                            
                            if !viewStore.questions.isEmpty {
                                ForEachStore(
                                    self.store.scope(state: \.questions, action: { Questions.Action.question(id: $0, action: $1) })
                                ) { store in
                                    if  store.state.value.id == viewStore.currentQuestionNumber + 1 {
                                        QuestionView(store: store)
                                    }
                                }
                            }
            
                            Spacer()
                        }
                        .background(Color(UIColor.lightGray))
                        .toolbarBackground(Color(UIColor.lightGray))
                        .toolbar {
                            ToolbarItem(placement: .principal) {
                                Text("Question \(viewStore.currentQuestionNumber + 1)/\(viewStore.numberOfQuestions)")
                            }
                            ToolbarItemGroup(placement:.primaryAction) {
                                Button("Previous") {
                                    viewStore.send(.decrementButtonTapped)
                                }
                                .disabled(viewStore.currentQuestionNumber <= 0)
                                
                                Button("Next") {
                                    viewStore.send(.incrementButtonTapped)
                                }
                                .disabled(viewStore.currentQuestionNumber > viewStore.numberOfQuestions-2)
                            }
                        }
                    }
                }
            }
        }
        .onAppear {
            store.send(.fetchQuestions)
        }
    }
}

extension IdentifiedArray where ID == QuestionReducer.State.ID, Element == QuestionReducer.State {
  static var mock: Self = [
    QuestionReducer.State(id: 1, question: "FirstQuestion", answer: "answer", answered: true),
    QuestionReducer.State(id: 2, question: "SecondQuestion"),
    QuestionReducer.State(id: 3, question: "ThirdQuestion"),
  ]
}

struct QuestionsView_Previews: PreviewProvider {
    static var previews: some View {
        QuestionsView(
            store: Store(initialState: Questions.State(currentQuestionNumber: 0, questions: .mock)) {
                Questions()
            }
        )
    }
}
