//
//  GameViewModel.swift
//  GUESSITGOOD
//
//  Created by Nicholas Olivieri on 12/13/24.
//

//
//  GameViewModel.swift
//  GUESSITGOOD
//

import SwiftUI
import AVFoundation
import GoogleMobileAds



class Player: Identifiable, ObservableObject, Equatable {
    let id: Int
    @Published var totalScore: Int = 0
    @Published var name: String = ""
    
    static func == (lhs: Player, rhs: Player) -> Bool {
          return lhs.id == rhs.id
      }
    
    init(id: Int, totalScore: Int = 0, name: String = "") {
        self.id = id
        self.totalScore = totalScore
        self.name = name
        
    }
}


struct Phrase: Decodable {
    let phrase: String
    let category: String
}

class GameViewModel: ObservableObject {
    @Published var categoryRevealed: Bool = false // Controls category visibility
    @Published var isGameStarted: Bool = false
    @Published var players: [Player] = []
    @Published var currentGame: Int = 1
    @Published var totalGames: Int = 1
    @Published var gamesRequested: Int = 1
    @Published var gamesPlayed: Int = 0
    @Published var currentPlayerIndex: Int = 0
    @Published var phrase: String = ""
    @Published var category: String = ""
    @Published var activeIndices: [Int: Character] = [:]
    @Published var guessedLetters: Set<Character> = []
    @Published var pendingLetter: Character?
    @Published var winnerMessage: String?
    @Published var isPlayAgainButtonEnabled: Bool = false
    @Published var gameInProgress: Bool = false // New property
    @Published var isAdShown = false // New flag

    enum TurnPhase {
        case idle
        case waitingForWheel
        case spinning
        case resolving
        case guessing
    }

    @Published var phase: TurnPhase = .idle
    @Published var showWheel: Bool = false
    @Published var showClue: Bool = false
    @Published var currentWheelValue: Int?
    @Published var isFirstTurn: Bool = true
    
    // Call this when the game starts
        func resetClueButton() {
            categoryRevealed = false
        }
    // Function to reveal the category when CLUE is pressed
    func revealCategory() {
        guard !categoryRevealed else { return } // Prevent multiple activations

        categoryRevealed = true

        if isSpeechEnabled {
            speechManager.speak("The clue is \(category).")
        }
    }
    
    
    
    
    func handleAdDismissal() {
        isPlayAgainButtonEnabled = true
    }
      //Below for when Speech should be disabled.
    
    
    
    @Published var isSpeechEnabled: Bool = true
    @Published var isMusicEnabled: Bool = true {
        didSet {
            if !isMusicEnabled {
                stopSound() // Stop music when the toggle is turned off
            }
        }
    }
    //This may still be needed to calculate score.
    private let letterScores: [Character: Int] = [
            "A": -10, "E": -10, "I": -10, "O": -10, "U": -10,
            "L": 250, "N": 250, "R": 250, "S": 250, "T": 250,
            "D": 250, "G": 250,
            "B": 250, "C": 250, "M": 250, "P": 250,
            "F": 250, "H": 250, "V": 250, "W": 250, "Y": 250,
            "K": 250, "J": 250, "X": 250,
            "Q": 250, "Z": 250
        ]
    
    private var phrases: [Phrase] = []
    var gridSize = 12
    var gridRows = 8
    private var audioPlayer: AVAudioPlayer?
    
    private let speechManager = SpeechManager() // SpeechManager instance
    
    
    func stopSound() {
        if audioPlayer?.isPlaying == true {
            audioPlayer?.stop()
            print("Music has been stopped.")
        }
        audioPlayer = nil
    }
    
    /*
    // TEMPORARY hard coded phrase to test UI of puzzleboard etc UI.
    private func selectRandomPhrase() {
     // Temporarily hard-code the phrase for debugging
     phrase = "A journey of a thousand miles begins with a single step"
     category = "Debug Category"
     
     // Optionally, include speech for debugging purposes
     if isSpeechEnabled {
     speechManager.speak("The category is \(category).")
     }
     
     // Stop sound to ensure no conflict with debugging
  //  stopSound()
     
     print("Phrase is: \(phrase), Category is: \(category)") // Debug Statement
     }

    //END hard coded phrase
     */
    private func selectRandomPhrase() {
            if let randomPhrase = phrases.randomElement() {
                phrase = randomPhrase.phrase.uppercased()
                category = randomPhrase.category
                resetClueButton() // Reset CLUE button each game
                
                stopSound()
            } else {
                phrase = "DEFAULT PHRASE"
                category = "CATEGORY"
            }
            print("Phrase is: \(phrase)")
        }

