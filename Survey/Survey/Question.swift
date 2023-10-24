//
//  Question.swift
//  Survey
//
//  Created by Artem Kutasevych on 20.10.2023.
//

import SwiftUI
import ComposableArchitecture

struct QuestionReducer: Reducer {
    struct State: Equatable, Identifiable, Hashable {
        let id: Int
        let question: String
        @BindingState var answer = ""
        @BindingState  var answered = false
    }
    
    enum Action: BindableAction, Equatable, Sendable {
        case binding(BindingAction<State>)
    }
    
    
    var body: some Reducer<State, Action> {
        BindingReducer()
        Reduce { state, action in
            switch action {
            default: return .none
            }
        }
    }
}

struct QuestionView: View {
    let store: StoreOf<QuestionReducer>
    
    var body: some View {
        WithViewStore(self.store, observe: { $0 }) { viewStore in
            VStack {
                Text(viewStore.question)
                    .font(.title)
                    .padding(EdgeInsets(top: 20, leading: 16, bottom: 20, trailing: 16))
                
                TextField("Type here for an answer", text: viewStore.$answer)
                    .font(.title3)
                    .padding(EdgeInsets(top: 20, leading: 16, bottom: 20, trailing: 16))
                    .disabled(viewStore.answered)
                
                Button(!viewStore.answered ? "Submit" : "Already submitted") {
                    viewStore.$answered.wrappedValue.toggle()
                }
                .disabled(viewStore.answered || viewStore.answer.isEmpty)
            }
        }
    }
}


#Preview {
    QuestionView(store: Store(initialState: QuestionReducer.State(id: 1, question: "1 Question")) {
        QuestionReducer()
    })
}
