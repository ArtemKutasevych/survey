//
//  NormalSuccessErrorView.swift
//  Survey
//
//  Created by Artem Kutasevych on 22.10.2023.
//

import SwiftUI

struct NormalView: View {
    var numberOfSubmittesQuestions: Int
    
    var body: some View {
        HStack {
            Spacer()
            Text("Question submitted: \(numberOfSubmittesQuestions)")
                .padding(EdgeInsets(top: 20, leading: 16, bottom: 20, trailing: 16))
            Spacer()
        }
        .background(.white)
    }
}

struct ErrorView: View {
    var submitAnswerAction: (() -> Void)
    
    var body: some View {
        HStack {
            Text("Failure!")
                .font(.largeTitle)
                .padding(EdgeInsets(top: 70, leading: 16, bottom: 70, trailing: 16))
            Spacer()
            Button("Retry") {
                submitAnswerAction()
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

struct SuccessView: View {
    var body: some View {
        HStack {
            Text("Success")
                .font(.largeTitle)
                .padding(EdgeInsets(top: 70, leading: 16, bottom: 70, trailing: 16))
            Spacer()
        }
        .background(.green)
    }
}

#Preview {
    Group {
        NormalView(numberOfSubmittesQuestions: 5)
        ErrorView(submitAnswerAction: {})
        SuccessView()
    }
}
