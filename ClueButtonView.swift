//
//  ClueButtonView.swift
//  GUESSITGOOD
//
//  Created by Nicholas Olivieri on 1/27/25.
//

import SwiftUI

struct ClueButtonView: View {
    @ObservedObject var viewModel: GameViewModel
    
    var body: some View {
            Button(action: {
                viewModel.revealCategory()
            }) {
                Text("CLUE")
                    .font(.system(size: 14))
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(Color.blue)
                    .cornerRadius(5)
            }
            .disabled(viewModel.categoryRevealed) // ✅ Button disabled after first press
        }
    }


