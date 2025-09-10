///
//  ContentView.swift
//  GUESSITGOOD
//
//  Created by Nicholas Olivieri on 12/13/24.
//

import SwiftUI
import AVFoundation

struct ContentView: View {
    @EnvironmentObject var viewModel: GameViewModel
    @StateObject private var speechManager = SpeechManager()
    @State private var isAlertPresented = false
    @State private var solutionText = ""
    @State private var isAdDisplayed = false
    @State private var isMenuOpen = false // For hamburger menu toggle
    
    var body: some View {
        ZStack {
            //Main Game View
            VStack {
                if viewModel.isPlayAgainButtonEnabled {
                    VStack {
                        Text("Series Over!")
                            .font(.largeTitle)
                            .padding()
                        Button("Play Again") {
                            viewModel.handleRestart() // Reset the game
                        }
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color.gray.opacity(0.2))
                } else if isAdDisplayed {
                    VStack {
                        Text("Thank you for playing!")
                            .font(.largeTitle)
                            .padding()
                        Button("Close Ad") {
                            isAdDisplayed = false
                            viewModel.handleRestart()
                        }
                        .padding()
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color.black.opacity(0.8))
                } else { //Main Game View
                    GeometryReader { geometry in
                        VStack(spacing: 0) { // Keep it tight to allow for better spacing adjustments
                            ZStack {
                                Color(UIColor.white).edgesIgnoringSafeArea(.top)
                                VStack(spacing: geometry.size.height * 0.02) { // Increase spacing slightly
                                    // 🔹 Scoreboard
                                    HStack(spacing: geometry.size.width * 0.01) {
                                        ForEach(viewModel.players, id: \ .id) { player in
                                            ZStack {
                                                RoundedRectangle(cornerRadius: 8)
                                                    .fill(Color.blue)
                                                    .frame(
                                                        width: geometry.size.width * 0.25,
                                                        height: geometry.size.height * 0.07
                                                    )
                                                VStack {
                                                    Text(player.name.isEmpty ? "Player \(player.id)" : player.name)
                                                        .font(.system(size: geometry.size.width * 0.035))
                                                        .fontWeight(.bold)
                                                        .foregroundColor(.white)
                                                    
                                                    Text("\(player.totalScore + player.roundScore)")
                                                        .font(.system(size: geometry.size.width * 0.035))
                                                        .foregroundColor(.white)
                                                    Text("Round: \(player.roundScore)")
                                                        .font(.system(size: geometry.size.width * 0.03))
                                                        .foregroundColor(.white)
                                                }
                                            }
                                        }
                                    }
                                    
                                    // 🔹 Player Turn Indicator (Raised Higher)
                                    
                                    if let currentPlayer = viewModel.currentPlayer {
                                        Text("\(currentPlayer.name)'s Turn")
                                            .font(.system(size: geometry.size.width * 0.05))
                                            .fontWeight(.bold)
                                            .foregroundColor(.red)
                                            .padding(.bottom, geometry.size.height * 0.06)
                                    }
                                    
                                    // Clue Button & Category Display
                                    if !viewModel.category.isEmpty {
                                        VStack {
                                            if viewModel.categoryRevealed {
                                                Text(viewModel.category)
                                                    .font(.system(size: geometry.size.width * 0.05, weight: .bold))
                                                    .foregroundColor(.black)
                                            } else if viewModel.clueButtonVisible {
                                                Button(action: {
                                                    viewModel.revealCategory()
                                                }) {
                                                    Text("CLUE")
                                                        .font(.system(size: 12))
                                                        .fontWeight(.bold)
                                                        .foregroundColor(.white)
                                                        .padding(.horizontal, 8)
                                                        .padding(.vertical, 4)
                                                        .background(Color.blue)
                                                        .cornerRadius(5)
                                                }
                                            }
                                        }
                                        .offset(y: geometry.size.height * (UIDevice.current.userInterfaceIdiom == .pad ? -0.04 : -0.05))
                                    }
                                    
                                    // 🔹 Gameboard (Position Adjusted)
                                    ResponsiveGameBoardView()
                                        .padding(.horizontal, geometry.size.width * 0.03) // ✅ Keep horizontal padding
                                        .frame(maxHeight: geometry.size.height * 0.45) // ✅ Increase height
                                        .offset(y: geometry.size.height * (UIDevice.current.userInterfaceIdiom == .pad ? -0.07 : -0.12)) // ✅ Move game board higher
                                    Spacer(minLength: geometry.size.height * 0.02)
                                }
                            }
                        }
                        // 🔹 Keyboard (Adjusted Height & Padding)
                        
                        CustomKeyboardView(
                            onLetterSelect: { letter in
                                viewModel.selectPendingLetter(letter)
                            },
                            onEnterPress: { viewModel.confirmPendingLetter() },
                            guessedLetters: viewModel.guessedLetters
                        )
                        .frame(height: geometry.size.height * 0.23)
                        .padding(.top, geometry.size.height * (UIDevice.current.userInterfaceIdiom == .pad ? -0.10 : 0.53 )) // iPad gets raised much higher - was at .10
                        .padding(.bottom, geometry.size.height * 0.07) // Increased padding below
                        
                        // 🔹 Solve and Play Again Buttons
                        
                        VStack(alignment: .leading, spacing: geometry.size.height * 0.01) {
                            Spacer()
                            Button(action: {
                                viewModel.handleRestart()
                            }) {
                                Label("Back", systemImage: "chevron.left")
                                    .font(.system(size: 20, weight: .semibold))
                                    .padding(6)
                                    .background(Color.white.opacity(0.6))
                                    .foregroundColor(.black)
                                    .cornerRadius(5)
                            }
                            .padding(.leading, geometry.size.width * 0.03)
                            
                            HStack(spacing: geometry.size.width * 0.03) {
                                Button("Solve") {
                                    viewModel.initiateSolvePuzzle()
                                }
                                .font(.system(size: geometry.size.width * 0.04, weight: .bold))
                                .foregroundColor(.white)
                                .frame(width: geometry.size.width * 0.31, height: geometry.size.height * 0.04)
                                .background(Color.green)
                                .cornerRadius(10)
                                .shadow(radius: 3)
                                
                                Button("Play Again") {
                                    viewModel.handleRestart()
                                }
                                .disabled(!viewModel.checkIfSeriesOver())
                                .font(.system(size: geometry.size.width * 0.04, weight: .bold))
                                .foregroundColor(.white)
                                .frame(width: geometry.size.width * 0.31, height: geometry.size.height * 0.04)
                                .background(Color.red.opacity(!viewModel.checkIfSeriesOver() ? 0.5 : 1.0))
                                .cornerRadius(10)
                                .shadow(radius: 3)
                            }
                            .frame(maxWidth: .infinity, alignment: .center)
                            
                            // 🔹 Toggles for Sounds & Voice
                            VStack(spacing: geometry.size.height * 0.005) {
                                Toggle("Game Sounds", isOn: $viewModel.isMusicEnabled)
                                    .toggleStyle(SwitchToggleStyle(tint: .blue))
                                    .scaleEffect(geometry.size.width * 0.0017)
                                
                                Toggle("Voice", isOn: $viewModel.isSpeechEnabled)
                                    .toggleStyle(SwitchToggleStyle(tint: .green))
                                    .scaleEffect(geometry.size.width * 0.0017)
                            }
                            .frame(maxWidth: .infinity, alignment: .center)
                        }
                    }
                }
            }
        }
        .sheet(isPresented: $viewModel.showWheel) {
                        WheelView(viewModel: viewModel)
                    }
            }
    
            
    
    
    
    
    
    
    
    
    
  
    struct CustomKeyboardView: View {
        @State private var pressedKey: Character? = nil
        @State private var guessedKeys: Set<Character> = []
        
