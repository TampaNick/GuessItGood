//
//  MenuView.swift
//  GUESSITGOOD
//
//  Created by Nicholas Olivieri on 1/10/25.
//

import SwiftUI

struct MenuView: View {
    var body: some View {
        VStack(alignment: .leading) {
            NavigationLink(destination: UserGuideView()) {
                Text("User Guide")
                    .font(.headline)
                    .padding(.vertical, 10)
            }
            Spacer()
        }
        .frame(maxWidth: 250)
        .background(Color.gray.opacity(0.9))
        .foregroundColor(.white)
        .edgesIgnoringSafeArea(.all)
    }
}
