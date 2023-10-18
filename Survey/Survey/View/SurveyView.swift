//
//  SurveyView.swift
//  Survey
//
//  Created by Artem Kutasevych on 18.10.2023.
//

import SwiftUI

struct SurveyView: View {
    @StateObject private var viewModel = SurveyViewModel(questionsService: QuestionsService())
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    var btnBack : some View { Button(action: {
        self.presentationMode.wrappedValue.dismiss()
    }) {
        HStack {
            Image(systemName: "arrow.left")
                .aspectRatio(contentMode: .fit)
                .foregroundColor(.black)
        }
    }
    }
    
    var body: some View {
        if !viewModel.isLoaded {
            ProgressView()
                .scaleEffect(5.0, anchor: .center)
                .progressViewStyle(CircularProgressViewStyle(tint: .red))
        } else {
            NavigationStack {
                VStack {
                    Spacer()
                        .frame(height: 1)
                    VStack {
                        switch viewModel.viewState {
                        case .normal:
                            HStack {
                                Spacer()
                                Text("Question submitted: \(viewModel.questions.filter { $0.answered }.count)")
                                    .padding(EdgeInsets(top: 20, leading: 16, bottom: 20, trailing: 16))
                                Spacer()
                            }
                            .background(.white)
                        case .success:
                            HStack {
                                Text("Success")
                                    .font(.largeTitle)
                                    .padding(EdgeInsets(top: 70, leading: 16, bottom: 70, trailing: 16))
                                Spacer()
                            }
                            .background(.green)
                        case .error:
                            HStack {
                                Text("Failure!")
                                    .font(.largeTitle)
                                    .padding(EdgeInsets(top: 70, leading: 16, bottom: 70, trailing: 16))
                                Spacer()
                                Button("Retry") {
                                    viewModel.submitAnswer()
                                }
                                .padding(EdgeInsets(top: 10, leading: 40, bottom: 10, trailing: 40))
                                .padding()
                                .background(Color(red: 0, green: 0, blue: 0.5))
                                .clipShape(Capsule())
                                .cornerRadius(15)
                            }
                            .background(.red)
                        }
                    }
                    
                    Text(viewModel.currentQuestion.question.question)
                        .font(.title)
                        .padding(EdgeInsets(top: 20, leading: 16, bottom: 20, trailing: 16))
                    
                    TextField("Type here for an answer", text: $viewModel.currentQuestion.answer)
                        .padding(EdgeInsets(top: 20, leading: 16, bottom: 20, trailing: 16))
                    
                    Button(!viewModel.currentQuestion.answered ? "Submit" : "Already submitted") {
                        viewModel.submitAnswer()
                    }
                    .disabled(viewModel.currentQuestion.answered || viewModel.currentQuestion.answer.isEmpty)
                    
                    Spacer()
                }
                .background(Color(UIColor.lightGray))
                .toolbarBackground(Color(UIColor.lightGray))
                .toolbar {
                    ToolbarItem(placement: .principal) {
                        Text("Question \(viewModel.currentQuestion.question.id)/ \(viewModel.questions.count)")
                    }
                    ToolbarItemGroup(placement:.primaryAction) {
                        Button("Previous") {
                            viewModel.decrement()
                        }
                        .disabled(viewModel.currentQuestion.question.id <= 1)
                        
                        Button("Next") {
                            viewModel.increment()
                        }
                        .disabled(viewModel.currentQuestion.question.id > viewModel.questions.count - 1)
                    }
                    ToolbarItem(placement: .navigationBarLeading) {
                       btnBack
                    }
                }
            }
            .navigationBarBackButtonHidden(true)
        }
    }
}

#Preview {
    SurveyView()
}
