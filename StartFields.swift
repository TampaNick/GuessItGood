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
                VStack{
                    Spacer()
                        .frame(height: 5) //leave space for the button
                }
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
                            .background(Color(.blue))
                            .cornerRadius(8)
                            .padding(.top, 60)
            Spacer()
                            .zIndex(1) //Ensure content is above background
            
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
                                // Initialize players array here with default names
                                viewModel.players = (1...selectedPlayers).map { index in
                                    Player(id: index, name: "")   // had "player \(index)" by default
                                    //       Player(id: index, name: " \(index)")   // had "player \(index)" by default //original code that added a default number to name field
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
                                    viewModel.players[currentPlayerIndex].name // Access the player's current name
                                },
                                set: { newValue in
                                    viewModel.players[currentPlayerIndex].name = String(newValue.prefix(12)) // Truncate to 12 characters
                                }
                            )
                        )
                        .onChange(of: currentPlayerIndex) { _ in
                            viewModel.players[currentPlayerIndex].name = "" // Clear field for the next player
                        }
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .frame(maxWidth: 200)
                        .onSubmit { // Ensure the player's name is cleared when the input field first appears
                            print("Current Player Index: \(currentPlayerIndex)")//debug
                            print("Player Name: \(viewModel.players[currentPlayerIndex].name)") //debug
                            
                            if !viewModel.players[currentPlayerIndex].name.isEmpty {
                                    withAnimation {
                                        if currentPlayerIndex < selectedPlayers - 1 {
                                            currentPlayerIndex += 1
                                        } else {
                                            currentStep += 1
                                        }
                                    }
                                    viewModel.players[currentPlayerIndex].name = "" // Clear the field
                                }
                            }
                        Button("Next") {
                            withAnimation {
                                if viewModel.players[currentPlayerIndex].name.isEmpty {
                                    viewModel.players[currentPlayerIndex].name = "Player \(currentPlayerIndex + 1)" // Assign a default name if empty
                                }
                                withAnimation {
                                    
                                    if currentPlayerIndex < selectedPlayers - 1 {
                                        currentPlayerIndex += 1
                                    } else {
                                        currentStep += 1
                                    }
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
                                viewModel.initializeGame() // Call initializeGame here
                                viewModel.isGameStarted = true // Trigger ContentView to appear
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
                                    .foregroundColor(.white) // White color for visibility
                                    .padding()
                                    .background(Color.black.opacity(0.2))//temporary debug background.  Omit after testing
                                    .cornerRadius(5)
                            }
                      //      .padding(.top,50)
                        //    .padding(.leading,20)
                            
                            Spacer()
                        }
                       
                        Spacer()
                    }
                    .zIndex(2)
                    
                    // Hamburger Menu Content
                if isMenuOpen {
                    HamburgerMenu(isMenuOpen: $isMenuOpen)
                        .background(Color.black.opacity(0.8)) // Optional dim background
                                                .transition(.move(edge: .leading))
                                                .animation(.easeInOut)
                                                .edgesIgnoringSafeArea(.leading)
                                                .zIndex(3)
                }
            }
                    .navigationBarHidden(true) // Properly hides the navigation bar
                           }
                           .navigationViewStyle(StackNavigationViewStyle()) // Avoids navigation style conflicts
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

