//
//  HamburgerMenu.swift
//  GUESSITGOOD
//
//  Created by Nicholas Olivieri on 1/10/25.
//

import SwiftUI

struct HamburgerMenu: View {
    @Binding var isMenuOpen: Bool // Binding to toggle the menu state

    var body: some View {
        ZStack(alignment: .leading) {
            if isMenuOpen {
                // Dimmed background when the menu is open
                Color.black.opacity(0.5)
                    .ignoresSafeArea()
                    .onTapGesture {
                        withAnimation {
                            isMenuOpen = false
                        }
                    }

                // Menu content
                VStack(alignment: .leading, spacing: 20) {
                    Button(action: {
                        withAnimation {
                            isMenuOpen = false
                        }
                    }) {
                        HStack {
                            Image(systemName: "chevron.left")
                            Text("Back")
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }

                    NavigationLink(destination: HowToGuessItGoodView()) {
                        Text("How to Guess It Good")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }

                    NavigationLink(destination: GameWheelView()) {
                        Text("The Game Wheel")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }

                    NavigationLink(destination: GameboardView()) {
                        Text("The Gameboard")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }

                    NavigationLink(destination: QuickStartView()) {
                        Text("Quick Start")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }

                    NavigationLink(destination: GamePlayView()) {
                        Text("Game Play")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }

                    NavigationLink(destination: SolvingView()) {
                        Text("Solving")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }

                    Spacer()
                }
                .padding()
                .frame(width: UIScreen.main.bounds.width * 0.8, alignment: .leading)
                .background(Color.gray)
                .transition(.move(edge: .leading))
            }
        }
        .animation(.easeInOut, value: isMenuOpen)
    }
}

