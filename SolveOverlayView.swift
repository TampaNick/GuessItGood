//
//  SolveOverlayView.swift
//  GUESSITGOOD
//
//  Created by Nicholas Olivieri on 12/24/24.
//

import SwiftUI

struct SolveOverlayView: View {
    @ObservedObject var viewModel: GameViewModel
    @State private var solveAttemptIndices: [Int: String] = [:]
    @State private var showFlapAnimation = false
    @State private var showShrinkAnimation = false
    @State private var dismissOverlay = false
    var onDismiss: () -> Void
    var onSolutionSubmit: () -> Void

    var body: some View {
        ZStack {
            Color.black.opacity(0.5)
                .ignoresSafeArea()
                .onTapGesture {
                    dismissSolveView()
                }

            VStack {
                //removed Title and background view here
           
             // Gameboard (FIXED)
               ZStack {
                   ResponsiveSolveBoardView(
                        gridSize: 12,
                        gridRows: 8,
                        activeIndices: viewModel.activeIndices,
                        guessedLetters: viewModel.guessedLetters,
                        solveAttemptIndices: $solveAttemptIndices
                    )
                    .padding(.horizontal, 10)
                    .offset(y:-85)
                    
                     VStack(spacing: 130) {
                        CustomOverlayKeyboardView(
                         onLetterSelect: { letter in selectSolvePendingLetter(letter) },
                           
                           guessedLetters: viewModel.guessedLetters
                            )
                           .padding(.bottom, 1)  //this was bottom padding 12-24-24
                           .offset(y: 36) // This pushes the keyboard down to almost touching the solve and restart buttons
                    }
                }
               
                    HStack {
                      Button("Submit Solution") {
                        submitPuzzle()
                     }
                      .font(.system(size: 16, weight: .bold))
                      .foregroundColor(.white)
                      .frame(width: UIScreen.main.bounds.width * 0.4, height: 40)
                      .background(Color.green)
                      .cornerRadius(5)
                   }
             }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
           .background(Color.clear) // set the background of solve overlay view to clear color.
            .onAppear {
                    populateSolveAttemptIndices()
            }
             .scaleEffect(showShrinkAnimation ? 0.01 : 1)
                .opacity(showShrinkAnimation ? 0.01 : 1)
                .animation(showShrinkAnimation ? .easeInOut(duration: 0.5) : .none, value: showShrinkAnimation)
            .offset(x: showFlapAnimation ? 300 : 0, y: showFlapAnimation ? -300 : 0 )
            .opacity(showFlapAnimation ? 0.01 : 1)
            .animation(showFlapAnimation ? .easeInOut(duration: 0.8) : .none, value: showFlapAnimation)
            
         }
        .opacity(dismissOverlay ? 0 : 1)
       .animation(dismissOverlay ? .easeInOut(duration: 0.3) : .none, value: dismissOverlay)
    }
    
    private func dismissSolveView() {
        dismissOverlay = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            onDismiss()
        }
    }
   
    private func populateSolveAttemptIndices() {
      solveAttemptIndices.removeAll()
        for (index, letter) in viewModel.activeIndices {
            if viewModel.guessedLetters.contains(letter) {
                solveAttemptIndices[index] = String(letter)
              }
        }
    }

    private func submitPuzzle() {
        var solution = ""
            
        //Create the user entered solution
        for i in 0..<8*12 {
            if let solvedLetter = solveAttemptIndices[i] {
                solution += solvedLetter
            } else if viewModel.activeIndices[i] != nil {
                solution += " "
           }
        }

        if solution.trimmingCharacters(in: .whitespaces) == viewModel.phrase {
            // If Correct
            for (index, letter) in viewModel.activeIndices { // Update Main Board
                 if !viewModel.guessedLetters.contains(letter){
                    viewModel.selectPendingLetter(letter)
                    viewModel.confirmPendingLetter()
               }
            }
            onSolutionSubmit()
            dismissSolveView()
        
        } else {
            showFlapAnimation = true // Show the "flap" animation
            showShrinkAnimation = true // Show the "shrink" animation
            viewModel.playSound(named: "aww")
           DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                dismissSolveView() // then dismiss
                showFlapAnimation = false // Reset animation flags
                showShrinkAnimation = false
           }
        }
    }
    
     func selectSolvePendingLetter(_ letter: Character) {
         
         if let currentLetter = viewModel.pendingLetter {
              if viewModel.activeIndices.values.contains(currentLetter) {
                return
             }
          }
         
        viewModel.selectPendingLetter(letter)
       
    }
}

