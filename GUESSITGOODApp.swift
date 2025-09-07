//
//  GUESSITGOODApp.swift
//  GUESSITGOOD
//
//  Created by Nicholas Olivieri on 12/13/24.
//

import SwiftUI
import AVFoundation


@main
struct GUESSITGOODApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @StateObject var viewModel = GameViewModel()

    init() {
            // Place any synchronous setup code here
            print("GUESSITGOODApp initialized")
        }
    
    
    var body: some Scene {
        WindowGroup {
            if viewModel.isGameStarted {
                ContentView()
                    .environmentObject(viewModel)
                    .onAppear {
                        Task {
                            await AdManager.shared.loadInterstitialAd()
                        }
                    }
            } else {
                StartFields()
                    .environmentObject(viewModel)
                    .onAppear {
                        Task {
                            await AdManager.shared.loadInterstitialAd()
                        }
                    }
            }
        }
    }
}

