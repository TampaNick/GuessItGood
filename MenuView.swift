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
            NavigationLink(destination: HowToGuessItGoodView()) {
                Text("How to Guess It Good")
                    .font(.headline)
                    .padding(.vertical, 10)
            }
            NavigationLink(destination: GameWheelView()) {
                Text("The Game Wheel")
                    .font(.headline)
                    .padding(.vertical, 10)
            }
            NavigationLink(destination: GameboardView()) {
                Text("The Gameboard")
                    .font(.headline)
                    .padding(.vertical, 10)
            }
            NavigationLink(destination: QuickStartView()) {
                Text("Quick Start")
                    .font(.headline)
                    .padding(.vertical, 10)
            }
            NavigationLink(destination: GamePlayView()) {
                Text("Game Play")
                    .font(.headline)
                    .padding(.vertical, 10)
            }
            NavigationLink(destination: SolvingView()) {
                Text("Solving")
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
