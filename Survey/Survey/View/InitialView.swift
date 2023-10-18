//
//  InitialView.swift
//  Survey
//
//  Created by Artem Kutasevych on 18.10.2023.
//

import SwiftUI

struct InitialView: View {
    static let spacing: CGFloat = 150.0
    
    var body: some View {
        NavigationView {
            VStack {
                VStack(spacing: InitialView.spacing) {
                    Text("Welcome")
                    NavigationLink(destination: SurveyView()) {
                        Text("Start survey")
                            .background(.white)
                    }
                }
                .padding()
                Spacer()
            }
        }
    }
}

#Preview {
    InitialView()
}
