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
        ZStack {
            // Dimmed background when the menu is open
            if isMenuOpen {
                Color.black.opacity(0.5)
                    .ignoresSafeArea()
                    .onTapGesture {
                        withAnimation {
                            isMenuOpen = false
                        }
                    }
                }
            
            // Menu content
            if isMenuOpen {
                VStack(alignment: .leading) {
                    NavigationLink(destination: UserGuideView()) {
                        Text("User Guide")
                            .font(.headline)
                            .foregroundColor(.white)
                        Spacer()
                    }
                    
                    
                    NavigationLink(destination: QuickStartView()) { /* Your destination view for Quick Start Guide */
                        Text("Quick Start")
                            .font(.headline)
                            .foregroundColor(.white)
                        Spacer()
                    }
                    
                    NavigationLink(destination: GamePlayView()) {
                        Text("Game Play")
                            .font(.headline)
                            .foregroundColor(.white)
                        Spacer()
                    }
                    
                    NavigationLink(destination: SolvingView()) {
                         Text("Solving")
                        .font(.headline)
                          .foregroundColor(.white)
                            }
                    
                    
                    Spacer()
                }
                        .frame(maxWidth: 200)
                        .background(Color.gray)
                        .transition(.move(edge: .leading))
                        .animation(.easeInOut, value: isMenuOpen)
                }
            }
        }
    }

