//
//  StartFields.swift
//  GUESSITGOOD
//
//  Created by Nicholas Olivieri
//

import SwiftUI
import AVFoundation

struct StartFields: View {
    @EnvironmentObject var viewModel: GameViewModel
    @State private var currentStep: Int = 1
    @State private var selectedPlayers: Int = 1
    @State private var playerNames: [String] = ["", "", ""]
    @State private var totalGamesInput: Int = 1
    @State private var currentPlayerIndex: Int = 0
    @State private var isMenuOpen: Bool = false

    var body: some View {
        NavigationView {
            ZStack {
                Image("GIG_ICON")
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color.black.opacity(0.2))

                VStack {
                    Spacer()

                    if !viewModel.isGameStarted {
                        Text("Guess It Good!")
                            .font(.system(size: 38))
                            .foregroundColor(.white)
                            .background(Color.blue)
                            .cornerRadius(8)
                            .padding(.top, 60)
                            .zIndex(1)

                        Spacer()

                        VStack(spacing: 20) {
                            if currentStep == 1 {
                                VStack {
                                    Text("How Many Players?")
                                        .font(.headline)
                                        .foregroundColor(.white)
                                        .background(Color.blue)
                                        .cornerRadius(8)

                                    Picker("Select Players", selection: $selectedPlayers) {
                                        ForEach(1...3, id: \.self) { number in
                                            Text("\(number)").tag(number)
                                        }
                                    }
                                    .pickerStyle(SegmentedPickerStyle())
                                    .background(Color.blue)
                                    .cornerRadius(8)
                                    .frame(maxWidth: 200)

                                    Button("Next") {
                                        withAnimation {
                                            currentStep += 1
                                            viewModel.players = (1...selectedPlayers).map { index in
                                                Player(id: index, name: "")
                                            }
                                        }
                                    }
                                    .buttonStyle(NextButtonStyle())
                                }
                            } else if currentStep == 2 {
                                VStack {
                                    Text("Player \(currentPlayerIndex + 1) Name:")
                                        .font(.headline)
                                        .foregroundColor(.white)
                                        .background(Color.blue)
                                        .cornerRadius(8)

                                    TextField(
                                        "Enter Name",
                                        text: Binding(
                                            get: {
                                                viewModel.players[currentPlayerIndex].name
                                            },
                                            set: { newValue in
                                                viewModel.players[currentPlayerIndex].name = String(newValue.prefix(12))
                                            }
                                        )
                                    )
                                    .onChange(of: currentPlayerIndex) { _ in
                                        viewModel.players[currentPlayerIndex].name = ""
                                    }
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                    .frame(maxWidth: 200)
                                    .onSubmit {
                                        if !viewModel.players[currentPlayerIndex].name.isEmpty {
                                            withAnimation {
                                                if currentPlayerIndex < selectedPlayers - 1 {
                                                    currentPlayerIndex += 1
                                                } else {
                                                    currentStep += 1
                                                }
                                            }
                                            viewModel.players[currentPlayerIndex].name = ""
                                        }
                                    }

                                    Button("Next") {
                                        withAnimation {
                                            if viewModel.players[currentPlayerIndex].name.isEmpty {
                                                viewModel.players[currentPlayerIndex].name = "Player \(currentPlayerIndex + 1)"
                                            }
                                            if currentPlayerIndex < selectedPlayers - 1 {
                                                currentPlayerIndex += 1
                                            } else {
                                                currentStep += 1
                                            }
                                        }
                                    }
                                    .buttonStyle(NextButtonStyle())
                                }
                            } else if currentStep == 3 {
                                VStack {
                                    Text("Number of Games:")
                                        .font(.headline)
                                        .foregroundColor(.white)
                                        .background(Color.blue)

                                    TextField("Enter Total Games", value: $totalGamesInput, formatter: NumberFormatter())
                                        .textFieldStyle(RoundedBorderTextFieldStyle())
                                        .frame(maxWidth: 200)
                                        .keyboardType(.numberPad)

                                    Button("Start Game") {
                                        withAnimation {
                                            viewModel.setNumberOfGames(totalGamesInput)
                                            viewModel.initializeGame()
                                            viewModel.isGameStarted = true
                                        }
                                    }
                                    .buttonStyle(StartGameButtonStyle())
                                }
                            }
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
                        .padding(.bottom, 50)
                    }
                }

                // Hamburger Menu Button
                VStack {
                    HStack {
                        Button(action: {
                            withAnimation {
                                isMenuOpen.toggle()
                            }
                        }) {
                            Image(systemName: "line.horizontal.3")
                                .resizable()
                                .frame(width: 15, height: 10)
                                .foregroundColor(.white)
                                .padding()
                                .background(Color.black.opacity(0.2))
                                .cornerRadius(5)
                        }
                        Spacer()
                    }
                    Spacer()
                }
                .zIndex(2)

                // Hamburger Menu Content
                if isMenuOpen {
                    HamburgerMenu(isMenuOpen: $isMenuOpen)
                        .background(Color.black.opacity(0.8))
                        .transition(.move(edge: .leading))
                        .animation(.easeInOut, value: isMenuOpen)
                        .edgesIgnoringSafeArea(.leading)
                        .zIndex(3)
                }
            }
            .navigationBarHidden(true)
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }

    private func resetStartFields() {
        currentStep = 1
        selectedPlayers = 1
        playerNames = ["", "", ""]
        totalGamesInput = 1
        currentPlayerIndex = 0
    }

    // Button styles are now properly defined here.
    struct NextButtonStyle: ButtonStyle {
        func makeBody(configuration: Configuration) -> some View {
            configuration.label
                .font(.headline)
                .foregroundColor(.white)
                .frame(maxWidth: 200, maxHeight: 40)
                .background(Color.blue)
                .cornerRadius(8)
                .opacity(configuration.isPressed ? 0.7 : 1)
        }
    }

    struct StartGameButtonStyle: ButtonStyle {
        func makeBody(configuration: Configuration) -> some View {
            configuration.label
                .font(.headline)
                .foregroundColor(.white)
                .frame(maxWidth: 200, maxHeight: 50)
                .background(Color.green)
                .cornerRadius(10)
                .opacity(configuration.isPressed ? 0.7 : 1)
        }
    }
}

