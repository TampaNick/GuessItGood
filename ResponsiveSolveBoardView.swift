//
//  ResponsiveSolveBoardView.swift
//  GUESSITGOOD
//
//  Created by Nicholas Olivieri on 12/25/24.
//

import SwiftUI

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
                                    .font(.system(size: boxSize * 0.8, weight: .bold))
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