struct ResponsiveSolveBoardView: View {
    let gridSize: Int
    let gridRows: Int
    let activeIndices: [Int: Character]
    let guessedLetters: Set<Character>
    @Binding var solveAttemptIndices: [Int: String]
    
    var body: some View {
        GeometryReader { geometry in
            let availableWidth = geometry.size.width * 0.45
            let availableHeight = geometry.size.height * 0.45
            let boxSize = availableWidth / CGFloat(gridSize)

            VStack(spacing: 2) {  //reduced from 5 to narrow the space between boxes
                ForEach(0..<gridRows, id: \.self) { row in
                    HStack(spacing: 2) {
                        ForEach(0..<gridSize, id: \.self) { column in
                            let index = (row * gridSize) + column
                            if let letter = activeIndices[index] {
                                let isGuessed = guessedLetters.contains(letter)
                                 TextField(isGuessed ? String(letter) : "", text: Binding(
                                        get: { solveAttemptIndices[index] ?? "" },
                                         set: { newValue in
                                            let limitedNewValue = String(newValue.prefix(1)).uppercased()
                                             solveAttemptIndices[index] = limitedNewValue
                                         }
                                 ))
                                    .font(.system(size: boxSize * 0.9, weight: .bold))
                                    .frame(width: boxSize, height: boxSize)
                                     .background(isGuessed ? Color.gray.opacity(0.5) : Color.white)
                                    .cornerRadius(5)
                            } else {
                                Rectangle()
                                    .fill(Color.clear)
                                    .frame(width: boxSize, height: boxSize)
                                    .cornerRadius(5)
                            }
                        }
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity) // Center within parent
                              .padding(.horizontal, 10) // Ensure alignment
                              .background(Color.clear) // Add background color for visual clarity  //try to lessen opaqueness
            }
        }
    }
}

struct CustomOverlayKeyboardView: View {
    @State private var pressedKey: Character? = nil
    @State private var guessedKeys: Set<Character> = []
    
    let onLetterSelect: (Character) -> Void
    let guessedLetters: Set<Character>
    let letters = Array("ABCDEFGHIJKLMNOPQRSTUVWXYZ")
    let columns = 7

    var body: some View {
        VStack(spacing: 4) {
            ForEach(0..<3, id: \.self) { row in
                HStack(spacing: 4) {
                    ForEach(0..<columns, id: \.self) { column in
                        let index = row * columns + column
                        if index < letters.count {
                            let letter = letters[index]
                            Button(action: {
                                pressedKey = letter
                                onLetterSelect(letter)
                            }) {
                                Text(String(letter))
                                    .font(.system(size: 20, weight: .bold))
                                    .foregroundColor(.white)
                                    .frame(width: 40, height: 40)
                                    .background(keyBackgroundColor(for: letter))
                                    .cornerRadius(5)
                            }
                        }
                    }
                }
            }

            HStack(spacing: 4) {
                ForEach(21..<26, id: \.self) { index in
                    let letter = letters[index]
                    Button(action: {
                        pressedKey = letter
                        onLetterSelect(letter)
                    }) {
                        Text(String(letter))
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(.white)
                            .frame(width: 40, height: 40)
                            .background(keyBackgroundColor(for: letter))
                            .cornerRadius(5)
                    }
                }
                Button(action: {
                  if let key = pressedKey {
                        guessedKeys.insert(key)
                   }
                   pressedKey = nil
                   //onEnterPress()  // no longer use onEnter
                  }) {
                    Text("Enter")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.white)
                        .frame(width: 85, height: 40)
                        .background(Color.green)
                        .cornerRadius(5)
                 }
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
