//
//  GameBoard.swift
//  GUESSITGOOD
//
//  Created by Nicholas Olivieri
//


import SwiftUI
import GameKit
import AVFoundation


struct ResponsiveGameBoardView: View {
    @EnvironmentObject var viewModel: GameViewModel  // Use @EnvironmentObject
    
    var body: some View {
        GeometryReader { geometry in
            // Dynamically calculate box size and board dimensions
            // Calculate the total number of letters in the puzzle
            let totalPieces = viewModel.activeIndices.count
            let maxWidth = geometry.size.width * 0.7 // Max width for the black background
        //    let boxSize = (maxWidth / CGFloat(viewModel.gridSize)) * 0.95 // Example: Make pieces 10% smaller
          //  let totalWidth = CGFloat(viewModel.gridSize) * boxSize
            
            // Dynamically adjust block size based on total pieces
                      let boxSize: CGFloat = {
                          switch totalPieces {
                          case 0...10:
                              return maxWidth / 10 // Larger blocks for fewer letters
                          case 11...25:
                              return maxWidth / 12 // Medium blocks
                          default:
                              return maxWidth / 13 // Smaller blocks for larger puzzles
                          }
                      }()
            
            let totalHeight = CGFloat(viewModel.gridRows) * (boxSize + 3) // includes spacing
            let paddingSpace: CGFloat = 11 // Extra space to add above and below
            
            ZStack {
                Color.black
                    .cornerRadius(10)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                       //     .stroke(Color.red, lineWidth: 5)
                    )
                
                
                
                VStack(spacing: 15) {
                    // Render rows of puzzle boxes
                    ForEach(0..<viewModel.gridRows, id: \.self) { row in
                        HStack(spacing: 3) {
                            ForEach(0..<viewModel.gridSize, id: \.self) { column in
                                let index = (row * viewModel.gridSize) + column
                                if let letter = viewModel.activeIndices[index] {
                                    let isGuessed = viewModel.guessedLetters.contains(letter)
                                    Text(isGuessed ? String(letter) : "")
                                        .font(.system(size: boxSize * 0.81, weight: .bold))
                                        .frame(width: boxSize, height: boxSize)
                                        .background(Color.white)
                                        .cornerRadius(5)
                                } else {
                                    Rectangle()
                                        .fill(Color.clear)
                                        .frame(width: boxSize, height: boxSize)
                                }
                            }
                        }
                        
                        //      .frame(maxWidth: totalWidth, alignment: .center) // Center rows horizontally
                        .padding(.bottom, customGapForRow(row)) // Apply custom gap logic
                    }
                }
                
            }
            
            .padding(15) // Padding for the content inside the gameboard  //was 15
            .frame(
           //     width: totalWidth + 12 * paddingSpace, // Total width including horizontal padding - was 15
                height: totalHeight + 12 * paddingSpace, // Total height including vertical padding - was 15
                alignment: .center
            )
            .background(Color.black)
            .cornerRadius(10)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color.red, lineWidth: 5)
            )
            .position(
                x: geometry.size.width / 2,
                y: geometry.size.height / 2 // Center vertically
            )
        }
    }
    
    // Helper function to define custom gaps
    func customGapForRow(_ row: Int) -> CGFloat {
        let rowLetters = viewModel.activeIndices.filter { $0.key / viewModel.gridSize == row }
        switch rowLetters.count {
        case 0...4: return 20 // Larger gap for short rows
        case 5...8: return 10 // Medium gap for average-length rows
        default: return 5 // Smaller gap for long rows
        }
    }
}
struct ResponsiveGameBoardView_Previews: PreviewProvider {
    
    // Helper to build a mock GameViewModel from given words
    static func makeMockViewModel(words: [String], gridSize: Int) -> GameViewModel {
        let vm = GameViewModel()
        vm.gridSize = gridSize
        vm.gridRows = words.count
        vm.activeIndices = [:]
        
        for (row, word) in words.enumerated() {
            for (col, char) in word.enumerated() {
                let index = row * gridSize + col
                vm.activeIndices[index] = char
            }
        }
        // Mark a few letters guessed to simulate game progress
        vm.guessedLetters = Set(["A", "E", "I", "O", "U"].map { Character($0) })
        
        // If your ContentView expects other viewModel flags (e.g. currentPlayerName, score)
        // set them here to make the preview show the top UI. Example:
        // vm.currentPlayerName = "You"
        // vm.playerScores = ["You": 12, "CPU": 8]
        
        return vm
    }
    
    static var previews: some View {
        // Example real-word puzzles for previewing real layouts
        let smallVM = makeMockViewModel(words: ["WORD", "GAME", "TEST"], gridSize: 6)
        let mediumVM = makeMockViewModel(words: ["SWIFT", "PUZZLE", "GUESS"], gridSize: 8)
        let largeVM = makeMockViewModel(
            words: [
                "DEVELOPERZZZZ",
                "PROGRAMMINGX",
                "APPLICATIONS",
                "XCODEEDITORR",
                "FRAMEWORKSSS",
                "ALGORITHMMMS",
                "PUZZLEBOARDD",
                "DEBUGGINGGGG",
                "INTERFACESSS",
                "SIMULATORRRR",
                "RENDERINGGGG",
                "CHALLENGEEEZ"
            ],
            gridSize: 12
        )
        
        return Group {
            // Full screen device preview — should show nav bar / top UI
            NavigationStack {
                ContentView()
                    .environmentObject(largeVM)
            }
            .previewDevice("iPhone 15 Pro")
            .previewDisplayName("iPhone 15 Pro — Full Screen")
            
            // Fixed large layout (useful when Canvas clips part of the screen)
            NavigationStack {
                ContentView()
                    .environmentObject(largeVM)
            }
            .previewLayout(.fixed(width: 430, height: 932)) // big phone size
            .previewDisplayName("Fixed 430×932 — Top UI Visible")
            
            // Smaller phone to see how the top UI competes with board
            NavigationStack {
                ContentView()
                    .environmentObject(mediumVM)
            }
            .previewLayout(.fixed(width: 375, height: 812)) // compact phone
            .previewDisplayName("375×812 — Compact Phone")
            
            // Bonus: board-only, sizeThatFits (handy when tuning board spacing)
            ResponsiveGameBoardView()
                .environmentObject(smallVM)
                .previewLayout(.sizeThatFits)
                .padding()
                .previewDisplayName("Board Only — sizeThatFits")
        }
    }
}
