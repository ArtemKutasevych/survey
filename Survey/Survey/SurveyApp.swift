//
//  SurveyApp.swift
//  Survey
//
//  Created by Artem Kutasevych on 18.10.2023.
//

import SwiftUI
import ComposableArchitecture

@main
struct SurveyApp: App {
    var body: some Scene {
        WindowGroup {
            QuestionsView(
                store: Store(initialState: Questions.State()) {
                    Questions()._printChanges()
                }
            )
        }
    }
}