        let onLetterSelect: (Character) -> Void
        let onEnterPress: () -> Void
        let guessedLetters: Set<Character>
        let letters = Array("ABCDEFGHIJKLMNOPQRSTUVWXYZ")
        let columns = 7
        
        var body: some View {
            GeometryReader { geometry in
                VStack(spacing: geometry.size.height * 0.01) { // Adjust spacing dynamically
                    HStack { // Center the keyboard horizontally
                        VStack(spacing: geometry.size.height * 0.01) { // Adjust spacing dynamically
                            ForEach(0..<3, id: \.self) { row in
                                HStack(spacing: geometry.size.width * 0.01) { // Adjust spacing dynamically
                                    ForEach(0..<columns, id: \.self) { column in
                                        let index = row * columns + column
                                        if index < letters.count {
                                            let letter = letters[index]
                                            Button(action: {
                                                pressedKey = letter
                                                onLetterSelect(letter)
                                            }) {
                                                Text(String(letter))
                                                    .font(.system(size: geometry.size.width * 0.06, weight: .bold))
                                                    .foregroundColor(.white)
                                                    .frame(width: geometry.size.width * 0.123, height: geometry.size.width * 0.123)
                                                    .background(
                                                        ZStack {
                                                            keyBackgroundColor(for: letter) // Keeps dynamic color changes
                                                            LinearGradient(gradient: Gradient(colors: [Color.white.opacity(0.2), Color.clear]),
                                                                           startPoint: .topLeading,
                                                                           endPoint: .bottomTrailing) // Adds subtle lighting
                                                        }
                                                    )
                                                    .cornerRadius(8) // Rounded keys
                                                    .shadow(color: Color.black.opacity(0.4), radius: 4, x: 2, y: 2) // Raised effect
                                                    .overlay(
                                                        RoundedRectangle(cornerRadius: 8)
                                                            .stroke(Color.white.opacity(0.5), lineWidth: 1) // Soft highlight
                                                    )
                                            }
                                            
                                        }
                                    }
                                }
                            }
                            
                            HStack(spacing: geometry.size.width * 0.01) { // Adjust spacing dynamically
                                ForEach(21..<26, id: \.self) { index in
                                    let letter = letters[index]
                                    Button(action: {
                                        pressedKey = letter
                                        onLetterSelect(letter)
                                    }) {
                                        Text(String(letter))
                                            .font(.system(size: geometry.size.width * 0.06, weight: .bold))
                                            .foregroundColor(.white)
                                            .frame(width: geometry.size.width * 0.123, height: geometry.size.width * 0.123)
                                            .background(
                                                ZStack {
                                                    keyBackgroundColor(for: letter) // Keeps dynamic color changes
                                                    LinearGradient(gradient: Gradient(colors: [Color.white.opacity(0.2), Color.clear]),
                                                                   startPoint: .topLeading,
                                                                   endPoint: .bottomTrailing) // Adds subtle lighting
                                                }
                                            )
                                            .cornerRadius(8) // Rounded keys
                                            .shadow(color: Color.black.opacity(0.4), radius: 4, x: 2, y: 2) // Raised effect
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 8)
                                                    .stroke(Color.white.opacity(0.5), lineWidth: 1) // Soft highlight
                                            )
                                    }
                                    
                                    
                                    
                                }
                                
                                Button(action: {
                                    if let key = pressedKey {
                                        guessedKeys.insert(key)
                                    }
                                    pressedKey = nil
                                    onEnterPress()
                                }) {
                                    Text("Enter")
                                        .font(.system(size: geometry.size.width * 0.06, weight: .bold))
                                        .foregroundColor(.white)
                                        .frame(width: geometry.size.width * 0.254, height: geometry.size.width * 0.123)
                                    //   .background(Color.green)
                                    //   .cornerRadius(5)
                                        .background(
                                            LinearGradient(gradient: Gradient(colors: [Color.green.opacity(0.9), Color.green]),
                                                           startPoint: .topLeading,
                                                           endPoint: .bottomTrailing)
                                        )
                                        .cornerRadius(10)
                                        .shadow(color: Color.black.opacity(0.5), radius: 5, x: 2, y: 2) // Stronger shadow for more depth
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 10)
                                                .stroke(Color.white.opacity(0.5), lineWidth: 1)
                                        )
                                    
                                    
                                    
                                }
                            }
                        }
                        .padding(.horizontal, geometry.size.width * 0.05) // Dynamic horizontal padding
                    }
                    .frame(maxWidth: .infinity) // Ensure the HStack takes full width and centers the keyboard
                }
            }
        }
        
        
        private func keyBackgroundColor(for letter: Character) -> Color {
            if guessedLetters.contains(letter) {
                return Color.gray
            } else if pressedKey == letter {
                return Color.orange
            } else {
                return Color.blue
            }
        }
        
    }
        
        struct ContentView_Previews: PreviewProvider {
            static var previews: some View {
                ContentView()
                    .environmentObject(GameViewModel()) // Add this line
                
            }
        }
        
    }