    enum WheelOutcome {
        case points(Int)
        case clue
        case loseTurn
        case bankrupt
    }

    private func announceCurrentPlayer(starting: Bool) {
        guard let player = currentPlayer else { return }
        guard isSpeechEnabled else { return }
        if starting {
            speechManager.speak("\(player.name), spin the wheel to start the game.")
        } else {
            speechManager.speak("\(player.name), spin the wheel.")
        }
    }

    func startFirstTurn() {
        phase = .waitingForWheel
        showWheel = false
        announceCurrentPlayer(starting: true)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.showWheel = true
        }
    }

    func startNewTurn() {
        phase = .waitingForWheel
        showWheel = false
        announceCurrentPlayer(starting: false)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.showWheel = true
        }
    }

    func spinWheel() {
        phase = .spinning
        isFirstTurn = false
    }

    func handleWheelStop(_ outcome: WheelOutcome) {
        switch outcome {
        case .points(let value):
            currentWheelValue = value
            if isSpeechEnabled {
                speechManager.speak("You landed on \(value)")
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self.showWheel = false
                self.phase = .guessing
            }
        case .clue:
            revealCategory()
            showClue = true
            if isSpeechEnabled {
                speechManager.speak("You landed on clue")
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self.showWheel = false
                self.phase = .resolving
            }
        case .loseTurn:
            currentWheelValue = nil
            if isSpeechEnabled {
                speechManager.speak("Lose a turn")
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self.showWheel = false
                self.moveToNextPlayer()
                self.startNewTurn()
            }
        case .bankrupt:
            currentWheelValue = nil
            if let current = self.currentPlayer,
               let index = self.players.firstIndex(where: { $0.id == current.id }) {
                self.players[index].totalScore = 0
            }
            if isSpeechEnabled {
                speechManager.speak("Bank-ruppt")
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self.showWheel = false
                self.moveToNextPlayer()
                self.startNewTurn()
            }
        }
    }

    func dismissClue() {
        showClue = false
        phase = .guessing
    }
    

  
    
    // MARK: - Computed Property
    var currentPlayer: Player? {
        players.indices.contains(currentPlayerIndex) ? players[currentPlayerIndex] : nil
    }
    
    // MARK: - Confirm Letter Logic
    
    func moveToNextPlayer() {
        guard !players.isEmpty else {
            print("Error: No players available to move to the next player.")
            return
        }
        currentPlayerIndex = (currentPlayerIndex + 1) % players.count
        print("Player \(currentPlayerIndex + 1)'s turn.")
    }
    func confirmPendingLetter() {
        guard let letter = pendingLetter else { return }
        guard !players.isEmpty else {
            print("Error: No players available. Initializing default players.")
            players = (1...2).map { Player(id: $0, name: "Player \($0)") } // Ensure players are present
            return
        }
        
        if guessedLetters.contains(letter) {
            playSound(named: "Buzzer", withExtension: "wav")
            if isSpeechEnabled { // Check if speech is enabled before speaking
                speechManager.speak("Letter \(letter) has already been guessed.")
            }
            pendingLetter = nil
            return
        }
        
        
        guessedLetters.insert(letter)

        let occurrences = activeIndices.values.filter { $0 == letter }.count

        if occurrences > 0 {
            playSound(named: "Ding")
            if isSpeechEnabled { // Check if speech is enabled before speaking
                speechManager.speak("\(occurrences) \(occurrences == 1 ? "letter" : "letters") \(letter).")
            }
            if let currentPlayer = currentPlayer,
               let index = players.firstIndex(where: { $0.id == currentPlayer.id }),
               let wheelValue = currentWheelValue {
                let letterValue = letterScores[letter] ?? 0
                let pointsEarned = occurrences * (wheelValue + letterValue)
                players[index].totalScore += pointsEarned
            }
        } else {
            playSound(named: "Buzzer", withExtension: "wav")
            if isSpeechEnabled { // Check if speech is enabled before speaking
                speechManager.speak("No \(letter).")
            }
            moveToNextPlayer()
            currentWheelValue = nil
            startNewTurn()
        }
        
        if checkIfGameSolved() {
          //  playSound(named: "Cheering")
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.evaluatePuzzleSolution(self.phrase)
            }
        }
        
        pendingLetter = nil
        
    }
    
    // MARK: - Initialize Sounds
    func playSound(named soundName: String, withExtension fileExtension: String = "mp3") {
        guard isMusicEnabled else {
            stopSound() // Stop any currently playing music if toggle is off
            print("Music and game sounds are muted.")
            return
        }
        
        guard let soundURL = Bundle.main.url(forResource: soundName, withExtension: fileExtension) else {
            print("Could not find sound file \(soundName).\(fileExtension)")
            return
        }
        
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: soundURL)
            audioPlayer?.play()
        } catch {
            print("Error playing sound: \(error.localizedDescription)")
        }
    }
    
    
    
    
    
    // MARK: - Game Initialization Logic
    
    func initializeGame() {
        // 1. Load phrases from your JSON file
        loadPhrases()
        
        // 2. Select a random phrase and category
        selectRandomPhrase()
        
        // 3. Calculate the activeIndices for the game board
        calculateActiveIndices()
        
        // 4. Reset game-specific properties
        guessedLetters.removeAll()
        pendingLetter = nil
        currentPlayerIndex = 0
        currentGame = 1
        winnerMessage = nil
        isPlayAgainButtonEnabled = false
        
        // 5. Mark the game as started and in progress
        isGameStarted = true
        startGame()
        
        // 6. Play or stop the starting sound effect based on music toggle state
        if isMusicEnabled {
            playSound(named: "GETITGOOD")
        } else {
            stopSound() // Stop any currently playing sounds
            print("Music is muted; skipping opening sound effect.")
        }
        
        // Debug information
        print("Game Initialized. Active Indices: \(activeIndices.keys.sorted())")
        currentWheelValue = nil
        isFirstTurn = true
        startFirstTurn()
    }
    
    
    
    func setNumberOfPlayers(_ number: Int) {
        // New code to contrain free users to 2 players
        let validNumber = max(1, min(number,3)) // Enforce the limit
        
        // Initialize the players array with default names or existing names
        players = (1...validNumber).map { index in
            Player(id: index, name: players.indices.contains(index - 1) ? players[index - 1].name : "Player \(index)")
        }
        print("Number of Players: \(players.count)")
    }
    
    
    
    
    //original code below for func setNumberOfPlayers(_number: Int) {
    //   let validNumber = max(1, min(number, PremiumManager.shared.maxPlayers()))
    //  players = (1...validNumber).map { Player(id: $0, name: players.indices.contains($0 - 1) ? players[$0 - 1].name : "") }
    //    print("Number of Players: \(players.count)")
    //      }
    
    func setNumberOfGames(_ number: Int) {
        let validNumber = max(1, number)
        totalGames = validNumber
        gamesRequested = validNumber
        gamesPlayed = 0
        print("Number of Games: \(totalGames)")
    }

    func handleRestart() {
        isGameStarted = false
        players.removeAll() // Clear players
        totalGames = 1
        gamesRequested = 1
        currentGame = 1
        gamesPlayed = 0
        guessedLetters.removeAll()
        activeIndices.removeAll()
        pendingLetter = nil
        phrase = ""
        category = ""
        winnerMessage = nil
        currentPlayerIndex = 0
        isPlayAgainButtonEnabled = true
        endGame()
        isAdShown = false // Reset flag
        // Add logic to reset game state
        print("Game has been reset. Returning to Start Game screen.")
    }
    
    
    func resetGame() {
        guessedLetters.removeAll()
        pendingLetter = nil
        activeIndices.removeAll()
        selectRandomPhrase()
        calculateActiveIndices()
        currentPlayerIndex = 0 // Ensure the first player starts each game
        isPlayAgainButtonEnabled = false // Set button enabled when game solved
        gameInProgress = true // start the next game - updated by chat because of dual Solve/Play Again button
        categoryRevealed = false
        isFirstTurn = true
        print("Resetting game state.")
        startFirstTurn()
    }
    
    func loadPhrases() {
        do {
            if let url = Bundle.main.url(forResource: "phrases", withExtension: "json") {
                let data = try Data(contentsOf: url)
                let loadedPhrases = try JSONDecoder().decode([Phrase].self, from: data)
                phrases = loadedPhrases
                print("Phrases loaded successfully.")
            } else {
                print("Could not find phrases.json file.")
            }
        } catch {
            print("Error loading phrases: \(error.localizedDescription)")
        }
    }
    
    
    
    func calculateActiveIndices() {
        var currentRow = 0
        var currentCol = 0
        activeIndices.removeAll()
        
        let words = phrase.split(separator: " ")
        
        for word in words {
            if currentCol + word.count > gridSize {
                currentRow += 1
                currentCol = 0
            }
            
            for char in word {
                let index = (currentRow * gridSize) + currentCol
                activeIndices[index] = char
                currentCol += 1
            }
            
            currentCol += 1 // Add space between words
            if currentCol > gridSize {
                currentRow += 1
                currentCol = 0
            }
        }
        
        // Dynamically adjust gridRows based on the number of rows used
        gridRows = currentRow + 1
        print("Active Indices: \(activeIndices), Grid Rows: \(gridRows)") // Debugging
    }
    
    
    
    func selectPendingLetter(_ letter: Character) {
        pendingLetter = letter
        if isSpeechEnabled { // Check if speech is enabled before speaking
            speechManager.speak("\(letter).")
        }
        stopSound()
    }
    
    
    func initiateSolvePuzzle() {
        let correctGuessesExist = activeIndices.values.contains { guessedLetters.contains($0) }
        if !correctGuessesExist {
            print("No correctly guessed letters on the gameboard. Solve button action denied.")
            playSound(named: "enteraletter", withExtension: "mp3")
            return
        }
        
        print("Player \(currentPlayerIndex + 1) attempting to solve the puzzle.")
        
        // Prompt the user to enter the full puzzle solution
        let alert = UIAlertController(title: "", message: nil, preferredStyle: .alert)
        
        alert.addTextField { textField in
            textField.placeholder = "Enter full solution"
        }
        
        alert.addAction(UIAlertAction(title: "Submit", style: .default) { _ in
            if let solution = alert.textFields?.first?.text?.uppercased() {
                self.evaluatePuzzleSolution(solution)
            }
        })
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        // Present the alert
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let rootVC = windowScene.windows.first?.rootViewController {
            rootVC.present(alert, animated: true, completion: nil)
        }
    }
    
    //MARK: -WINNER ANNOUNCEMENT
    func isVowel(_ letter: Character) -> Bool {
        return "AEIOU".contains(letter)
    }
    
    func evaluatePuzzleSolution(_ solution: String) {   //made public from internal so I can use it in Content View
        //Let solution be a trimmed solution
        let solution = solution.trimmingCharacters(in: .whitespaces)
        if solution == phrase {
            print("Correct solution! Player \(currentPlayerIndex + 1) wins the round.")
            
            let remainingScore = activeIndices.values.filter { !guessedLetters.contains($0) && !isVowel($0) }
                .reduce(0) { total, letter in
                    total + (letterScores[letter] ?? 0)
                }
            if let currentPlayer = currentPlayer, let index = players.firstIndex(where: {$0.id == currentPlayer.id}) {
                players[index].totalScore += remainingScore
            }
            
            print("Remaining points added: \(remainingScore)")
            if let currentPlayer = currentPlayer {
                print("Player \(currentPlayerIndex + 1)'s total score: \(currentPlayer.totalScore)")
            }
            
            guessedLetters = Set(activeIndices.values)
        //    playSound(named: "Cheering")  //was commented out
            
            if currentGame == totalGames {
                let winner = players.max(by: { $0.totalScore < $1.totalScore })
                winnerMessage = "\(winner?.name ?? "Player 1") Wins the Series!"
                print("Series completed. Winner: \(winnerMessage ?? "No winner")")

                if isSpeechEnabled { // Check if speech is enabled before speaking
                    speechManager.speak("\(winner?.name ?? "Player 1") is the series winner!")
                }
            } else {
                currentPlayerIndex = (currentPlayerIndex + 1) % players.count
                print("Next round starts with Player \(currentPlayerIndex + 1).")
            }

            // Use unified end-game flow which also handles ads and leader announcements
            endGame()
        } else {
            print("Incorrect solution! Passing turn to the next player.")
            playSound(named: "aww")
            moveToNextPlayer()
        }
    }
    
    
    
    
    
    
    // MARK: - Check if Single Game Solved
    func checkIfGameSolved() -> Bool {
        let allLetters = Set(activeIndices.values)
        return allLetters.isSubset(of: guessedLetters)
    }
    
    // No changes to this function
    func checkIfSeriesOver() -> Bool {
        return !gameInProgress && checkIfGameSolved() && currentGame == totalGames
    }
    
    // No changes to this function
    func startGame() {
        gameInProgress = true
    }

    private func announceLeader(completion: @escaping () -> Void) {
        guard let leader = players.max(by: { $0.totalScore < $1.totalScore }) else {
            completion()
            return
        }
        let message = "Congratulations \(leader.name)! You are in the lead at this point, with \(leader.totalScore) points scored. Good luck to everyone for a good game."
        if isSpeechEnabled {
            speechManager.speak(message) {
                completion()
            }
        } else {
            completion()
        }
    }

    // Modified endGame function to include ads after each game
    func endGame() {
        print("Checking if game is solved: \(checkIfGameSolved())")

        guard !isAdShown else {
            print("Ad already shown, skipping further actions.")
            return } // Prevent multiple ad triggers
        gameInProgress = false

        if checkIfSeriesOver() {
            // Series is over, show series-end ad
            isAdShown = true
            print("Series is over. Preparing to show interstitial ad.")

            gamesPlayed += 1

            // Proceed once the ad is dismissed
            AdManager.shared.onAdDismissed = { [weak self] in
                self?.handleAdDismissal()
                AdManager.shared.onAdDismissed = nil
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + 3) { [weak self] in
                guard let self = self else { return }
                if let rootVC = getRootViewController(), AdManager.shared.isAdReady() {
                    print("Series End Interstitial ad is ready. Showing now.")
                    AdManager.shared.showInterstitialAd(from: rootVC)
                } else {
                    print("Ad is not ready or root view controller not found.")
                    AdManager.shared.onAdDismissed = nil
                    self.handleAdDismissal()
                }
            }
        } else if checkIfGameSolved() {
            // Single game solved, show game-end ad
            isAdShown = true
            print("Game solved. Preparing to show interstitial ad.")
            print("Attempting to show ad. isAdShown: \(isAdShown)")

            // Proceed to the next game only after the ad is dismissed
            AdManager.shared.onAdDismissed = { [weak self] in
                self?.prepareNextGame()
                AdManager.shared.onAdDismissed = nil
            }

            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                if let rootVC = getRootViewController(), AdManager.shared.isAdReady() {
                    print("Interstitial ad is ready. Showing now.")
                    AdManager.shared.showInterstitialAd(from: rootVC)
                } else {
                    print("Ad is not ready or root view controller not found. Resetting immediately.")
                    AdManager.shared.onAdDismissed = nil
                    self.prepareNextGame()
                }
            }
        } else {
            print("Ad is not ready or root view controller not found. Resetting game.")
            self.currentGame += 1
            self.gamesPlayed += 1
            self.resetGame()
            self.isAdShown = false
        }
    }

    private func prepareNextGame() {
        // Ensure we do not start a new game if the series has already ended
        guard currentGame < totalGames else {
            print("All games completed. No further games.")
            return
        }

        print("Resetting game for next round.")
        print("Current game index: \(self.currentGame)")
        self.currentGame += 1
        self.gamesPlayed += 1
        self.isAdShown = false // Reset for the next game

        // Announce the leader after every game once at least two games have been played
        if self.gamesPlayed >= 2 {
            self.announceLeader { [weak self] in
                self?.resetGame()
            }
        } else {
            self.resetGame()
        }
    }
    
    
    // No changes to this function
    func showAdIfNeeded() {
        guard let rootVC = UIApplication.shared.connectedScenes
            .compactMap({ $0 as? UIWindowScene })
            .flatMap({ $0.windows })
            .first?.rootViewController else {
            print("Root view controller not found.")
            return
        }
        print("AdManager.shared.isAdReady(): \(AdManager.shared.isAdReady())")
        if AdManager.shared.isAdReady() {
            AdManager.shared.showInterstitialAd(from: rootVC)
        } else {
            print("Ad is not ready to be shown.")
        }
    }
    
    // Helper to retrieve the root view controller
    func getRootViewController() -> UIViewController? {
        return UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap { $0.windows }
            .first?.rootViewController
    }
    
}

    
   
    


        
        
        
        
       
        
    
    

